import tkinter as tk
from tkinter import filedialog
import csv
import json
import os

def choose_file(starting_directory, title="Select a file"):
    root = tk.Tk()
    root.withdraw()
    file_path = filedialog.askopenfilename(initialdir=starting_directory,
                                           title=title,
                                           filetypes=(("CSV files", "*.csv"),))
    return file_path

def choose_column(columns):
    root = tk.Tk()
    root.title("Choose Column")

    selected_column = tk.StringVar()
    selected_column.set(columns[0])

    drop_menu = tk.OptionMenu(root, selected_column, *columns)
    drop_menu.pack()

    def on_submit():
        nonlocal selected_column
        selected_column = selected_column.get()
        root.quit()

    submit_button = tk.Button(root, text="Submit", command=on_submit)
    submit_button.pack()

    root.mainloop()
    return selected_column

def main():
    # Select the CSV file
    file_path = choose_file(os.getcwd(), "Select a CSV file")
    if not file_path:
        print("No file selected")
        return

    # Read the CSV file
    with open(file_path, 'r') as csv_file:
        reader = csv.reader(csv_file)
        headers = next(reader)
        data = list(reader)

    # Choose column
    column = choose_column(headers)
    if not column:
        print("No column selected")
        return

    # Extract data from chosen column
    column_index = headers.index(column)
    json_data = [row[column_index] for row in data]

    # Output to .json file
    directory, file_name = os.path.split(file_path)
    base_name, _ = os.path.splitext(file_name)
    output_path = os.path.join(directory, f"{base_name}.json")

    with open(output_path, 'w') as json_file:
        json.dump(json_data, json_file, indent=4)

    print(f"Data saved to {output_path}")

if __name__ == "__main__":
    main()
