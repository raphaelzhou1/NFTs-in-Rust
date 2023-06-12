import pandas as pd
import json
import tkinter as tk
from tkinter import filedialog
import subprocess
import csv
import os

git_root = subprocess.check_output(['git', 'rev-parse', '--show-toplevel']).strip().decode('utf-8')

def load_file_path(filetype):
    root = tk.Tk()
    root.withdraw()  # Hides the root window
    file_path = filedialog.askopenfilename(initialdir=git_root, filetypes=[(f"{filetype} files", f"*.{filetype}")])
    return file_path

def load_file(filetype):
    root = tk.Tk()
    root.withdraw()  # Hides the root window
    file_path = filedialog.askopenfilename(initialdir=git_root, filetypes=[(f"{filetype} files", f"*.{filetype}")])

    if filetype == 'csv':
        df = pd.read_csv(file_path)
        # Get the list of TX_FROM values
        df = df[~df['TX_FROM'].str.contains('\r')]
        data = df['TX_FROM'].tolist()
    elif filetype == 'json':
        with open(file_path, 'r') as json_file:
            data = json.load(json_file)
        data = [s.replace('\r', '') for s in data]

    return data

def save_to_csv(data, file_path):
    # Ask the user for a filename
    file_name = input("Enter a filename for the CSV file, without .csv suffix: ")

    # Concatenate the filename to the chosen directory path
    save_path = os.path.join(file_path, f"{file_name}.csv")

    with open(save_path, 'w', newline='') as f:
        writer = csv.writer(f)
        for item in data:
            writer.writerow([item])

def save_to_json(data, file_path):
    # Ask the user for a filename
    file_name = input("Enter a filename for the JSON file, without .json suffix: ")

    # Concatenate the filename to the chosen directory path
    save_path = os.path.join(file_path, f"{file_name}.json")

    # Create a single string with the JSON representation of the data
    # json.dumps will create a string, not write directly to a file
    # We're using an indent of 0 to put each item on a new line without leading spaces
    data_string = json.dumps(list(data), indent=0)

    # Remove leading spaces from all lines in the string
    data_string = '\n'.join(line.lstrip() for line in data_string.split('\n'))

    # Write the resulting string to the file
    with open(save_path, 'w') as f:
        f.write(data_string)

def save_file(data, file_path):
    # Ask the user for the output format
    file_format = input("Enter the desired output file format (csv or json): ").lower()

    # Ask the user for a filename
    file_name = input("Enter a filename for the file, without file extension: ")

    # Concatenate the filename to the chosen directory path
    save_path = os.path.join(file_path, f"{file_name}.{file_format}")

    if file_format == 'csv':
        with open(save_path, 'w', newline='') as f:
            writer = csv.writer(f)
            for item in data:
                writer.writerow([item])
    elif file_format == 'json':
        # Create a single string with the JSON representation of the data
        # json.dumps will create a string, not write directly to a file
        # We're using an indent of 0 to put each item on a new line without leading spaces
        data_string = json.dumps(list(data), indent=0)

        # Remove leading spaces from all lines in the string
        data_string = '\n'.join(line.lstrip() for line in data_string.split('\n'))

        # Write the resulting string to the file
        with open(save_path, 'w') as f:
            f.write(data_string)
    else:
        raise ValueError(f"Unsupported file format: {file_format}")


def load_file_with_path(file_path):
    if file_path.endswith('.csv'):
        df = pd.read_csv(file_path)

        # Check if any of the column names starts with "sei"
        col_name = next((col for col in df.columns if col.startswith('sei')), None)
        if col_name is not None:
            # If yes, just take the first column
            data = df.iloc[:, 0].tolist()
        else:
            # Else, proceed as before
            df = df[~df['TX_FROM'].str.contains('\r')]
            data = df['TX_FROM'].tolist()
    elif file_path.endswith('.json'):
        with open(file_path, 'r') as json_file:
            data = json.load(json_file)
        data = [s.replace('\r', '') for s in data]
    else:
        raise ValueError(f"Unsupported file type: {file_path}")
    return data


def compare_files(path1, path2):
    list1 = load_file_with_path(path1)
    list2 = load_file_with_path(path2)

    print(list1[:10])
    print(list2[:10])
    print("Number of elements in file 1: ", len(list1))
    print("Number of unique elements in file 1: ", len(set(list1)))
    print("Number of unique elements in file 2: ", len(set(list2)))

    # Find the superset (union) of the two lists
    superset = set(list1).union(set(list2))

    # Compare the differences
    list1_not_in_list2 = set(list1).difference(set(list2))
    list2_not_in_list1 = set(list2).difference(set(list1))
    print("Number of elements in Superset of file 1 and file 2: ", len(superset))
    print("Number of elements in file 1 but not in file 2: ", len(list1_not_in_list2))
    print("Number of elements in file 2 but not in file 1: ", len(list2_not_in_list1))

    save_directory = filedialog.askdirectory(initialdir=git_root)
    save_to_json(list2_not_in_list1, save_directory)

def ask_user_load_more_files(superset):
    while True:
        answer = input("Do you want to load another file? (y/n): ")
        if answer.lower() == 'n':
            break

        filetype = input("Enter the file type (csv/json): ")
        data = load_file(filetype)
        superset = superset.union(set(data))

    return superset

def main():
    # superset = set()
    # superset = ask_user_load_more_files(superset)
    # print("Number of elements in Superset: ", len(superset))
    #
    # print("Would you like to save the superset to a file?")
    # save_directory = filedialog.askdirectory(initialdir=git_root)
    # save_to_json(superset, save_directory)

    # Ask the user to compare two files
    print("Would you like to compare two files?")

    answer = input("Answer (y/n): ")
    if answer.lower() == 'y':
        # Load the paths for CSV and JSON files
        file_format = input("Enter the desired output file format (csv or json): ").lower()
        file1_path = load_file_path(file_format)
        file_format = input("Enter the desired output file format (csv or json): ").lower()
        file2_path = load_file_path(file_format)

        # Compare files and output results
        compare_files(file1_path, file2_path)

if __name__ == "__main__":
    main()
