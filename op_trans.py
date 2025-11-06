import os
import numpy as np
import torch
from torch import nn
from torch.utils.data import Dataset, DataLoader, random_split
from transformers import BertTokenizer, BertModel
from collections import Counter
from sklearn.metrics import classification_report, accuracy_score, precision_score, recall_score, f1_score
from data_processing.map_cfg_to_embedding import filter_opcodes

# 1. 数据预处理部分
def load_opcode_sequences_with_labels(vuln_folder, normal_folder):
    """
    从两个文件夹加载操作码序列并添加标签
    vuln_folder: 漏洞合约文件夹路径
    normal_folder: 正常合约文件夹路径
    返回: (序列列表, 标签列表)
    """
    sequences = []
    labels = []

    # 加载漏洞合约 (标签1)
    for filename in os.listdir(vuln_folder):
        if filename.endswith('.txt'):
            with open(os.path.join(vuln_folder, filename), 'r', encoding='utf-8') as f:
                sequence = f.read()
                sequence = filter_opcodes(sequence)
                sequence1 = [line.strip() for line in sequence if line.strip()]
                if sequence1:
                    sequences.append(sequence1)
                    labels.append(1)  # 漏洞标签为1

    # 加载正常合约 (标签0)
    for filename in os.listdir(normal_folder):
        if filename.endswith('.txt'):
            with open(os.path.join(normal_folder, filename), 'r', encoding='utf-8') as f:
                sequence = f.read()
                sequence = filter_opcodes(sequence)
                sequence2 = [line.strip() for line in sequence if line.strip()]
                if sequence2:
                    sequences.append(sequence2)
                    labels.append(0)  # 正常标签为0

    return sequences, labels


# 2. 定义模型组件
class PositionalEncoding(nn.Module):
    def __init__(self, d_model, max_len=5000):
        super(PositionalEncoding, self).__init__()
        pe = torch.zeros(max_len, d_model) #初始化一个形状为（max_len,d_model）的零向量pe
        position = torch.arange(0, max_len, dtype=torch.float).unsqueeze(1) #生成位置向量 position=[0,1,2,…,Lmax-1]的转置
        div_term = torch.exp(torch.arange(0, d_model, 2).float() * (-np.log(10000.0) / d_model))  #torch.arrange(0,d_model,2)的意思是每隔两个数 ＋1，
        pe[:, 0::2] = torch.sin(position * div_term)  #偶数列
        pe[:, 1::2] = torch.cos(position * div_term)  #奇数列
        pe = pe.unsqueeze(0)
        self.register_buffer('pe', pe)

    def forward(self, x):
        return x + self.pe[:, :x.size(1), :]  #返回的是 X+PE   即输入特征向量+位置嵌入向量


class BERTEmbedding(nn.Module):
    def __init__(self, bert_path):
        super(BERTEmbedding, self).__init__()
        self.tokenizer = BertTokenizer.from_pretrained(bert_path)
        self.bert = BertModel.from_pretrained(bert_path)
        for param in self.bert.parameters():
            param.requires_grad = False  # 默认冻结
        for layer in self.bert.encoder.layer[-2:]:  # 解冻最后两层
            for param in layer.parameters():
                param.requires_grad = True

    def forward(self, input_ids, attention_mask):
        with torch.no_grad():
            outputs = self.bert(input_ids=input_ids, attention_mask=attention_mask)
        return outputs.last_hidden_state


class OpcodeDataset(Dataset):
    def __init__(self, sequences, labels, max_seq_length, bert_tokenizer):
        self.sequences = sequences
        self.labels = labels
        self.max_seq_length = max_seq_length
        self.bert_tokenizer = bert_tokenizer

    def __len__(self):
        return len(self.sequences)

    def __getitem__(self, idx):
        sequence = self.sequences[idx]
        encoded = self.bert_tokenizer(
            sequence,
            padding='max_length',
            max_length=self.max_seq_length,
            truncation=True,
            return_tensors='pt',
            is_split_into_words=True
        )
        return {
            'input_ids': encoded['input_ids'].squeeze(0),
            'attention_mask': encoded['attention_mask'].squeeze(0),
            'label': torch.tensor(self.labels[idx], dtype=torch.long)
        }


class OpcodeClassifier(nn.Module):
    def __init__(self, bert_path, d_model, nhead, num_layers, num_classes=2, dropout=0.1):
        super(OpcodeClassifier, self).__init__()
        self.d_model = d_model  #输入数据的维度
        self.bert_embedding = BERTEmbedding(bert_path)  #词嵌入层
        self.pos_encoder = PositionalEncoding(d_model)  #位置嵌入层

        encoder_layer = nn.TransformerEncoderLayer(   #编码器层
            d_model=d_model,  #输入数据维度
            nhead=nhead,   #头数
            dropout=dropout,
            batch_first=True
        )
        self.transformer_encoder = nn.TransformerEncoder(encoder_layer, num_layers=num_layers)  #编码器层数
        self.classifier1 = nn.Sequential(
            nn.Linear(d_model, d_model // 2),  # 降维至一半
            nn.ReLU(),  # 保持非线性
            nn.Dropout(dropout),  # 防止过拟合
            nn.Linear(d_model // 2, num_classes)  # 最终分类
        )
        # 改进2: 更复杂的分类头
        self.classifier = nn.Sequential(
            nn.Linear(d_model, d_model),
            nn.BatchNorm1d(d_model),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(d_model, d_model//2),
            nn.BatchNorm1d(d_model//2),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(d_model//2, num_classes)
        )
        # 改进3: 初始化权重
        self._init_weights()

    def _init_weights(self):
        for p in self.parameters():
            if p.dim() > 1:
                nn.init.xavier_uniform_(p)
    def forward(self, input_ids, attention_mask, return_features=False):
        bert_embeddings = self.bert_embedding(input_ids, attention_mask)
        embeddings = self.pos_encoder(bert_embeddings)
        key_padding_mask = (attention_mask == 0)

        # 获取序列的全局表示 (使用[CLS]标记或平均池化)
        transformer_output = self.transformer_encoder(
            src=embeddings,
            src_key_padding_mask=key_padding_mask
        )

        # 使用平均池化获取序列整体表示
        sequence_rep = transformer_output.mean(dim=1)

        # 分类
        logits = self.classifier1(sequence_rep)
        #print(sequence_rep.shape)
        if return_features:
            return logits, sequence_rep
        return logits


# 3. 训练和评估函数
def train_epoch(model, dataloader, criterion, optimizer, device):
    model.train()
    total_loss = 0
    correct = 0
    total = 0

    for batch in dataloader:
        input_ids = batch['input_ids'].to(device)
        attention_mask = batch['attention_mask'].to(device)
        labels = batch['label'].to(device)

        optimizer.zero_grad()
        outputs = model(input_ids, attention_mask)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()

        total_loss += loss.item()
        _, predicted = torch.max(outputs.data, 1)
        total += labels.size(0)
        correct += (predicted == labels).sum().item()

    return total_loss / len(dataloader), correct / total


def evaluate(model, dataloader, criterion, device):
    model.eval()
    total_loss = 0
    correct = 0
    total = 0
    all_labels = []
    all_preds = []

    with torch.no_grad():
        for batch in dataloader:
            input_ids = batch['input_ids'].to(device)
            attention_mask = batch['attention_mask'].to(device)
            labels = batch['label'].to(device)

            outputs = model(input_ids, attention_mask)
            loss = criterion(outputs, labels)

            total_loss += loss.item()
            _, predicted = torch.max(outputs.data, 1)
            total += labels.size(0)
            correct += (predicted == labels).sum().item()

            all_labels.extend(labels.cpu().numpy())
            all_preds.extend(predicted.cpu().numpy())

    # 计算各项指标
    accuracy = accuracy_score(all_labels, all_preds)
    precision = precision_score(all_labels, all_preds, average='binary')  # 二分类问题
    recall = recall_score(all_labels, all_preds, average='binary')
    f1 = f1_score(all_labels, all_preds, average='binary')

    report = classification_report(all_labels, all_preds, target_names=['Normal', 'Vulnerable'])

    metrics = {
        'loss': total_loss / len(dataloader),
        'accuracy': accuracy,
        'precision': precision,
        'recall': recall,
        'f1': f1,
        'report': report
    }
    return total_loss / len(dataloader), metrics


# 4. 主函数
def train_trans_main():
    # 配置参数
    config = {
        'vuln_folder': 'E:\Cross-Modality-Bug-Detection-main\dataset1\\opcode\\undependency_reen',  # 漏洞合约文件夹
        'normal_folder': 'E:\Cross-Modality-Bug-Detection-main\dataset1\\opcode\dependency_reen',  # 正常合约文件夹
        'bert_path': 'D:\\bert-base-uncased',  # 本地BERT模型路径
        'max_seq_length': 1024,  # 根据你的数据调整
        'batch_size': 64,
        'embedding_dim': 768,
        'num_heads': 4,
        'num_layers': 2,
        'dropout': 0.2,
        'learning_rate': 1e-4,
        'num_epochs': 100,
        'device': 'cuda' if torch.cuda.is_available() else 'cpu'
    }

    print(f"Using device: {config['device']}")

    # 1. 加载和预处理数据
    sequences, labels = load_opcode_sequences_with_labels(
        config['vuln_folder'],
        config['normal_folder']
    )

    print(f"Loaded {len(sequences)} samples ({sum(labels)} vulnerable, {len(labels) - sum(labels)} normal)")

    # 初始化BERT tokenizer
    bert_tokenizer = BertTokenizer.from_pretrained(config['bert_path'])

    # 创建数据集
    dataset = OpcodeDataset(
        sequences=sequences,
        labels=labels,
        max_seq_length=config['max_seq_length'],
        bert_tokenizer=bert_tokenizer
    )

    # 分割数据集 (80%训练, 10%验证, 10%测试)
    train_size = int(0.8 * len(dataset))
    val_size = int(0.1 * len(dataset))
    test_size = len(dataset) - train_size - val_size

    train_dataset, val_dataset, test_dataset = random_split(
        dataset,
        [train_size, val_size, test_size],
        generator=torch.Generator().manual_seed(42)  # 固定随机种子确保可重复性
    )
    print("已经划分好数据集")

    train_loader = DataLoader(
        train_dataset,
        batch_size=config['batch_size'],
        shuffle=True
    )

    val_loader = DataLoader(
        val_dataset,
        batch_size=config['batch_size'],
        shuffle=False
    )

    test_loader = DataLoader(
        test_dataset,
        batch_size=config['batch_size'],
        shuffle=False
    )

    # 2. 初始化模型
    model = OpcodeClassifier(
        bert_path=config['bert_path'],
        d_model=config['embedding_dim'],
        nhead=config['num_heads'],
        num_layers=config['num_layers'],
        num_classes=2,
        dropout=config['dropout']
    ).to(config['device'])

    # 3. 训练准备
    criterion = nn.CrossEntropyLoss()
    optimizer = torch.optim.AdamW(model.parameters(), lr=config['learning_rate'])
    scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(optimizer, mode='max', factor=0.5, patience=2)

    # 4. 训练循环
    print("Starting training...")
    best_val_accuracy = 0

    #  添加早停机制
    #patience = 3
    best_val_loss = float('inf')
    epochs_no_improve = 0

    for epoch in range(config['num_epochs']):
        train_loss, train_acc = train_epoch(model, train_loader, criterion, optimizer, config['device'])
        val_loss, val= evaluate(model, val_loader, criterion, config['device'])
        scheduler.step(val["accuracy"])

        print(f"\nEpoch {epoch + 1}/{config['num_epochs']}")
        print(f"Train Loss: {train_loss:.4f} | Train Acc: {train_acc:.4f}")
        print(f"Val Loss: {val_loss:.4f} | Val Acc: {val['accuracy']:.4f} ,Val Pre : {val['precision']:.4f} , Val Rec : {val['recall']:.4f}, Val F1 : {val['f1']:.4f}")

        # 保存最佳模型
        if val["accuracy"] > best_val_accuracy:
            best_val_accuracy = val["accuracy"]
            torch.save(model.state_dict(), 'E:/Cross-Modality-Bug-Detection-main/dataset4_model/reen/best_trans_model.pth')
            print("Saved new best model")
        # 早停检查
        #if val_loss < best_val_loss:
        #    best_val_loss = val_loss
        #    epochs_no_improve = 0
        #else:
        #    epochs_no_improve += 1
        #    if epochs_no_improve >= patience:
        #        print(f"Early stopping at epoch {epoch}")
        #        break
    # 5. 在测试集上评估最佳模型
    print("\nEvaluating on test set...")
    model.load_state_dict(torch.load('E:/Cross-Modality-Bug-Detection-main/dataset4_model/reen/best_trans_model.pth'))
    test_loss, test = evaluate(model, test_loader, criterion, config['device'])

    print(f"\nTest Loss: {test_loss:.4f} | Test Acc: {test['accuracy']:.4f},Test Pre:{test['precision']:.4f},Test Rec:{test['recall']:.4f},Test F1:{test['f1']:.4f}")
    print("\nClassification Report:")


if __name__ == "__main__":
    train_trans_main()