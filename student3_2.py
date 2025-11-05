import os
import torch
import torch.nn as nn
import torch.nn.functional as F
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms
from PIL import Image
from transformers import BertModel, BertTokenizer
from torch_geometric.data import Data, Batch
from torch_geometric.nn import GCNConv, global_mean_pool
import numpy as np
from sklearn.model_selection import train_test_split
from tqdm import tqdm
import random
import re

from by_cfg_gnn import GNNModel, process_bytecode
from byte_im import SimpleCNN
from data_processing.map_cfg_to_embedding import filter_opcodes
from op_trans import OpcodeClassifier


# 在student3.py中添加注意力模块
class TeacherAttention(nn.Module):
    def __init__(self, feat_dims=[2048, 768, 128], hidden_dim=256):
        super().__init__()
        # 投影各教师特征到统一空间
        self.proj_cnn = nn.Sequential(
            nn.Linear(feat_dims[0], hidden_dim),
            nn.ReLU(),
            nn.LayerNorm(hidden_dim)
        )
        self.proj_trans = nn.Sequential(
            nn.Linear(feat_dims[1], hidden_dim),
            nn.ReLU(),
            nn.LayerNorm(hidden_dim)
        )
        self.proj_gnn = nn.Sequential(
            nn.Linear(feat_dims[2], hidden_dim),
            nn.ReLU(),
            nn.LayerNorm(hidden_dim))

        # 注意力计算网络
        self.attention_net = nn.Sequential(
            nn.Linear(hidden_dim * 3, hidden_dim),
            nn.ReLU(),
            nn.LayerNorm(hidden_dim),
            nn.Linear(hidden_dim, 3),
            nn.Softmax(dim=1)
        )

    def forward(self, cnn_feat, trans_feat, gnn_feat):
        # 统一特征维度
        proj_cnn = self.proj_cnn(cnn_feat)
        proj_trans = self.proj_trans(trans_feat)
        proj_gnn = self.proj_gnn(gnn_feat)

        # 拼接后计算权重
        combined = torch.cat([proj_cnn, proj_trans, proj_gnn], dim=1)
        weights = self.attention_net(combined)
        return weights


# 1. 定义学生网络模型（优化版）
class MultiModalStudent(nn.Module):
    def __init__(self, bert_path=None):
        super(MultiModalStudent, self).__init__()

        # 图像分支 (优化CNN结构)
        self.image_branch = nn.Sequential(
            nn.Conv2d(1, 16, kernel_size=3, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(),
            nn.MaxPool2d(2, 2),
            nn.Conv2d(16, 32, kernel_size=3, padding=1),
            nn.BatchNorm2d(32),
            nn.ReLU(),
            nn.MaxPool2d(2, 2),
            nn.Conv2d(32, 64, kernel_size=3, padding=1),
            nn.BatchNorm2d(64),
            nn.ReLU(),
            nn.AdaptiveAvgPool2d((4, 4)),
            nn.Flatten()
        )  # 输出维度: batch_size × (64*4*4) = 1024

        # 操作码分支 (优化Transformer结构)
        if bert_path:
            self.bert = BertModel.from_pretrained(bert_path)
            for param in self.bert.parameters():
                param.requires_grad = False
            self.bert_dim = 768
        else:
            self.bert = None
            self.bert_dim = 256  # 如果没有BERT，使用固定维度

        self.opcode_proj = nn.Sequential(
            nn.Linear(self.bert_dim, 128),
            nn.ReLU(),
            nn.LayerNorm(128),
            nn.Dropout(0.1)
        )

        self.opcode_transformer = nn.TransformerEncoder(
            nn.TransformerEncoderLayer(d_model=128, nhead=4, dim_feedforward=526),
            num_layers=2
        )  # 输出维度: batch_size × 256

        # CFG图分支 (优化GNN结构)
        self.gnn_layer1 = GCNConv(256, 64, heads=2, dropout=0.1)
        self.gnn_layer2 = GCNConv(64 * 2, 32, heads=1, dropout=0.1)
        self.gnn_norm = nn.LayerNorm(32)
        self.gnn_act = nn.LeakyReLU(0.2)  # 输出维度: batch_size × 64

        # 多模态融合 (优化融合策略)
        self.fusion = nn.Sequential(
            nn.Linear(1024+128+32, 512),  # 合并所有特征
            nn.ReLU(),
            nn.BatchNorm1d(512),
            nn.Dropout(0.2),
            nn.Linear(512, 256),
            nn.ReLU(),
            nn.Linear(256, 2)
        )

        self.teacher_attention = TeacherAttention(feat_dims=[2048, 768 , 128])
    def forward(self, image_input, opcode_input_ids, opcode_attention_mask, graph_data):
        # 图像处理
        image_feats = self.image_branch(image_input)  # [batch_size, 2048]

        # 操作码处理
        if self.bert:
            with torch.no_grad():
                bert_outputs = self.bert(
                    input_ids=opcode_input_ids,
                    attention_mask=opcode_attention_mask
                )
                opcode_feats = bert_outputs.last_hidden_state[:, 0, :]  # 使用[CLS] token
        else:
            opcode_feats = opcode_input_ids.float()

        opcode_feats = self.opcode_proj(opcode_feats)  # [batch_size, 256]
        opcode_feats = self.opcode_transformer(opcode_feats.unsqueeze(1)).squeeze(1)

        # 图处理
        x, edge_index, batch = graph_data.x, graph_data.edge_index, graph_data.batch
        x = F.dropout(x, p=0.2, training=self.training)
        x = self.gnn_layer1(x, edge_index)
        x = self.gnn_act(x)
        x = F.dropout(x, p=0.2, training=self.training)
        x = self.gnn_layer2(x, edge_index)
        x = self.gnn_norm(x)
        graph_feats = global_mean_pool(x, batch) if batch is not None else x.mean(dim=0, keepdim=True)
        #print(f"特征维度验证 - 图像: {image_feats.shape}, 操作码: {opcode_feats.shape}, 图: {graph_feats.shape}")
        # 特征融合 (确保维度匹配)
        combined = torch.cat([
            image_feats,
            opcode_feats,
            graph_feats
        ], dim=1)
        output = self.fusion(combined)

        return output, (image_feats, opcode_feats, graph_feats)


# 2. 知识蒸馏训练器（优化版）
class KDTrainer:
    def __init__(self, student, teachers, device='cuda'):
        self.student = student.to(device)
        self.teachers = {name: teacher.to(device) for name, teacher in teachers.items()}
        self.device = device

        for teacher in self.teachers.values():
            teacher.eval()
            for param in teacher.parameters():
                param.requires_grad = False

        # 定义各教师的处理方式
        self.teacher_handlers = {
            'cnn': lambda x, images: x['cnn'](images),
            'transformer': lambda x, ids, mask: x['transformer'](ids, mask),
            'gnn': lambda x, graph: x['gnn'](graph)
        }
        self.attention = TeacherAttention().to(device)
        self.attention.train()  # 确保可训练
        self.logger = {
            'train_loss': [],
            'val_acc': [],
            'ce_loss': [],
            'kd_loss': [],
            'weights': {'cnn': [], 'trans': [], 'gnn': []}
        }
    def compute_kd_loss(self, student_logits, teacher_logits, weights, T=3.0):
        """计算知识蒸馏损失"""
        stacked_logits = torch.stack(teacher_logits, dim=1)  # [batch, 3, 2]
        weighted_logits = (stacked_logits * weights.unsqueeze(2)).sum(dim=1)

        soft_targets = F.softmax(weighted_logits / T, dim=1)
        soft_outputs = F.log_softmax(student_logits / T, dim=1)
        return F.kl_div(soft_outputs, soft_targets, reduction='batchmean') * (T * T)

    def train_epoch(self, dataloader, optimizer, alpha=0.7, T=3.0):
        """训练一个epoch"""
        self.student.train()
        self.attention.train()  # 确保注意力模块处于训练模式
        total_loss = 0.0
        total_ce = 0.0
        total_kd = 0.0
        criterion_ce = nn.CrossEntropyLoss()

        for batch in tqdm(dataloader, desc="Training"):
            # 数据移动到设备
            images = batch['image'].to(self.device)
            opcode_ids = batch['opcode_ids'].to(self.device)
            opcode_mask = batch['opcode_mask'].to(self.device)
            graph_data = batch['graph_data'].to(self.device)
            labels = batch['labels'].to(self.device)

            optimizer.zero_grad()

            # 学生预测
            student_logits, student_feats = self.student(images, opcode_ids, opcode_mask, graph_data)

            with torch.no_grad():
                teacher_logits = []
                teacher_feats = []

                # CNN教师
                if 'cnn' in self.teachers:
                    cnn_logits, cnn_feat = self.teachers['cnn'](images, return_features=True)
                    cnn_probs = torch.cat([1 - cnn_logits.sigmoid(), cnn_logits.sigmoid()], dim=1)
                    teacher_logits.append(torch.log(cnn_probs + 1e-10))
                    teacher_feats.append(cnn_feat)

                # Transformer教师
                if 'transformer' in self.teachers:
                    trans_logits, trans_feat = self.teachers['transformer'](
                        opcode_ids, opcode_mask, return_features=True)
                    teacher_logits.append(trans_logits)
                    teacher_feats.append(trans_feat)

                # GNN教师
                if 'gnn' in self.teachers:
                    gnn_logits, gnn_feat = self.teachers['gnn'](graph_data, return_features=True)
                    teacher_logits.append(gnn_logits)
                    teacher_feats.append(gnn_feat)

            # 计算动态权重 根据各教师输出的中间特征 来动态计算各教师的权重
            weights = self.attention(*teacher_feats)

            # 计算损失
            #计算交叉熵损失
            loss_ce = criterion_ce(student_logits, labels)
            loss_kd = self.compute_kd_loss(student_logits, teacher_logits, weights, T)
            loss = alpha * loss_ce + (1 - alpha) * loss_kd

            # 记录批次的损失和权重
            total_ce += loss_ce.item()
            total_kd += loss_kd.item()
            total_loss += loss.item()

            # 记录权重分布
            with torch.no_grad():
                mean_weights = weights.mean(dim=0)
                self.logger['weights']['cnn'].append(mean_weights[0].item())
                self.logger['weights']['trans'].append(mean_weights[1].item())
                self.logger['weights']['gnn'].append(mean_weights[2].item())

            loss.backward()
            optimizer.step()
            total_loss += loss.item()
        # 记录epoch统计
        self.logger['train_loss'].append(total_loss / len(dataloader))
        self.logger['ce_loss'].append(total_ce / len(dataloader))
        self.logger['kd_loss'].append(total_kd / len(dataloader))
        return total_loss / len(dataloader)

    def log_epoch_stats(self, epoch, train_loader):
        """打印和保存详细的epoch统计信息"""
        stats = {
            'epoch': epoch,
            'train_loss': self.logger['train_loss'][-1],
            'ce_loss': self.logger['ce_loss'][-1],
            'kd_loss': self.logger['kd_loss'][-1],
            'weights': {
                'cnn': np.mean(self.logger['weights']['cnn'][-len(train_loader):]),
                'trans': np.mean(self.logger['weights']['trans'][-len(train_loader):]),
                'gnn': np.mean(self.logger['weights']['gnn'][-len(train_loader):])
            }
        }

        print(f"\nEpoch {epoch} Detailed Stats:")
        print(f"  Total Loss: {stats['train_loss']:.4f}")
        print(f"  CE Loss: {stats['ce_loss']:.4f} | KD Loss: {stats['kd_loss']:.4f}")
        print(f"  Teacher Weights - CNN: {stats['weights']['cnn']:.3f} "
              f"Transformer: {stats['weights']['trans']:.3f} "
              f"GNN: {stats['weights']['gnn']:.3f}")

        return stats

    def evaluate(self, dataloader):
        """评估模型"""
        self.student.eval()
        correct = 0
        total = 0
        all_preds = []
        all_labels = []
        with torch.no_grad():
            for batch in tqdm(dataloader, desc="Evaluating"):
                images = batch['image'].to(self.device)
                opcode_ids = batch['opcode_ids'].to(self.device)
                opcode_mask = batch['opcode_mask'].to(self.device)
                graph_data = batch['graph_data'].to(self.device)
                labels = batch['labels'].to(self.device)

                outputs,_ = self.student(images, opcode_ids, opcode_mask, graph_data)
                _, predicted = torch.max(outputs.data, 1)
                all_preds.extend(predicted.cpu().numpy())
                all_labels.extend(labels.cpu().numpy())

        # 计算指标
        accuracy = accuracy_score(all_labels, all_preds)
        precision = precision_score(all_labels, all_preds)
        recall = recall_score(all_labels, all_preds)
        f1 = f1_score(all_labels, all_preds)

        return {
            'accuracy': accuracy,
            'precision': precision,
            'recall': recall,
            'f1': f1
        }


# 3. 多模态数据集类（完整实现）
class MultiModalDataset(Dataset):
    def __init__(self, root_dir, max_seq_length=100, image_size=256):
        """
        多模态数据集类

        参数:
            root_dir: 数据集根目录，包含:
                - bytecode/ (GNN数据)
                - image/ (CNN数据)
                - opcode/ (Transformer数据)
            max_seq_length: 操作码序列最大长度
            image_size: 图像尺寸
        """
        self.root_dir = root_dir
        self.max_seq_length = max_seq_length
        self.image_transform = transforms.Compose([
            transforms.Resize((image_size, image_size)),
            transforms.Grayscale(),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.5], std=[0.5])
        ])

        # 收集样本ID并确保三种数据源对齐
        self.samples = self._collect_samples()

        # 初始化tokenizer
        self.tokenizer = BertTokenizer.from_pretrained('D:/bert-base-uncased')

        print(f"成功加载 {len(self.samples)} 个多模态样本")

    def _collect_samples(self):
        """收集三种数据源共有的样本"""
        samples = []

        # 定义数据目录结构
        data_dirs = {
            'vulnerable': {
                'bytecode': os.path.join(self.root_dir, 'bytecode', 'timestamp_pecu'),
                'image': os.path.join(self.root_dir, 'image', 'timestamp_pecu'),
                'opcode': os.path.join(self.root_dir, 'opcode', 'timestamp_pecu')
            },
            'normal': {
                'bytecode': os.path.join(self.root_dir, 'bytecode', 'contract_normal_hex'),
                'image': os.path.join(self.root_dir, 'image', 'contract_normal_hex'),
                'opcode': os.path.join(self.root_dir, 'opcode', 'contract_normal_hex')
            }
        }

        # 处理漏洞合约 (label=1)
        vuln_bytecodes = set(
            f.replace('.txt', '') for f in os.listdir(data_dirs['vulnerable']['bytecode']) if f.endswith('.txt'))
        vuln_images = set(
            f.replace('.png', '') for f in os.listdir(data_dirs['vulnerable']['image']) if f.endswith('.png'))
        vuln_opcodes = set(
            f.replace('.txt', '') for f in os.listdir(data_dirs['vulnerable']['opcode']) if f.endswith('.txt'))

        common_vuln = vuln_bytecodes & vuln_images & vuln_opcodes
        samples.extend([(sid, 'vulnerable', 1) for sid in common_vuln])

        # 处理正常合约 (label=0)
        norm_bytecodes = set(
            f.replace('.txt', '') for f in os.listdir(data_dirs['normal']['bytecode']) if f.endswith('.txt'))
        norm_images = set(f.replace('.png', '') for f in os.listdir(data_dirs['normal']['image']) if f.endswith('.png'))
        norm_opcodes = set(
            f.replace('.txt', '') for f in os.listdir(data_dirs['normal']['opcode']) if f.endswith('.txt'))

        common_norm = norm_bytecodes & norm_images & norm_opcodes
        samples.extend([(sid, 'normal', 0) for sid in common_norm])

        # 转换为字典列表
        return [{
            'id': sid,
            'category': cat,
            'label': label
        } for sid, cat, label in samples]

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        sample = self.samples[idx]

        # 1. 加载图像数据
        image_path = os.path.join(
            self.root_dir,
            'image',
            'timestamp_pecu' if sample['label'] == 1 else 'contract_normal_hex',
            f"{sample['id']}.png"
        )
        image = Image.open(image_path).convert('L')  # 转换为灰度图
        image = self.image_transform(image)

        # 2. 加载操作码数据
        opcode_path = os.path.join(
            self.root_dir,
            'opcode',
            'timestamp_pecu' if sample['label'] == 1 else 'contract_normal_hex',
            f"{sample['id']}.txt" if sample['label'] == 1 else f"{sample['id']}.txt"
        )
        with open(opcode_path, 'r', encoding='utf-8') as f:
            sequence = f.read()
            sequences = filter_opcodes(sequence)
            opcode_sequence = [line.strip() for line in sequences if line.strip()]
        opcode_sequence=filter_opcodes(opcode_sequence)
        opcode_input = self.tokenizer(
            opcode_sequence,
            padding='max_length',
            max_length=self.max_seq_length,
            truncation=True,
            return_tensors='pt',
            is_split_into_words=True
        )

        # 3. 加载字节码生成CFG图
        bytecode_path = os.path.join(
            self.root_dir,
            'bytecode',
            'timestamp_pecu' if sample['label'] == 1 else 'contract_normal_hex',
            f"{sample['id']}.txt" if sample['label'] == 1 else f"{sample['id']}.txt"
        )
        with open(bytecode_path, 'r', encoding='utf-8') as f:
            bytecode = f.read().strip()

        try:
            graph_data = process_bytecode(bytecode, sample['label'])
            if graph_data is None:
                raise ValueError("process_bytecode返回None")
        except Exception as e:
            print(f"处理字节码失败: {bytecode_path}, 错误: {str(e)}")
            # 返回一个空图作为占位符
            graph_data = Data(
                x=torch.randn(1, 256),  # 假设特征维度为256
                edge_index=torch.zeros((2, 1), dtype=torch.long),
                y=sample['label']
            )

        return {
            'image': image,
            'opcode_ids': opcode_input['input_ids'].squeeze(0),
            'opcode_mask': opcode_input['attention_mask'].squeeze(0),
            'graph_data': graph_data,
            'labels': torch.tensor(sample['label'], dtype=torch.long)
        }


def collate_fn(batch):
    """自定义批处理函数"""
    # 过滤无效样本
    valid_batch = [item for item in batch if item is not None]

    images = torch.stack([item['image'] for item in valid_batch])
    opcode_ids = torch.stack([item['opcode_ids'] for item in valid_batch])
    opcode_mask = torch.stack([item['opcode_mask'] for item in valid_batch])
    labels = torch.stack([item['labels'] for item in valid_batch])

    # 处理图数据
    graph_data = Batch.from_data_list([item['graph_data'] for item in valid_batch])

    return {
        'image': images,
        'opcode_ids': opcode_ids,
        'opcode_mask': opcode_mask,
        'graph_data': graph_data,
        'labels': labels
    }


# 4. 主函数（优化版）
def student_main():
    # 配置参数
    config = {
        'dataset_root': 'D:/Cross-Modality-Bug-Detection-main/dataset1',
        'bert_path': 'D:/bert-base-uncased',
        'batch_size': 64,
        'num_epochs': 30,
        'learning_rate': 1e-5,
        'alpha': 0.7,  # hard target权重
        'T': 3.0,  # 温度参数
        'device': 'cuda' if torch.cuda.is_available() else 'cpu',
        'test_size': 0.2,
        'val_size': 0.25,
        'random_state': 42,
        'max_seq_length': 100,
        'image_size': 256
    }

    print(f"Using device: {config['device']}")

    # 1. 准备数据集
    print("Loading dataset...")
    full_dataset = MultiModalDataset(
        root_dir=config['dataset_root'],
        max_seq_length=config['max_seq_length'],
        image_size=config['image_size']
    )

    # 数据集统计
    num_vuln = sum(1 for s in full_dataset.samples if s['label'] == 1)
    num_normal = len(full_dataset) - num_vuln
    print(f"数据集统计: 总样本={len(full_dataset)}, 漏洞合约={num_vuln}, 正常合约={num_normal}")

    # 划分训练测试集
    train_val_idx, test_idx = train_test_split(
        range(len(full_dataset)),
        test_size=config['test_size'],
        random_state=config['random_state'],
        stratify=[s['label'] for s in full_dataset.samples]
    )
    train_idx, val_idx = train_test_split(
        train_val_idx,
        test_size=config['val_size'],
        random_state=config['random_state'],
        stratify=[full_dataset.samples[i]['label'] for i in train_val_idx]
    )
    train_dataset = torch.utils.data.Subset(full_dataset, train_idx)
    val_dataset = torch.utils.data.Subset(full_dataset, val_idx)
    test_dataset = torch.utils.data.Subset(full_dataset, test_idx)

    train_loader = DataLoader(
        train_dataset,
        batch_size=config['batch_size'],
        shuffle=True,
        collate_fn=collate_fn,
        num_workers=4,
        pin_memory=True,
        drop_last=True
    )
    val_loader = DataLoader(
        val_dataset,
        batch_size=config['batch_size'],
        shuffle=False,
        collate_fn=collate_fn,
        num_workers=4,
        pin_memory=True,
        drop_last=True
    )
    test_loader = DataLoader(
        test_dataset,
        batch_size=config['batch_size'],
        shuffle=False,
        collate_fn=collate_fn,
        num_workers=4,
        pin_memory=True,
        drop_last=True
    )

    # 2. 初始化模型
    print("Initializing models...")

    # 加载教师模型
    teachers = {}

    # CNN教师
    cnn_teacher = SimpleCNN()
    cnn_teacher.load_state_dict(torch.load('D:/Cross-Modality-Bug-Detection-main/method2/best_cnn_model.pth'),strict=False)
    teachers['cnn'] = cnn_teacher.to(config['device'])

    # Transformer教师
    trans_teacher = OpcodeClassifier(
        bert_path=config['bert_path'],
        d_model=768,
        nhead=8,
        num_layers=4,
        num_classes=2,
        dropout=0.2
    )
    trans_teacher.load_state_dict(torch.load('D:/Cross-Modality-Bug-Detection-main/method2/best_trans_model.pth'))
    teachers['transformer'] = trans_teacher.to(config['device'])

    # GNN教师
    gnn_teacher = GNNModel(input_dim=256, hidden_dim=128, output_dim=2, model_type='gcn')
    gnn_teacher.load_state_dict(torch.load('D:/Cross-Modality-Bug-Detection-main/method2/best_gnn_model.pth'))
    teachers['gnn'] = gnn_teacher.to(config['device'])

    # 初始化学生模型
    student = MultiModalStudent(bert_path=config['bert_path']).to(config['device'])
    trainer = KDTrainer(student, teachers, config['device'])
    # 3. 训练配置
    optimizer = torch.optim.AdamW(
        list(student.parameters()) + list(trainer.attention.parameters()),  # 同时优化学生和注意力模块
        lr=config['learning_rate'],
        weight_decay=1e-5
    )
    scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(
        optimizer, mode='max', factor=0.5, patience=3
    )

    # 初始化时添加注意力可视化
    def plot_weights(weights, epoch):
        avg_weights = weights.mean(dim=0).cpu().numpy()
        print(f"Epoch {epoch} Teacher Weights - CNN: {avg_weights[0]:.3f}, "
              f"Transformer: {avg_weights[1]:.3f}, GNN: {avg_weights[2]:.3f}")
    # 4. 训练循环
    print("Starting training...")
    best_val_acc = 0.0
    patience=5
    patience_counter = 0
    # 添加CSV日志记录
    import csv
    log_file = open('training_time1_log.csv', 'w', newline='')
    log_writer = csv.writer(log_file)
    log_writer.writerow(['Epoch', 'Train_Loss', 'CE_Loss', 'KD_Loss',
                         'CNN_Weight', 'Trans_Weight', 'GNN_Weight',
                         'Val_Acc', 'Best_Val_Acc', 'Learning_Rate'])

    for epoch in range(config['num_epochs']):
        train_loss = trainer.train_epoch(
            train_loader,
            optimizer,
            alpha=config['alpha'],
            T=config['T']
        )
        #train_acc = trainer.evaluate(train_loader)
        val_metrics = trainer.evaluate(val_loader) #使用验证集评估

        # 记录详细统计
        epoch_stats = trainer.log_epoch_stats(epoch + 1,train_loader)

        # 调整学习率
        scheduler.step(val_metrics['accuracy'])

        # 保存最佳模型
        if val_metrics['accuracy']> best_val_acc:
            best_val_acc = val_metrics['accuracy']
            torch.save(student.state_dict(), 'D:/Cross-Modality-Bug-Detection-main/method2/best_student_model.pth')
            print(f"保存最佳模型，测试准确率: {best_val_acc:.4f}")
            patience_counter = 0
        else:
            patience_counter += 1
        print(f"Epoch {epoch + 1}/{config['num_epochs']}:")
        print(f"  训练损失: {train_loss:.4f}")
        print(f"  验证集指标 - 准确率: {val_metrics['accuracy']:.4f}, 精确率: {val_metrics['precision']:.4f}, "
              f"召回率: {val_metrics['recall']:.4f}, F1: {val_metrics['f1']:.4f}")
        print(f"  最佳测试准确率: {best_val_acc:.4f}")
        print(f"  当前学习率: {optimizer.param_groups[0]['lr']:.2e}")
        # 写入CSV日志
        log_writer.writerow([
            epoch + 1,
            epoch_stats['train_loss'],
            epoch_stats['ce_loss'],
            epoch_stats['kd_loss'],
            epoch_stats['weights']['cnn'],
            epoch_stats['weights']['trans'],
            epoch_stats['weights']['gnn'],
            val_metrics['accuracy'],
            val_metrics['precision'],
            val_metrics['recall'],
            val_metrics['f1'],
            best_val_acc,
            optimizer.param_groups[0]['lr']
        ])
        log_file.flush()

        # 早停检查
        if patience_counter >= patience:
            print(f"\n早停触发！连续 {patience} 个epoch验证准确率未提升。")
            break

        # 在student_main()函数中修改权重可视化部分
        if epoch % 5 == 0 and epoch != 0:
            with torch.no_grad():
                sample = next(iter(test_loader))
                images = sample['image'].to(config['device'])
                opcode_ids = sample['opcode_ids'].to(config['device'])
                opcode_mask = sample['opcode_mask'].to(config['device'])
                graph_data = sample['graph_data'].to(config['device'])

                # 获取教师特征而非学生特征
                teacher_feats = []
                if 'cnn' in trainer.teachers:
                    _, cnn_feat = trainer.teachers['cnn'](images, return_features=True)
                    teacher_feats.append(cnn_feat)
                if 'transformer' in trainer.teachers:
                    _, trans_feat = trainer.teachers['transformer'](
                        opcode_ids, opcode_mask, return_features=True)
                    teacher_feats.append(trans_feat)
                if 'gnn' in trainer.teachers:
                    _, gnn_feat = trainer.teachers['gnn'](graph_data, return_features=True)
                    teacher_feats.append(gnn_feat)

                weights = trainer.attention(*teacher_feats)
                plot_weights(weights, epoch)
    log_file.close()
    print("\n训练完成!")
    # 5. 最终测试评估（新增）
    print("\n训练完成! 在测试集上进行最终评估...")
    best_model = MultiModalStudent(bert_path=config['bert_path']).to(config['device'])
    best_model.load_state_dict(torch.load('D:/Cross-Modality-Bug-Detection-main/method2/best_student_model.pth'))
    trainer.student = best_model
    test_metrics= trainer.evaluate(test_loader)
    print(f"测试集指标 - 准确率: {test_metrics['accuracy']:.4f}, 精确率: {test_metrics['precision']:.4f}, "
          f"召回率: {test_metrics['recall']:.4f}, F1: {test_metrics['f1']:.4f}")


if __name__ == "__main__":
    student_main()