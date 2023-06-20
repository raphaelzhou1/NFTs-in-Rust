import json
import os
import tkinter as tk
from tkinter import filedialog

def main():
    # Create the root Tk window
    root = tk.Tk()
    # Hide the main window
    root.withdraw()

    # Open the file selector dialog
    file_path = filedialog.askopenfilename()

    # Load the JSON file
    with open(file_path, 'r') as f:
        data = json.load(f)
    print(data)

    # Iterate over the array in the JSON file
    # And remove any members containing an escape character
    data = [member for member in data if '\r' not in member]

    # Get the base file name and its extension
    base_name, extension = os.path.splitext(file_path)

    # Create a new file name for the output file
    new_file_path = f"{base_name}_modified{extension}"

    # Save the modified array back to a new JSON file
    with open(new_file_path, 'w') as f:
        json.dump(data, f, indent=4)

    print(f"Modified JSON has been saved to {new_file_path}")

if __name__ == "__main__":
    main()
