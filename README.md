# MKDD-Vul: A Lightweight Multi-modal Knowledge Distillation Framework for Detecting Vulnerabilities in Smart Contracts

## Overview

MKDD-Vul employs knowledge distillation to learn interaction information from three modal data representations of smart contracts (control flow graphs, grayscale images, and opcode sequences), providing a solution for identifying vulnerabilities in smart contracts.

## Requirements
  - Requirements
  
  To install requirements:
  
  ```
  pip install -r requirements.txt
  ```

## Model Workflow

1. **CFG Generation:**
   - Utilizes the evm-cfg-builder to generate the CFG from the smart contract bytecode. and embeds the content of each node using word2vec.

2. **Grayscale Image:**
   - Convert hexadecimal bytecode sequences to decimal lists, and store it as a two-dimensional matrix in row-major order, with each value corresponding to a pixel point.

3. **Opcode sequences:**
   - Perform address filtering and normalization on the opcode sequence, and embeds the content using BERT.


## Impressive Results

RazorBlade has undergone rigorous testing on prominent datasets:
- [smartbugs-wild](https://github.com/smartbugs/smartbugs-wild/tree/master/contracts) on github
- [Ethereum_smart_contract](https://github.com/Messi-Q/Smart-Contract-Dataset) on github

## Usage
- Training

To train three teacher models (three modal representations) and a lightweight student mmodel(main network), we can run the following command:
```
python by_cfg_gnn.py   # T1
python byte_im.py      # T2
python op_trans.py     # T3
python student3_2.py   # student model
```




