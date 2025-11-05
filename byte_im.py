import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, Dataset
from torchvision import transforms
from PIL import Image
import os
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.metrics import precision_score, recall_score, f1_score,accuracy_score
import torch.nn.functional as F
# 1. 数据准备
class CustomDataset(Dataset):
    def __init__(self, image_paths, labels, transform=None):
        self.image_paths = image_paths
        self.labels = labels
        self.transform = transform

    def __len__(self):
        return len(self.image_paths)

    def __getitem__(self, idx):
        img_path = self.image_paths[idx]
        image = Image.open(img_path).convert('L')  # 转换为灰度图像
        label = self.labels[idx]

        if self.transform:
            image = self.transform(image)

        return image, label


# 2. 准备数据集
def prepare_datasets(pos_dir, neg_dir, test_size=0.2, random_state=42):
    # 收集文件路径和标签
    pos_files = [os.path.join(pos_dir, f) for f in os.listdir(pos_dir) if f.endswith('.png')]
    neg_files = [os.path.join(neg_dir, f) for f in os.listdir(neg_dir) if f.endswith('.png')]

    file_paths = pos_files + neg_files
    labels = [1] * len(pos_files) + [0] * len(neg_files)

    # 划分训练集和测试集
    train_files, test_files, train_labels, test_labels = train_test_split(
        file_paths, labels, test_size=test_size, random_state=random_state, stratify=labels
    )

    return train_files, test_files, train_labels, test_labels


# 3. 定义CNN模型
class SimpleCNN(nn.Module):
    def __init__(self):
        super(SimpleCNN, self).__init__()
        self.conv_layers = nn.Sequential(
            # 输入通道1（灰度图），输出通道32，3x3卷积核
            nn.Conv2d(1, 32, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(2, 2),  # 下采样

            nn.Conv2d(32, 64, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(2, 2),

            nn.Conv2d(64, 128, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(2, 2)
        )

        self.fc_layers = nn.Sequential(
            nn.Linear(128 * 32 * 32, 512),  # 根据输入尺寸调整（256x256经过3次池化后为32x32）
            nn.ReLU(),
            nn.Dropout(0.5),
            nn.Linear(512, 1),
            nn.Sigmoid()
        )

    def forward(self, x, return_features=False):
        x = x.to(device)
        features = self.conv_layers(x)
        features = features.view(features.size(0), -1)  # 展平
        # 添加一个适配层，将大维度降到512
        if not hasattr(self, 'feature_adapter'):
            self.feature_adapter = nn.Linear(features.shape[1], 2048).to(device)
        x = self.fc_layers(features)

        features = F.relu(self.feature_adapter(features))

        if return_features:
            return x, features
        return x


def calculate_metrics(y_true, y_pred):
    """计算评估指标"""
    accuracy = accuracy_score(y_true, y_pred)
    precision = precision_score(y_true, y_pred, zero_division=0)
    recall = recall_score(y_true, y_pred, zero_division=0)
    f1 = f1_score(y_true, y_pred, zero_division=0)
    return accuracy, precision, recall, f1


def evaluate(model, data_loader, device):
    """评估函数"""
    model.eval()
    all_preds = []
    all_labels = []
    running_loss = 0.0

    with torch.no_grad():
        for images, labels in data_loader:
            images = images.to(device)
            labels = labels.float().unsqueeze(1).to(device)

            outputs = model(images)
            loss = criterion(outputs, labels)

            running_loss += loss.item() * images.size(0)
            preds = (outputs > 0.5).float().cpu().numpy()

            all_preds.extend(preds.ravel())
            all_labels.extend(labels.cpu().numpy().ravel())

    # 计算各项指标
    loss = running_loss / len(data_loader.dataset)
    accuracy, precision, recall, f1 = calculate_metrics(all_labels, all_preds)

    return loss, accuracy, precision, recall, f1

# 4. 训练参数设置
BATCH_SIZE = 512
EPOCHS = 180
LEARNING_RATE = 0.0001

# 5. 数据预处理
transform = transforms.Compose([
    transforms.Resize((256, 256)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.5], std=[0.5])  # 灰度图单通道归一化
])
# 初始化模型、损失函数和优化器
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = SimpleCNN().to(device)
criterion = nn.BCELoss()
optimizer = optim.Adam(model.parameters(), lr=LEARNING_RATE)
def train_cnn_main():
    # 准备数据
    pos_dir = 'E:/Cross-Modality-Bug-Detection-main/dataset1/image/contract1/label_1'  # 正样本路径
    neg_dir = 'E:/Cross-Modality-Bug-Detection-main/dataset1/image/contract1/label_0'  # 修改为你的负样本路径
    train_files, test_files, train_labels, test_labels = prepare_datasets(pos_dir, neg_dir)
    print("数据集已划分好")
    # 创建数据集和数据加载器
    train_dataset = CustomDataset(train_files, train_labels, transform=transform)
    test_dataset = CustomDataset(test_files, test_labels, transform=transform)

    train_loader = DataLoader(train_dataset, batch_size=BATCH_SIZE, shuffle=True)
    test_loader = DataLoader(test_dataset, batch_size=BATCH_SIZE)
    print("数据集已加载")


    # 6. 训练循环
    best_f1 = 0.0
    print("开始训练")
    for epoch in range(EPOCHS):
        model.train()
        running_loss = 0.0

        # 训练阶段
        for images, labels in train_loader:
            images = images.to(device)
            labels = labels.float().unsqueeze(1).to(device)

            optimizer.zero_grad()
            outputs = model(images)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()

            running_loss += loss.item() * images.size(0)

        # 验证阶段
        train_loss = running_loss / len(train_loader.dataset)
        val_loss, val_acc, val_precision, val_recall, val_f1 = evaluate(model, test_loader, device)

        # 打印详细指标
        print(f"\nEpoch [{epoch + 1}/{EPOCHS}]")
        print(f"Train Loss: {train_loss:.4f}")
        print(f"Val Loss: {val_loss:.4f} | Accuracy: {val_acc:.4f}")
        print(f"Precision: {val_precision:.4f} | Recall: {val_recall:.4f} | F1: {val_f1:.4f}")

        # 根据F1分数保存最佳模型
        if val_f1 > best_f1:
            best_f1 = val_f1
            torch.save(model.state_dict(), 'E:\Cross-Modality-Bug-Detection-main\contract1_model\\best_cnn12_model.pth')
            print("=> 保存新的最佳模型")

    # 7. 最终测试阶段
    print("\n开始最终测试...")
    model.load_state_dict(torch.load('E:\Cross-Modality-Bug-Detection-main\contract1_model\\best_cnn12_model.pth'))
    test_loss, test_acc, test_precision, test_recall, test_f1 = evaluate(model, test_loader, device)

    print("\n最终测试结果:")
    print(f"Test Loss: {test_loss:.4f} | Accuracy: {test_acc:.4f}")
    print(f"Precision: {test_precision:.4f} | Recall: {test_recall:.4f} | F1: {test_f1:.4f}")

    print('训练全部完成')
if __name__ == "__main__":
    train_cnn_main()