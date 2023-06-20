import json
import tkinter as tk
from tkinter import filedialog

# Create the root window
root = tk.Tk()
root.withdraw()  # Hide the main window

# Prompt user to select a JSON file
filename = filedialog.askopenfilename(filetypes=[("JSON files", "*.json")])

# Read the selected JSON file
with open(filename, 'r') as f:
    data = json.load(f)

# Extract unique non-empty values under the key "address"
addresses = {obj['address'] for obj in data if obj.get('address')}

# Write the addresses to a new JSON file in the same directory
output_filename = filename.rsplit('.', 1)[0] + '_addresses.json'
with open(output_filename, 'w') as f:
    json.dump(list(addresses), f)

print(f"Unique addresses have been written to {output_filename}")
