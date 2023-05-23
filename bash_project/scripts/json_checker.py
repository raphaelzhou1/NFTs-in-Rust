import json

json_string = '''
{
   "mint": {
     "owner": "sei13e58xcttwm7n5tpnmpcrqm5yjpjm5j28c6wf09",
     "extension": {
                  "image": null,
                  "image_data": null,
                  "external_url": "ipfs_url",
                  "description": "A Gray Powder Monkey Powder Boy With Navy Striped Tee",
                  "name": "Sparrowswap - Powder Monkeys",
                  "attributes": [
                                    {
                                      "trait_type": "Color",
                                      "value": "Gray"
                                    },
                                    {
                                      "trait_type": "Clothes",
                                      "value": "Navy Striped Tee"
                                    }
                                ],
                  "background_color": null,
                  "animation_url": null,
                  "youtube_url": null
                  },
     "token_id": "8",
     "token_uri": "QmSjxz3uJGRd6Xcgcr1aYzJbjN9LNrdqL5xwGdBg9UiEYB"
   }
}
'''

try:
    json_object = json.loads(json_string)
    print("No syntax errors found.")
except json.JSONDecodeError as e:
    print(f"Syntax error found: {e}")
