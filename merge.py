# -*- coding: utf-8 -*-
import os
import sys

def merge_files_to_txt(folder_path, output_file_path):
    """
    将指定文件夹及其子文件夹下的所有文件内容合并到一个 TXT 文件中。
    尝试使用 GBK 编码读取源文件，以兼容可能包含中文的非 UTF-8 文件。
    输出文件仍使用 UTF-8 编码保存。

    Args:
        folder_path (str): 要遍历的文件夹路径。
        output_file_path (str): 输出 TXT 文件的路径。
    """
    # 检查输入文件夹是否存在
    if not os.path.isdir(folder_path):
        print(f"错误：文件夹 '{folder_path}' 不存在或不是一个有效的文件夹。")
        return

    print(f"开始处理文件夹：{folder_path}")
    print(f"输出文件将保存到：{output_file_path}")

    # 获取脚本自身的绝对路径和输出文件的绝对路径
    try:
        absolute_script_path = os.path.abspath(__file__)
    except NameError:
        print("警告：无法获取脚本文件路径，可能无法自动跳过脚本文件。")
        absolute_script_path = None

    absolute_output_file_path = os.path.abspath(output_file_path)

    try:
        # --- 重要：写入输出文件时，始终使用 UTF-8 编码 ---
        with open(output_file_path, 'w', encoding='utf-8', errors='ignore') as outfile:
            # os.walk 会递归遍历文件夹
            for root, dirs, files in os.walk(folder_path):
                # 排序（可选）
                files.sort()
                dirs.sort()
                # 过滤掉一些常见的不需要处理的目录
                dirs[:] = [d for d in dirs if d not in ['.git', '.svn', '__pycache__', '.vscode', '.idea', 'build']] # 添加了 build 目录过滤

                for filename in files:
                    file_path = os.path.join(root, filename)
                    absolute_file_path = os.path.abspath(file_path)

                    # 跳过输出文件和脚本文件
                    if absolute_file_path == absolute_output_file_path:
                        print(f"跳过输出文件：{file_path}")
                        continue
                    if absolute_script_path and absolute_file_path == absolute_script_path:
                         print(f"跳过脚本文件自身：{file_path}")
                         continue

                    # 写入文件路径标题 (使用 UTF-8 写入)
                    outfile.write(f"--- 文件路径：{file_path} ---\n\n")
                    print(f"正在处理文件：{file_path}")

                    try:
                        # --- 重要：尝试使用 GBK 编码读取文件 ---
                        # 这是最可能解决中文乱码问题的修改点
                        # 如果你的文件确定是其他编码（如 BIG5），可以改成对应的编码
                        with open(file_path, 'r', encoding='gbk', errors='ignore') as infile:
                            content = infile.read()
                            # 将读取到的内容（现在是 Python 内部的 Unicode 字符串）写入到 UTF-8 编码的输出文件中
                            outfile.write(content)

                        outfile.write("\n\n--- 文件结束 ---\n\n")
                    except Exception as e:
                        # 如果读取文件时发生其他错误（如权限问题，或者文件根本不是文本）
                        error_message = f"无法读取文件 '{file_path}'（尝试使用 GBK 编码）：{e}\n"
                        print(error_message)
                        # 仍然用 UTF-8 写入错误信息
                        outfile.write(f"*** {error_message} ***")
                        outfile.write("\n\n--- 文件结束 ---\n\n")

        print(f"处理完成！所有内容已合并到：{output_file_path}")

    except IOError as e:
        print(f"错误：无法写入输出文件 '{output_file_path}'：{e}")
    except Exception as e:
        print(f"发生意外错误：{e}")

# --- 脚本入口 ---
if __name__ == "__main__":
    try:
        script_path = os.path.abspath(__file__)
        script_folder = os.path.dirname(script_path)
        print(f"脚本路径检测为：{script_path}")
    except NameError:
        print("错误：无法自动检测脚本位置。请将此代码保存为 .py 文件，")
        print("      然后使用 'python your_script_name.py' 从命令行运行。")
        sys.exit(1)

    input_folder = script_folder
    output_filename = 'output_merged_files.txt' # 输出文件名
    output_file = os.path.join(input_folder, output_filename)
    absolute_output_file = os.path.abspath(output_file)

    print(f"目标文件夹：{input_folder}")
    print(f"输出文件路径：{absolute_output_file}")

    merge_files_to_txt(input_folder, output_file)