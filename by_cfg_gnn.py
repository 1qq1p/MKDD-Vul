import os
import numpy as np
import re
import torch
import torch.nn as nn
import torch.nn.functional as F
from gensim.models import Word2Vec
from nltk import word_tokenize
from evm_cfg_builder.cfg import CFG
from sklearn.metrics import precision_score, recall_score, f1_score
from torch_geometric.data import Data
from torch_geometric.loader import DataLoader
from torch_geometric.nn import GCNConv, global_mean_pool
from sklearn.model_selection import train_test_split
from tqdm import tqdm

# 加载预训练的Word2Vec模型
word2vec_model = Word2Vec.load("E:\Cross-Modality-Bug-Detection-main\w2vec\word2vec_opcode_16.bin")


def filter_opcodes(opcode_sequence):
    # 过滤掉地址类信息，返回一个字符串
    #opcode_sequence = re.sub(r'0x[0-9a-fA-F]+', '', opcode_sequence)
    if isinstance(opcode_sequence, list):
        # 如果是列表，对每个元素进行处理
        opcode_sequence = [re.sub(r'0x[0-9a-fA-F]+', '', str(op)) for op in opcode_sequence]
    else:
        # 如果不是列表，直接处理
        opcode_sequence = re.sub(r'0x[0-9a-fA-F]+', '', str(opcode_sequence))
    opcode_sequence = re.sub(r'(PUSH|DUP|SWAP|LOG)\d+', r'\1', opcode_sequence)
    tokens = [token.strip() for token in opcode_sequence.split() if token.isalpha()]
    return " ".join(tokens)


def map_opcode_to_embedding(opcode_sequence):
    tokens = word_tokenize(opcode_sequence)
    opcode_sequence = [token.upper() for token in tokens if token.isalnum()]
    embedding_sequence = [word2vec_model.wv[token] for token in opcode_sequence]
    average_embedding = np.mean(embedding_sequence, axis=0)
    max_embedding = np.max(embedding_sequence, axis=0)
    sum_embedding = np.sum(embedding_sequence, axis=0)
    final_embedding = np.concatenate([average_embedding, max_embedding, sum_embedding])
    norm = np.linalg.norm(final_embedding)
    if norm > 0:
        final_embedding = final_embedding / norm
    final_embedding = np.resize(final_embedding, (256))
    final_embedding = np.round(final_embedding, 4)
    return final_embedding

def process_block(block):
    block_opcode = [info[0] for info in block['info']]
    #block_opcode=filter_opcodes(block_opcode)
    block_embedding = map_opcode_to_embedding('\n'.join(block_opcode))
    return block_embedding


def process_bytecode(bytecode,label=None):
    if bytecode.startswith("0x"):
        bytecode = bytecode[2:]
    bytecode = bytecode.strip().replace(" ", "").replace("\n", "")

    cfg = CFG(bytecode)
    sorted_data_mapping = {
        str(block): {
            'pos': block.start.pc,
            'info': [(instr.mnemonic, instr.description) for instr in block.instructions],
            'out': [str(out_block) for out_block in block.all_outgoing_basic_blocks],
        }
        for block in cfg.basic_blocks
    }
    sorted_keys = sorted(sorted_data_mapping.keys(), key=lambda key: sorted_data_mapping[key]['pos'])

    # 生成块到连续索引的映射
    block_index_mapping = {key: idx for idx, key in enumerate(sorted_keys)}  # 新增

    graph_embedding = [process_block(sorted_data_mapping[key]) for key in sorted_keys]
    x = torch.tensor(np.vstack(graph_embedding), dtype=torch.float)

    # 重构 edge_index 生成逻辑
    sources = []
    targets = []
    for key in sorted_keys:
        source_idx = block_index_mapping[key]
        for out_block in sorted_data_mapping[key]['out']:
            if out_block in block_index_mapping:  # 过滤不存在的块
                target_idx = block_index_mapping[out_block]
                sources.append(source_idx)
                targets.append(target_idx)
            else:
                print(f"警告：跳转目标块 {out_block} 不存在，已忽略此边")

    edge_index = torch.tensor([sources, targets], dtype=torch.long)  # 确保类型为 torch.long

    # 创建PyG数据对象
    return Data(x=x, edge_index=edge_index, y=label)


class GNNModel(nn.Module):
    def __init__(self, input_dim=256, hidden_dim=128, output_dim=2, model_type='gcn'):
        super(GNNModel, self).__init__()
        self.model_type = model_type
        self.conv1 = GCNConv(input_dim, hidden_dim)
        self.conv2 = GCNConv(hidden_dim, hidden_dim)

        self.fc = nn.Linear(hidden_dim, output_dim)
        self.dropout = nn.Dropout(0.5)

    def forward(self, data, return_features=False):
        x, edge_index, batch = data.x, data.edge_index, data.batch

        x = self.conv1(x, edge_index)
        x = F.leaky_relu(x)
        x = self.dropout(x)

        x = self.conv2(x, edge_index)
        x = F.leaky_relu(x)

        if hasattr(data, 'batch') and data.batch is not None:
            x = global_mean_pool(x, data.batch)
        logits = self.fc(x)
        if return_features:
            return logits, x
        return logits


class GNNTrainer:
    def __init__(self, model, device='cpu',patience=5):
        self.model = model.to(device)
        self.device = device
        self.patience = patience
        self.best_loss = float('inf')
        self.epochs_without_improvement = 0  # 用于早停法


    def train(self, loader, optimizer, criterion):
        self.model.train()
        total_loss = 0
        for data in tqdm(loader, desc="Training"):
            data = data.to(self.device)
            optimizer.zero_grad()
            out = self.model(data)
            loss = criterion(out, data.y)
            loss.backward()
            optimizer.step()
            total_loss += loss.item()
        return total_loss / len(loader)

    def test(self, loader):
        self.model.eval()
        correct = 0
        total = 0
        all_preds = []
        all_labels = []
        with torch.no_grad():
            for data in tqdm(loader, desc="Testing"):
                data = data.to(self.device)
                out = self.model(data)
                pred = out.argmax(dim=1)
                correct += int((pred == data.y).sum())
                total += len(data.y)
                all_preds.extend(pred.cpu().numpy())
                all_labels.extend(data.y.cpu().numpy())

        # Calculate precision, recall, F1-score
        precision = precision_score(all_labels, all_preds)
        recall = recall_score(all_labels, all_preds)
        f1 = f1_score(all_labels, all_preds)

        return correct / total, precision, recall, f1

    def early_stop(self, val_loss):
        if val_loss < self.best_loss:
            self.best_loss = val_loss
            self.epochs_without_improvement = 0
            return False
        else:
            self.epochs_without_improvement += 1
            if self.epochs_without_improvement >= self.patience:
                return True
            return False

def load_bytecode_files(vulnerable_dir, normal_dir):
    """从两个文件夹加载字节码文件"""
    dataset = []
    file_info = []
    # 加载漏洞合约 (标签为1)
    print(f"Loading vulnerable contracts from {vulnerable_dir}")
    for filename in tqdm(os.listdir(vulnerable_dir)):
        if filename.endswith('.txt'):
            with open(os.path.join(vulnerable_dir, filename), 'r') as f:
                bytecode = f.read().strip()
                dataset.append((bytecode, 1))  # 1表示漏洞合约
                file_info.append((filename, 1))

    # 加载正常合约 (标签为0)
    print(f"Loading normal contracts from {normal_dir}")
    for filename in tqdm(os.listdir(normal_dir)):
        if filename.endswith('.txt'):
            with open(os.path.join(normal_dir, filename), 'r') as f:
                bytecode = f.read().strip()
                dataset.append((bytecode, 0))  # 0表示正常合约
                file_info.append((filename, 0))
    return dataset,file_info


def gnn_main():
    # 配置参数
    vulnerable_dir = "E:\Cross-Modality-Bug-Detection-main\dataset1\\bytecode\contract1\\time_label_1"  # 替换为漏洞合约文件夹路径
    normal_dir = "E:\Cross-Modality-Bug-Detection-main\dataset1\\bytecode\contract1\\time_label_0"  # 替换为正常合约文件夹路径
    batch_size = 64
    epochs = 200
    hidden_dim = 128

    # 1. 加载数据
    raw_dataset,file_info = load_bytecode_files(vulnerable_dir, normal_dir)
    print(
        f"Loaded {len(raw_dataset)} contracts ({sum(y for _, y in raw_dataset)} vulnerable, {len(raw_dataset) - sum(y for _, y in raw_dataset)} normal)")

    # 2. 处理数据
    processed_data = []
    error_files = []
    print("Processing bytecodes into graphs...")
    for idx,(bytecode, label) in enumerate(tqdm(raw_dataset)):
        try:
            data = process_bytecode(bytecode, label)
            if data is not None:
                processed_data.append(data)
        except Exception as e:
            # 获取对应的文件名
            filename, file_label = file_info[idx]
            error_files.append((filename, str(e)))
            print(f"\nError processing file: {filename} (label: {file_label})")
            print(f"Error message: {str(e)}")
            print(f"Bytecode snippet: {bytecode[:100]}...\n")
    # 打印错误统计
    print(f"\nProcessing complete. Success: {len(processed_data)}/{len(raw_dataset)}")
    if error_files:
        print("\nFiles with errors:")
        for filename, error in error_files:
            print(f"- {filename}: {error}")

    print(f"Successfully processed {len(processed_data)}/{len(raw_dataset)} contracts")

    # 3. 划分训练集(60%)、验证集(20%)、测试集(20%)
    train_data, temp_data = train_test_split(
        processed_data,
        test_size=0.4,
        random_state=42,
        stratify=[d.y for d in processed_data]
    )
    val_data, test_data = train_test_split(
        temp_data,
        test_size=0.5,
        random_state=42,
        stratify=[d.y for d in temp_data]
    )

    # 4. 创建数据加载器
    train_loader = DataLoader(train_data, batch_size=batch_size, shuffle=True)
    val_loader = DataLoader(val_data, batch_size=batch_size, shuffle=False)
    test_loader = DataLoader(test_data, batch_size=batch_size, shuffle=False)

    # 5. 初始化模型和训练器
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model = GNNModel(input_dim=256, hidden_dim=hidden_dim, output_dim=2, model_type='gcn').to(device)
    trainer = GNNTrainer(model, device, patience=5)
    optimizer = torch.optim.Adam(model.parameters(), lr=0.0005, weight_decay=5e-4)
    criterion = nn.CrossEntropyLoss()
    #6. 训练阶段
    best_val_f1=0
    for epoch in range(1, epochs + 1):
        # 训练阶段
        train_loss = trainer.train(train_loader, optimizer, criterion)

        # 验证阶段
        val_acc, val_precision, val_recall, val_f1 = trainer.test(val_loader)

        # 打印训练和验证指标（不涉及测试集）
        print(f"Epoch {epoch}: "
              f"Train Loss: {train_loss:.4f} | "
              f"Val Acc: {val_acc:.4f},Val Pre: {val_precision},Val Rec: {val_recall}, Val F1: {val_f1:.4f}")


        # 保存最佳模型（基于验证集F1）
        if val_f1 > best_val_f1:
            best_val_f1 = val_f1
            torch.save(model.state_dict(), 'E:/Cross-Modality-Bug-Detection-main/contract1_time_model/best_gcn116_model.pth')

        # 7. 最终测试（仅在训练结束后运行一次）
    model.load_state_dict(torch.load('E:/Cross-Modality-Bug-Detection-main/contract1_time_model/best_gcn116_model.pth'))  # 加载最佳模型
    test_acc, test_precision, test_recall, test_f1 = trainer.test(test_loader)
    print(f"\nFinal Test Results: "
          f"Acc: {test_acc:.4f}, Precision: {test_precision:.4f}, "
          f"Recall: {test_recall:.4f}, F1: {test_f1:.4f}")


if __name__ == "__main__":
    gnn_main()