import numpy as np
import csv
import pandas as pd
import re
import os
import glob
import tkinter as tk
from tkinter import filedialog
import json

## READ
current_dir = os.getcwd()
git_root = current_dir
while not os.path.exists(os.path.join(git_root, '.git')):
    git_root = os.path.dirname(git_root)
def choose_csv_file(starting_directory):
    root = tk.Tk()
    root.withdraw()
    file_path = filedialog.askopenfilename(initialdir=starting_directory, title="Select a CSV file", filetypes=(("CSV files", "*.csv"),))
    return file_path
input_dir = choose_csv_file(git_root)
input_dir_directory = os.path.dirname(input_dir)
print(f"Selected file: {input_dir}")
original_df = pd.read_csv(input_dir)
df = original_df.copy()
print(df)

## ETL
# Drop any rows that don't have an address, since to prevent bots # but not username since Discord username is optional
df = df[df['Your Sei wallet address'].notnull()]

# Strip any whitespace from the Discord username
df['Your Discord Username (optional)'] = df['Your Discord Username (optional)'].str.strip()
# Filter out any rows that have a Discord username that isn't searchable
searchable_username_regex = re.compile(r'.+#\d{4}\s*$') # Regex to match a Discord username, anything that isn't whitespace followed by a # followed by 4 digits
searchable_address_regex = re.compile(r'^sei[A-Za-z0-9]{39}$')

df_address = df[df['Your Sei wallet address'].apply(lambda x: bool(searchable_address_regex.match(x)) if isinstance(x, str) else False)]
df_address.drop_duplicates(subset='Your Sei wallet address', keep='first', inplace=True)

df_username = df_address[df_address['Your Discord Username (optional)'].apply(lambda x: bool(searchable_username_regex.match(x)) if isinstance(x, str) else False)]
df_username.drop_duplicates(subset='Your Discord Username (optional)', keep='first', inplace=True)
df_username = df_username.rename(columns={'Your Discord Username (optional)': 'discord usernames/ids'}) # So will be recognized in CSV role
df_username = df_username.drop(columns=[col for col in df_username.columns if col != 'discord usernames/ids'])
# df_username["Your Discord Username (optional)"] = df_username["Your Discord Username (optional)"].str.strip('0')

# Apply clean_username function to the "Your Discord Username (optional)" column

## WRITE Address
# Delete legacy
output_dir = input_dir_directory
os.chdir(output_dir)
filename_format = 'SparrowSwap_Mission_One_Registration_Address_Filtered_*.csv'
files_to_delete = glob.glob(filename_format)
for file in files_to_delete:
    os.remove(file)
filename_format = 'SparrowSwap_Mission_One_Registration_Address_Filtered_{}.csv'

address_filename = 'SparrowSwap_Mission_One_Registration_Address_Filtered.csv'
address_output_file_path = os.path.join(output_dir, address_filename)
df_address.to_csv(address_output_file_path, index=False)
print(f"Address DataFrame saved to {address_output_file_path}")
username_filename = 'SparrowSwap_Mission_One_Registration_Username_Filtered.csv'
username_output_file_path = os.path.join(output_dir, username_filename)
df_username.to_csv(username_output_file_path, index=False)
print(f"Username DataFrame saved to {username_output_file_path}")

# Split the output into multiple files if the number of rows exceeds 998
file_count = 1
row_count = 0
header_row = list(df_address.columns)

# Loop over the DataFrame rows and save them to CSV files
for index, row in df_address.iterrows():
    # Create a new file if the row count exceeds the limit
    if row_count >= 998:
        file_count += 1
        row_count = 0

    # Set the file name for the current row
    filename = os.path.join(output_dir, filename_format.format(file_count))

    # Append the current row to the current file
    with open(filename, 'a', newline='') as file:
        if row_count == 0:
            writer = csv.writer(file)
            writer.writerow(header_row)
        writer = csv.writer(file)
        writer.writerow(row)

    # Update the row and file counts
    row_count += 1

print(df_address)
filename = 'SparrowSwap_Mission_One_Registration_Address_Filtered.csv'
output_file_path = os.path.join(output_dir, filename)
df_address.to_csv(output_file_path, index=False)

wallet_addresses = df_address['Your Sei wallet address'].values.tolist()
wallet_addresses_json_path = os.path.join(output_dir, 'wallet_addresses.json')
with open(wallet_addresses_json_path, 'w') as f:
    json.dump(wallet_addresses, f, indent=4)
print(f"Wallet addresses saved to {wallet_addresses_json_path}")


## WRITE Username
# Delete legacy
filename_format_username = 'SparrowSwap_Mission_One_Registration_Username_Filtered_*.csv'
files_to_delete_username = glob.glob(filename_format_username)
for file in files_to_delete_username:
    os.remove(file)

current_dir = os.getcwd()
git_root = current_dir
while not os.path.exists(os.path.join(git_root, '.git')):
    git_root = os.path.dirname(git_root)
output_dir = os.path.join(git_root, 'data_analysis', 'Mission_One', 'data')
filename_format_username = 'SparrowSwap_Mission_One_Registration_Username_Filtered_{}.csv'

# Split the output into multiple files if the number of rows exceeds 998
file_count = 1
row_count = 0
header_row = list(df_username.columns)

# Loop over the DataFrame rows and save them to CSV files
for index, row in df_username.iterrows():
    # Create a new file if the row count exceeds the limit
    if row_count >= 998:
        file_count += 1
        row_count = 0

    # Set the file name for the current row
    filename = os.path.join(output_dir, filename_format_username.format(file_count))

    # Append the current row to the current file
    with open(filename, 'a', newline='', encoding='utf-8') as file:
        if row_count == 0:
            writer = csv.writer(file)
            writer.writerow(header_row)
        writer = csv.writer(file)
        writer.writerow(row)

    # Update the row and file counts
    row_count += 1

print(df_username)

########################################################################################################################

# import discord
# from discord.ext import commands
# import requests
# from dotenv import load_dotenv, dotenv_values
# import os
# import pandas as pd
# import asyncio
#
# load_dotenv()
# discord_token = dotenv_values(".env")["DISCORD_BOT_KEY"]
# client = commands.Bot(command_prefix="*", intents=discord.Intents.all())
# channel = client.get_channel(dotenv_values(".env")["CHANNEL_ID"])
#
# usernames = pd.read_csv('mission_one/data/SparrowSwap_Mission_One_Registration_Form_Filtered.csv')['Your Discord Username (optional)'].tolist()
#
# @client.event
# async def on_ready():
#     print("Bot connected")
#
# # Assign the role to each user in the list
# async def assign_role():
#     for username in usernames:
#         # Get the user object from the Discord API
#         user = await channel.fetch_user(username)
#
#         # Get the role object from the Discord API
#         role = discord.utils.get(user.guild.roles, name='Powder Monkey')
#         # Assign the role to the user
#         await user.add_roles(role)
#
# # Run the assign_role function when the script starts
# async def client_assign_role():
#     await client.start('MTA5NTEzNTUyMzc5MTcwMDA5OA.GUr6Yu.bfA9tTdIoV8Qq2d97eRm-1lLPPlh-q3Aro-yYc')
#     await client.wait_until_ready()
#     print(client)
#     await client.loop.create_task(assign_role())
#
# client.run(discord_token)
# asyncio.run(client_assign_role())

########################################################################################################################
