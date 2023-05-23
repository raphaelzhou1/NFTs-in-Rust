import sys
import tkinter as tk
from tkinter import filedialog, messagebox
import pandas as pd
import argparse

def on_button_click(column_name, root):
    global selected_column
    selected_column = column_name
    root.quit()

def select_column_from_csv(file_path):
    df = pd.read_csv(file_path)
    root = tk.Tk()
    root.title("Select Column")

    for i, column_name in enumerate(df.columns):
        button = tk.Button(root, text=column_name, command=lambda col=column_name: on_button_click(col, root))
        button.grid(row=i // 5, column=i % 5, sticky='w')

    root.mainloop()
    return df.columns.get_loc(selected_column)

def mint_nft_from_csv_helper(file_path):
    column_index = select_column_from_csv(file_path)
    print(column_index)

def main():
    parser = argparse.ArgumentParser(description="Call different functions from functions_helper")
    parser.add_argument("function_name", choices=["mint_nft_from_csv_helper", "another_function"],
                        help="The name of the function you want to call")
    parser.add_argument("file_path", help="The path to the CSV file")

    args = parser.parse_args()

    if args.function_name == "mint_nft_from_csv_helper":
        mint_nft_from_csv_helper(args.file_path)

if __name__ == "__main__":
    main()