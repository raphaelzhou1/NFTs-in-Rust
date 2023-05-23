import time
import discord
import requests
import re
import aiohttp
import asyncio
import os
from discord.ext import commands
from dotenv import load_dotenv, dotenv_values
import pyautogui as pg
from PIL import Image
import random
import csv
import numpy as np
import uuid

load_dotenv()
directory = os.getcwd()
discord_token = dotenv_values(".env")["DISCORD_BOT_KEY"]


templates = [
    "a {fur_color} powder monkey (powder boy) with {clothing} on a ship called {ship}, wearing a {hat}, {action}, with {eye} eyes and a {mouth} mouth, on a {background_color} background"
]

# Lists of replaceable words
fur_colors = ["gray", "yellow", "blue", "purple", "green", "orange", "pink", "red"]
ships = ["HMS ENCORE", "The Queen Anne's Revenge", "The Jolly Roger", "The Dying Gull", "The Black Pearl"]
clothes = ["Navy Striped Tee vest", "a ragged vest", "a striped shirt", "a captain's coat", "a pirate jacket"]
hats = ["a seaman's hat", "a bandana", "a tricorn hat", "a captain's hat", "a pirate's hat"]
actions = [
    "watching cannon shots",
    "swabbing the deck",
    "loading cannons",
    "singing sea shanties",
    "navigating through treacherous waters",
    "hoisting the Jolly Roger",
    "firing cannons"
]
eyes = ["round", "narrow", "squinty", "wide", "curious", "sleepy"]
mouths = ["smiling", "frowning", "laughing", "grinning", "smirking", "pouting"]
background_colors = ["gray", "yellow", "blue", "purple", "green", "orange", "pink", "red"]

# Probability distributions for each attribute array
fur_colors_probs = [0.55, 0.3, 0.1, 0.01, 0.01, 0.01, 0.01, 0.01]
ship_probs = [0.98, 0.005, 0.005, 0.005, 0.005]
clothes_probs = [0.96, 0.01, 0.01, 0.01, 0.01]
hats_probs = [0.55, 0.3, 0.1, 0.03, 0.02]
actions_probs = [0.6, 0.3, 0.06, 0.01, 0.01, 0.01, 0.01]
eyes_probs = [0.35, 0.25, 0.2, 0.1, 0.05, 0.05]
mouths_probs = [0.35, 0.25, 0.2, 0.1, 0.05, 0.05]
background_colors_probs = [0.55, 0.3, 0.1, 0.01, 0.01, 0.01, 0.01, 0.01]

client = commands.Bot(command_prefix="*", intents=discord.Intents.all())

@client.event
async def on_ready():
    print("Bot connected")
@client.event
async def on_message(message):
    async def download_prompts():
        start_time = time.time()
        # Read prompts from the CSV file
        workspace_directory = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
        prompts_file_path = os.path.join(workspace_directory, 'python_project', 'midjourney', 'prompts.csv')
        with open(prompts_file_path, mode='r') as prompts_file:
            reader = csv.reader(prompts_file)
            prompts = [row[0] for row in reader][1:]  # Skip the header row

        prompt_counter = 0
        await asyncio.sleep(3)
        pg.press('tab')
        while prompt_counter < len(prompts):
            if time.time() - start_time > 30 * 60:  # 30 minutes in seconds
                print("Bot stopped after 30 minutes.")
                break
            await asyncio.sleep(3)
            pg.write('/imagine')
            await asyncio.sleep(5)
            pg.press('tab')
            pg.write(prompts[prompt_counter])
            await asyncio.sleep(3)
            pg.press('enter')
            await asyncio.sleep(5)
            prompt_counter += 1

    global prompt_counter

    msg = message.content

    # Start Automation by typing "automation" in the discord channel
    if msg == 'automation':
        loop = asyncio.get_event_loop()
        loop.create_task(download_prompts())

    if message.content.endswith("(fast)") and not message.content.endswith(") (fast)"):
        loop = asyncio.get_event_loop()
        loop.create_task(download_image_from_message(message))

async def download_image_from_message(message):
    words = re.findall(r'\b\w+\b', message.content)

    # Concatenate the words into a file prefix
    file_prefix = '_'.join(words) + '_'

    for attachment in message.attachments:
        if "Upscaled by" in message.content:
            file_prefix = f"UPSCALED_{file_prefix}"

        if attachment.filename.lower().endswith((".png", ".jpg", ".jpeg", ".gif", ".webp")):
            try:
                await download_image(attachment.url, f"{file_prefix}{attachment.filename}")
            except:
                await asyncio.sleep(10)
                continue

def split_image(image_file):
    with Image.open(image_file) as im:
        # Get the width and height of the original image
        width, height = im.size
        # Calculate the middle points along the horizontal and vertical axes
        mid_x = width // 2
        mid_y = height // 2
        # Split the image into four equal parts
        top_left = im.crop((0, 0, mid_x, mid_y))
        top_right = im.crop((mid_x, 0, width, mid_y))
        bottom_left = im.crop((0, mid_y, mid_x, height))
        bottom_right = im.crop((mid_x, mid_y, width, height))
        return top_left, top_right, bottom_left, bottom_right

async def download_image(url, original_filename):
    unique_id = uuid.uuid4() # Generate a unique ID for the image filename; otherwise, too long s.t. OS doesn't allow
    filename = f"{unique_id}.png"

    print(f"Downloading {original_filename} as {filename}...")
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            if response.status == 200:
                # Define the input and output folder paths
                workspace_directory = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
                input_folder = os.path.join(workspace_directory, 'python_project', 'midjourney', 'input')
                output_folder = os.path.join(workspace_directory, 'python_project', 'midjourney', 'output')

                # Check if the output folder exists, and create it if necessary
                if not os.path.exists(output_folder):
                    os.makedirs(output_folder)
                    os.chmod(output_folder, 0o755)
                # Check if the input folder exists, and create it if necessary
                if not os.path.exists(input_folder):
                    os.makedirs(input_folder)
                    os.chmod(input_folder, 0o755)

                print(f"Input folder path: {input_folder}/{filename}")
                input_file_path = os.path.join(input_folder, filename)

                data = await response.read()  # Read the content of the response as bytes

                with open(input_file_path, "wb") as f:
                    f.write(data)  # Write the data into the file
                    print(f"Image downloaded: {filename}")

                # Write the UUID and original filename mapping to a CSV file
                uuid_mapping_csv_path = os.path.join(output_folder, "uuid.csv")
                with open(uuid_mapping_csv_path, "a", newline='') as csvfile:
                    csv_writer = csv.writer(csvfile)
                    csv_writer.writerow([unique_id, original_filename])


                if "UPSCALED_" not in filename:
                    file_prefix = os.path.splitext(filename)[0]
                    # Split the image
                    top_left, top_right, bottom_left, bottom_right = split_image(input_file_path)
                    # Save the output images with dynamic names in the output folder
                    top_left.save(os.path.join(output_folder, file_prefix + "_top_left.jpg"))
                    top_right.save(os.path.join(output_folder, file_prefix + "_top_right.jpg"))
                    bottom_left.save(os.path.join(output_folder, file_prefix + "_bottom_left.jpg"))
                    bottom_right.save(os.path.join(output_folder, file_prefix + "_bottom_right.jpg"))
                else:
                    os.rename(input_file_path, os.path.join(output_folder, filename))
                # Delete the input file
                os.remove(input_file_path)

            else:
                print(f"Error downloading {filename}: Status code {response.status}")

async def runner():
    # First, import bot: https://discord.com/api/oauth2/authorize?client_id=1095135523791700098&scope=bot%20applications.commands
    # Generate prompts by replacing words in the templates
    prompts = []
    for i in range(500):
        fur_color = random.choices(fur_colors, fur_colors_probs)[0]
        ship = random.choices(ships, ship_probs)[0]
        clothing = random.choices(clothes, clothes_probs)[0]
        hat = random.choices(hats, hats_probs)[0]
        action = random.choices(actions, actions_probs)[0]
        eye = random.choices(eyes, eyes_probs)[0]
        mouth = random.choices(mouths, mouths_probs)[0]
        background_color = random.choices(background_colors, background_colors_probs)[0]
        prompt = random.choice(templates).format(fur_color=fur_color, ship=ship, clothing=clothing, hat=hat, action=action, eye=eye, mouth=mouth, background_color=background_color)
        prompts.append(prompt)
    print(prompts)

    workspace_directory = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
    prompts_file_path = os.path.join(workspace_directory, 'python_project', 'midjourney', 'prompts.csv')
    with open(prompts_file_path, mode='w') as prompts_file:
        writer = csv.writer(prompts_file)
        writer.writerow(['Prompts'])
        for prompt in prompts:
            writer.writerow([prompt])

    await client.start(discord_token)

asyncio.run(runner())
