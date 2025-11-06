#根据源代码生成字节码和操作码

import re
from solcx import compile_standard, install_solc
import glob
import os
import subprocess
import pyevmasm
def getVersionPragma(source_code):  # param la path cua contract
    data = source_code.split('\n')
    for line in data:  # duyet tung dong trong contract do
        if 'pragma' in line and 'solidity' in line:  # neu dong do chua chu "pragma"
            line1=line.split('//')[0].strip()
            temp = line1.split()  # chuyen dong do thanh list ['pragma', 'solidity', '^0.4.19;']
            if len(temp) == 3 and temp[2][0].isnumeric() == True:  # ['pragma', 'solidity', '0.4.19;']
                return temp[2][0:-1]
            elif len(temp) == 3 and temp[2][1].isnumeric() == True:  # ['pragma', 'solidity', '^0.4.19;']
                return temp[2][1:-1]
            elif len(temp) == 3 and temp[2][1].isnumeric() == False:  # ['pragma', 'solidity', '<=0.4.19;']
                return temp[2][2:-1]
            elif len(temp) > 3 and len(temp[2]) == 1:
                return temp[2][-1]
            elif len(temp) == 4 and temp[2][1].isnumeric() == True:  # ['pragma', 'solidity', '>0.4.22', '<0.6.0]
                return temp[2][1:]
            elif len(temp) == 4 and temp[2][1].isnumeric() == False:  # ['pragma', 'solidity', '>=0.4.22', '<0.6.0]
                return '0.5.0'
    return '0.6.0'


def clean_opcode(opcode_str):
    # remove hex characters (0x..)
    opcode_str = re.sub(r'0x[a-fA-F0-9]+', '', opcode_str)

    # remove newline characters
    opcode_str = opcode_str.replace('\n', ' ')

    # extract only the opcode names
    opcodes = re.findall(r'[A-Z]+', opcode_str)

    return opcodes




def get_bytecode(regex, bytecode):
    cc = bytecode.split(regex)
    bytecode = ''.join(cc)
    match = re.findall(r"__.{1,50}_", bytecode)
    if len(match) != 0:
        bytecode = get_bytecode(match[0], bytecode)
        return bytecode
    else:
        return bytecode


def return_bytecode_opcode(content):
    version = getVersionPragma(content)

    print(f'Getting pragma version: {version}')
    install_solc(version)
    try:
        install_solc(version)
    except:
        version = '0.4.11'
        install_solc(version)
    try:
        compiled_sol = compile_standard(
            {
                "language": "Solidity",
                "sources": {'cc': {"content": content}},
                "settings": {
                    "outputSelection": {
                        "*": {
                            "*": ["evm.bytecode.opcodes", "metadata", "evm.bytecode.sourceMap"]
                        }
                    }
                },
            },
            solc_version=version,
        )
    except:
        compiled_sol = compile_standard(
            {
                "language": "Solidity",
                "sources": {'cc': {"content": content}},
                "settings": {
                    "outputSelection": {
                        "*": {
                            "*": ["evm.bytecode.opcodes", "metadata", "evm.bytecode.sourceMap"]
                        }
                    }
                },
            },
            solc_version='0.4.24',
        )

    contracts_name = compiled_sol["contracts"]['cc'].keys()
    list_opcode = []
    list_bytecode = []
    for contract in contracts_name:
        try:
            bytecode = compiled_sol["contracts"]["cc"][contract]["evm"]["bytecode"]["object"]
            opcode = compiled_sol["contracts"]["cc"][contract]["evm"]["bytecode"]["opcodes"]

            match = re.findall(r"__.{1,50}_", bytecode)
            if len(match) != 0:
                bytecode = get_bytecode(match[0], bytecode)

            list_bytecode.append(bytecode)
            list_opcode.append(opcode)

        except KeyError:
            # Handle the case where bytecode or opcode is not available
            print(f"Skipping contract {contract} as bytecode or opcode is not available.")
            continue
        except Exception as e:
            # Handle any other exceptions that may occur
            print(f"An error occurred while processing contract {contract}: {str(e)}")
            continue

    final_bytecode = ''.join(list_bytecode)
    final_opcode = ''.join(list_opcode)
    final_opcode = clean_opcode(final_opcode)
    final_opcode = ''.join(list_opcode)

    return final_bytecode, final_opcode


def process_files_in_folder(folder_path, output_byte_folder,output_opcode_folder):
    # 获取文件夹中所有以 .sol 结尾的 Solidity 文件
    solidity_files = glob.glob(os.path.join(folder_path, "*.sol"))
    solc_path = "D:/solc-windows/solc.exe"
    # 遍历每个文件
    for file_path in solidity_files:
        print(f"Processed file: {file_path}")
        try:
            # 打开并读取文件内容
            with open(file_path, 'r', encoding='utf-8') as file:
                content = file.read()
            try:
                # 在这里调用您提供的 return_bytecode_opcode 函数
                bytecode, opcode = return_bytecode_opcode(content)
            except Exception :
                result=subprocess.run([solc_path,"--bin", file_path], capture_output=True,text=True)
                # 输出编译结果
                output = result.stdout
                match = re.search(r"Binary:\s*([0-9a-fA-F]+)", output)
                if match:
                    bytecode = match.group(1)
                    opcode = pyevmasm.disassemble_hex(bytecode)
                    print("Extracted Bytecode:")
                    print(bytecode)
                else:
                    print("Bytecode not found in the output.")



            # 输出或处理生成的 bytecode 和 opcode
            #print(f"Bytecode: {bytecode}")
            #print(f"Opcode: {opcode}")

            base_filename = os.path.basename(file_path)
            filename = os.path.splitext(base_filename)[0]
            bytecode_file_path = os.path.join(output_byte_folder, f"{filename}.txt")
            opcode_file_path = os.path.join(output_opcode_folder, f"{filename}.txt")

            # 如果需要，您可以将 bytecode 和 opcode 保存到文件或数据库
            # 例如，保存到文件：
            with open(bytecode_file_path, 'w', encoding='utf-8') as bytecode_file:
                bytecode_file.write(bytecode)
            with open(opcode_file_path, 'w', encoding='utf-8') as opcode_file:
                opcode_file.write(opcode)
            #os.remove(file_path)
        except Exception as e:
            print(f"An error occurred while processing file {file_path}: {str(e)}")
            # 发生异常时删除源文件
            os.remove(file_path)
            continue


if __name__ == '__main__':
    input_dir="E:\Cross-Modality-Bug-Detection-main\dataset1\sc\dao"
    output_byte_dir= "E:\Cross-Modality-Bug-Detection-main\dataset1\\bytecode\dao"
    output_op_dir= "E:\Cross-Modality-Bug-Detection-main\dataset1\opcode\dao"
    process_files_in_folder(input_dir, output_byte_dir, output_op_dir)