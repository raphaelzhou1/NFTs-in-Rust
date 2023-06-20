import tkinter as tk
from tkinter import filedialog
from bech32 import bech32_decode, bech32_encode, convertbits
import json
import os

def choose_file(starting_directory, title="Select a file"):
    root = tk.Tk()
    root.withdraw()
    file_path = filedialog.askopenfilename(initialdir=starting_directory,
                                           title=title,
                                           filetypes=(("JSON files", "*.json"),))
    return file_path

def validate_address(address):
    try:
        hrp, data = bech32_decode(address)
        decoded = convertbits(data, 5, 8, False)
        if decoded is None or hrp != 'sei':
            return False
        return True
    except:
        return False

# Open the file chooser dialog
file_path = choose_file(os.getcwd())
print(f"Selected file: {file_path}")

# Load the addresses
with open(file_path, "r") as f:
    addresses = json.load(f)

valid_addresses = [address for address in addresses if validate_address(address)]
print(f"Number of valid addresses: {len(valid_addresses)}")

# Save the valid addresses to a new file
dir_path, file_name = os.path.split(file_path)
base_name, _ = os.path.splitext(file_name)
new_file_path = os.path.join(dir_path, f"{base_name}_valid.json")

with open(new_file_path, "w") as f:
    json.dump(valid_addresses, f)

print(f"Valid addresses saved to {new_file_path}")
