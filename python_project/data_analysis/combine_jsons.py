import tkinter as tk
from tkinter import ttk, filedialog
import json
import os
from collections import OrderedDict

def choose_json_file(starting_directory):
    root = tk.Tk()
    root.withdraw()
    file_path = filedialog.askopenfilename(initialdir=starting_directory, title="Select a JSON file", filetypes=(("JSON files", "*.json"),))
    return file_path

def build_tree(tree, parent, data):
    if isinstance(data, dict):
        for key, value in data.items():
            item = tree.insert(parent, 'end', text=key)
            build_tree(tree, item, value)
    elif isinstance(data, list):
        if all(isinstance(item, dict) for item in data):
            for index, value in enumerate(data[0].keys()):
                item = tree.insert(parent, 'end', text=f"{value}")
        else:
            for index, value in enumerate(data):
                item = tree.insert(parent, 'end', text=f"Index {index}")
                build_tree(tree, item, value)

def fetch_selected_data(data, item_key_path):
    key = item_key_path.pop(0)  # Get the next key in the path

    print(f"JSON file key: {key}")

    # Base case: if the data is a list of dictionaries and the key is in the dictionaries
    if isinstance(data, list) and all(isinstance(item, dict) for item in data):
        if item_key_path:  # If there are more keys in the path, keep digging
            return [fetch_selected_data(item[key], list(item_key_path)) for item in data if key in item]
        else:  # Otherwise, return the values for the key
            return [item[key] for item in data if key in item]

    # Recursive case 1: if the data is a dictionary, search its values
    elif isinstance(data, dict):
        if key in data:
            if item_key_path:  # If there are more keys in the path, keep digging
                return fetch_selected_data(data[key], item_key_path)
            else:  # Otherwise, return the value for the key
                return data[key]

    # Recursive case 2: if the data is a list (but not of dictionaries), search its items
    elif isinstance(data, list):
        return [fetch_selected_data(item, list(item_key_path)) for item in data]

    # If the data is neither a list nor a dictionary, we can't search it, so return None
    else:
        return None

def on_select(event):
    global first_addresses
    item = tree.selection()[0]
    item_path = []
    while item:
        item_path.insert(0, tree.item(item)['text'])
        item = tree.parent(item)

    first_addresses = fetch_selected_data(first_json_data, item_path)
    if first_addresses is not None:
        root.quit()


# Select the first JSON file
print("Select the first JSON file with new addresses")
first_json_path = choose_json_file(os.getcwd())
print(f"Selected file: {first_json_path}")

# Load the data from the first JSON file
with open(first_json_path, 'r') as f:
    first_json_data = json.load(f)

# Create GUI and tree view
root = tk.Tk()
tree = ttk.Treeview(root)
tree.pack(fill=tk.BOTH, expand=True)

build_tree(tree, '', first_json_data)
tree.bind('<<TreeviewSelect>>', on_select)

root.mainloop()

# Select the second JSON file
print("Select the second JSON file with old addresses")
second_json_path = choose_json_file(os.getcwd())
print(f"Selected file: {second_json_path}")

# Load the addresses from the second JSON file
with open(second_json_path, 'r') as f:
    second_addresses = json.load(f)

first_addresses_dict = OrderedDict.fromkeys(first_addresses)
second_addresses_dict = OrderedDict.fromkeys(second_addresses)
# # Convert the lists to sets to remove duplicates
# first_addresses_set = set(first_addresses)
# second_addresses_set = set(second_addresses)

# prioritize the order of second_addresses and then add unique values from first_addresses
combined_addresses_dict = OrderedDict(list(item for item in second_addresses_dict.items() if item[0] is not None)
                                      + list(item for item in first_addresses_dict.items() if item[0] is not None))# combined_addresses_set = first_addresses_set | second_addresses_set
# first_addresses_set -= second_addresses_set

# Write the result to a new file
first_json_dir, first_json_name = os.path.split(first_json_path)
first_json_basename, first_json_ext = os.path.splitext(first_json_name) # Split the name and extension
second_json_dir, second_json_name = os.path.split(second_json_path)
second_json_basename, second_json_ext = os.path.splitext(second_json_name)
output_json_path = os.path.join(first_json_dir, f"{first_json_basename}_combined_with_{second_json_basename}{first_json_ext}")
output_json_path_2 = os.path.join(first_json_dir, f"{first_json_basename}_removed_of_{second_json_basename}{first_json_ext}")

with open(output_json_path, 'w') as f:
    json.dump(list(combined_addresses_dict.keys()), f, indent=4)

print(f"Removed duplicates saved to {output_json_path}")
