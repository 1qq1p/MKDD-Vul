import os
import numpy as np
from PIL import Image


def bytes_to_image(input_file, output_path, img_size=(64, 64)):
    """
    将任意字节文件转换为灰度图像
    :param input_file: 输入字节码文件路径
    :param output_path: 输出图像保存路径
    :param img_size: 目标图像尺寸 (width, height)
    """
    # 读取二进制数据
    with open(input_file, 'rb') as f:
        byte_data = f.read()

    # 转换为numpy数组
    byte_array = np.frombuffer(byte_data, dtype=np.uint8)

    # 计算需要填充的字节数
    target_length = img_size[0] * img_size[1]
    if len(byte_array) < target_length:
        # 用零填充不足部分
        byte_array = np.pad(byte_array, (0, target_length - len(byte_array)),
                            mode='constant')
    else:
        # 截断过长的部分
        byte_array = byte_array[:target_length]

    # 重塑为二维数组
    image_data = byte_array.reshape(img_size[::-1])  # reshape需要(height, width)

    # 转换为PIL图像并保存
    img = Image.fromarray(image_data, mode='L')
    img.save(output_path)
    print(f"Image saved to {output_path}")


def process_folder(input_folder, output_folder, img_size=(256, 256)):
    """
    处理一个文件夹中的所有字节码.txt文件，并将其转换为图像
    :param input_folder: 输入文件夹路径
    :param output_folder: 输出文件夹路径
    :param img_size: 图像的目标尺寸 (width, height)
    """
    # 确保输出文件夹存在
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    # 遍历文件夹中的所有文件
    for file_name in os.listdir(input_folder):
        input_file_path = os.path.join(input_folder, file_name)

        # 只处理以 .txt 结尾的文件
        if os.path.isfile(input_file_path) and file_name.endswith('.txt'):
            # 生成输出图像的文件路径
            output_file_name = file_name.replace('.txt', '.png')
            output_file_path = os.path.join(output_folder, output_file_name)

            # 调用bytes_to_image函数处理每个文件
            bytes_to_image(input_file_path, output_file_path, img_size)


# 示例用法
input_folder = 'E:\Cross-Modality-Bug-Detection-main\dataset1\\bytecode\\dao'  # 输入文件夹路径
output_folder = 'E:\Cross-Modality-Bug-Detection-main\dataset1\\image\\dao'  # 输出文件夹路径
process_folder(input_folder, output_folder)
