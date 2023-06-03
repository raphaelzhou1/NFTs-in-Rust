#!/bin/bash

pinata() {
  export workspace_root="$(git rev-parse --show-toplevel)"
  node "${workspace_root}/node_project/pinata-ipfs-scripts-for-nft-projects/src/upload-files.js"
  node "${workspace_root}/node_project/pinata-ipfs-scripts-for-nft-projects/src/download-cids.js"
  echo "Where to copy download-cids.json to ?"
  output_foldert=$(zenity --file-selection --directory --title="Select JSON folder" --filename="${workspace_root}/archives")
  cp "${workspace_root}/node_project/pinata-ipfs-scripts-for-nft-projects/output/downloaded-cids.json" $output_foldert
}

take_unique_json_files_to_create_many_metadata_json() {
  json_folder=$(zenity --file-selection --directory --title="Select JSON folder" --filename="${workspace_root}/")
  echo "How many metadata json files to create?: "
  read number_of_metadata_json_files

  output_folder=$(dirname "$json_folder")/powder_monkey_jsons
  rm -rf "$output_folder" && mkdir -p "$output_folder"

  shopt -s nullglob # Enable nullglob
  all_files=("$json_folder"/*.json)
  shopt -u nullglob # Disable nullglob
  total_files=${#all_files[@]}
  echo "Total files: $total_files"
  if [ $total_files -eq 0 ]; then
    echo "No JSON files found in the selected directory."
    return 1
  fi

  for (( index=1; index<=number_of_metadata_json_files; index++ ))
  do
    random_file_index=$(($RANDOM % total_files))
    echo "Copying ${all_files[$random_file_index]} to ${output_folder}/powder_monkey_${index}.json"
    cp "${all_files[$random_file_index]}" "${output_folder}/powder_monkey_${index}.json"
  done
}

RUM_combine_pinata_cids_and_midjourney_images_and_description_to_form_one_to_erc721_metadata_in_folder() {
  echo "Enter uuid file path (from midjourney): "
  uuid_path=$(zenity --file-selection --title="Select uuid (images' unique identifier) file (from midjourney)" --file-filter="*.csv" --filename="${workspace_root}/" --separator=",")
  echo "Enter downloaded_cids.json file path:"
  downloaded_cids_path=$(zenity --file-selection --title="Select downloaded_cids.json file from pinata" --file-filter="*.json" --filename="${workspace_root}/" --separator=",")
  output_folder=$(dirname "$downloaded_cids_path")/powder_monkey_images_json_unique
  rm -rf "$output_folder" && mkdir -p "$output_folder"

  fur_color_pattern="gray|yellow|blue|purple|green|orange|pink|red"
  ship_name_pattern="HMS_ENCORE|The_Queen_Anne's_Revenge|The_Jolly_Roger|The_Dying_Gull|The_Black_Pearl"
  background_colors_pattern="gray|yellow|blue|purple|green|orange|pink|red"

  index=1

  # Read CSV line by line
  while IFS=',' read -r uuid description
  do
    # Parse JSON and match keys with uuid
    while read -r key
    do
      cid=$(jq -r ".[\"$key\"]" $downloaded_cids_path)
      ipfs_url="https://gateway.pinata.cloud/ipfs/$cid"
      # Extract attributes using regex
      fur_color=$(echo "$description" | grep -oE "$fur_color_pattern" | head -n 1)
      ship_name=$(echo "$description" | grep -oE "$ship_name_pattern" | head -n 1)
      background_color=$(echo "$description" | grep -oE "$background_colors_pattern" | head -n 1)

      # Construct metadata JSON
      metadata=$(jq -n \
        --arg cid "$cid" \
        --arg fur_color "$fur_color" \
        --arg ship_name "$ship_name" \
        --arg background_color "$background_color" \
        --arg ipfs_url "$ipfs_url" \
       '{"animation_url": null, "attributes": [{"trait_type": "color", "value": $fur_color}, {"trait_type": "ship name", "value": $ship_name}, {"trait_type": "background color", "value": $background_color}], "description": "SparrowSwap April OG RUM collection", "external_url": $ipfs_url, "image": $ipfs_url, "name": "SparrowSwap April OG RUM", "youtube_url": null}')
#        '{CID: $cid, Metadata: {animation_url: null, attributes: [{trait_type: "color", value: $fur_color}, {trait_type: "ship name", value: $ship_name}, {trait_type: "clothes", value: $clothes}, {trait_type: "hat", value: $hat}, {trait_type: "action", value: $action}, {trait_type: "eye", value: $eye}, {trait_type: "mouth", value: $mouth}, {trait_type: "background color", value: $background_color}], description: "SparrowSwap collection", external_url: "$ipfs_url", image: "$ipfs_url", name: "Powder Monkey", youtube_url: null}}')
      echo $metadata > "${output_folder}/April_OG_RUM_${index}.json"
      let index+=1
    done < <(jq -r 'keys[]' $downloaded_cids_path | grep "^$uuid")
  done < $uuid_path
}

combine_pinata_cids_and_midjourney_images_and_description_to_form_one_to_erc721_metadata_in_folder() {
  uuid_path=$(zenity --file-selection --title="Select uuid (images' unique identifier) file (from midjourney)" --file-filter="*.csv" --filename="${workspace_root}/" --separator=",")
  downloaded_cids_path=$(zenity --file-selection --title="Select downloaded_cids.json file from pinata" --file-filter="*.json" --filename="${workspace_root}/" --separator=",")
  output_folder=$(dirname "$downloaded_cids_path")/powder_monkey_images_json_unique
  rm -rf "$output_folder" && mkdir -p "$output_folder"

  fur_color_pattern="gray|yellow|blue|purple|green|orange|pink|red"
  ship_name_pattern="HMS_ENCORE|The_Queen_Anne's_Revenge|The_Jolly_Roger|The_Dying_Gull|The_Black_Pearl"
  clothes_pattern="Navy_Striped_Tee_vest|a_ragged_vest|a_striped_shirt|a_captain's_coat|a_pirate_jacket"
  hats_pattern="a_seaman's_hat|a_bandana|a_tricorn_hat|a_captain's_hat|a_pirate's_hat"
  actions_pattern="watching_cannon_shots|swabbing_the_deck|loading_cannons|singing_sea_shanties|navigating_through_treacherous_waters|hoisting_the_Jolly_Roger|firing_cannons"
  eyes_pattern="round|narrow|squinty|wide|curious|sleepy"
  mouths_pattern="smiling|frowning|laughing|grinning|smirking|pouting"
  background_colors_pattern="gray|yellow|blue|purple|green|orange|pink|red"

  index=1

  # Read CSV line by line
  while IFS=',' read -r uuid description
  do
    # Parse JSON and match keys with uuid
    while read -r key
    do
      cid=$(jq -r ".[\"$key\"]" $downloaded_cids_path)
      ipfs_url="https://ipfs.filebase.io/ipfs/$cid"
      # Extract attributes using regex
      fur_color=$(echo "$description" | grep -oE "$fur_color_pattern" | head -n 1)
      ship_name=$(echo "$description" | grep -oE "$ship_name_pattern" | head -n 1)
      clothes=$(echo "$description" | grep -oE "$clothes_pattern" | head -n 1)
      hat=$(echo "$description" | grep -oE "$hats_pattern" | head -n 1)
      action=$(echo "$description" | grep -oE "$actions_pattern" | head -n 1)
      eye=$(echo "$description" | grep -oE "$eyes_pattern" | head -n 1)
      mouth=$(echo "$description" | grep -oE "$mouths_pattern" | head -n 1)
      background_color=$(echo "$description" | grep -oE "$background_colors_pattern" | head -n 1)

      # Construct metadata JSON
      metadata=$(jq -n \
        --arg cid "$cid" \
        --arg fur_color "$fur_color" \
        --arg ship_name "$ship_name" \
        --arg clothes "$clothes" \
        --arg hat "$hat" \
        --arg action "$action" \
        --arg eye "$eye" \
        --arg mouth "$mouth" \
        --arg background_color "$background_color" \
        --arg ipfs_url "$ipfs_url" \
         "{\"animation_url\": null, \"attributes\": [{\"trait_type\": \"color\", \"value\": \$fur_color}, {\"trait_type\": \"ship name\", \"value\": \$ship_name}, {\"trait_type\": \"clothes\", \"value\": \$clothes}, {\"trait_type\": \"hat\", \"value\": \$hat}, {\"trait_type\": \"action\", \"value\": \$action}, {\"trait_type\": \"eye\", \"value\": \$eye}, {\"trait_type\": \"mouth\", \"value\": \$mouth}, {\"trait_type\": \"background color\", \"value\": \$background_color}], \"description\": \"SparrowSwap collection\", \"external_url\": \$ipfs_url, \"image\": \$ipfs_url, \"name\": \"Powder Monkey\", \"youtube_url\": null}")
#        '{CID: $cid, Metadata: {animation_url: null, attributes: [{trait_type: "color", value: $fur_color}, {trait_type: "ship name", value: $ship_name}, {trait_type: "clothes", value: $clothes}, {trait_type: "hat", value: $hat}, {trait_type: "action", value: $action}, {trait_type: "eye", value: $eye}, {trait_type: "mouth", value: $mouth}, {trait_type: "background color", value: $background_color}], description: "SparrowSwap collection", external_url: "$ipfs_url", image: "$ipfs_url", name: "Powder Monkey", youtube_url: null}}')
      echo $metadata > "${output_folder}/powder_monkey_${index}.json"
      let index+=1
    done < <(jq -r 'keys[]' $downloaded_cids_path | grep "^$uuid")
  done < $uuid_path
}

combine_pinata_cids_and_midjourney_images_and_description_to_form_erc721_metadata_in_single_json() {
  uuid_path=$(zenity --file-selection --title="Select uuid (images' unique identifier) file (from midjourney)" --file-filter="*.csv" --filename="${workspace_root}/" --separator=",")
  downloaded_cids_path=$(zenity --file-selection --title="Select downloaded_cids.json file from pinata" --file-filter="*.json" --filename="${workspace_root}/" --separator=",")
  fur_color_pattern="gray|yellow|blue|purple|green|orange|pink|red"
  ship_name_pattern="HMS_ENCORE|The_Queen_Anne's_Revenge|The_Jolly_Roger|The_Dying_Gull|The_Black_Pearl"
  clothes_pattern="Navy_Striped_Tee_vest|a_ragged_vest|a_striped_shirt|a_captain's_coat|a_pirate_jacket"
  hats_pattern="a_seaman's_hat|a_bandana|a_tricorn_hat|a_captain's_hat|a_pirate's_hat"
  actions_pattern="watching_cannon_shots|swabbing_the_deck|loading_cannons|singing_sea_shanties|navigating_through_treacherous_waters|hoisting_the_Jolly_Roger|firing_cannons"
  eyes_pattern="round|narrow|squinty|wide|curious|sleepy"
  mouths_pattern="smiling|frowning|laughing|grinning|smirking|pouting"
  background_colors_pattern="gray|yellow|blue|purple|green|orange|pink|red"

  metadata_array=()

  # Read CSV line by line
  while IFS=',' read -r uuid description
  do
    # Parse JSON and match keys with uuid
    while read -r key
    do
      cid=$(jq -r ".[\"$key\"]" $downloaded_cids_path)
      ipfs_url="https://ipfs.filebase.io/ipfs/$cid"
      # Extract attributes using regex
      fur_color=$(echo "$description" | grep -oE "$fur_color_pattern" | head -n 1)
      ship_name=$(echo "$description" | grep -oE "$ship_name_pattern" | head -n 1)
      clothes=$(echo "$description" | grep -oE "$clothes_pattern" | head -n 1)
      hat=$(echo "$description" | grep -oE "$hats_pattern" | head -n 1)
      action=$(echo "$description" | grep -oE "$actions_pattern" | head -n 1)
      eye=$(echo "$description" | grep -oE "$eyes_pattern" | head -n 1)
      mouth=$(echo "$description" | grep -oE "$mouths_pattern" | head -n 1)
      background_color=$(echo "$description" | grep -oE "$background_colors_pattern" | head -n 1)

      # Construct metadata JSON
      metadata=$(jq -n \
        --arg cid "$cid" \
        --arg fur_color "$fur_color" \
        --arg ship_name "$ship_name" \
        --arg clothes "$clothes" \
        --arg hat "$hat" \
        --arg action "$action" \
        --arg eye "$eye" \
        --arg mouth "$mouth" \
        --arg background_color "$background_color" \
        --arg ipfs_url "$ipfs_url" \
         "{\"animation_url\": null, \"attributes\": [{\"trait_type\": \"color\", \"value\": \$fur_color}, {\"trait_type\": \"ship name\", \"value\": \$ship_name}, {\"trait_type\": \"clothes\", \"value\": \$clothes}, {\"trait_type\": \"hat\", \"value\": \$hat}, {\"trait_type\": \"action\", \"value\": \$action}, {\"trait_type\": \"eye\", \"value\": \$eye}, {\"trait_type\": \"mouth\", \"value\": \$mouth}, {\"trait_type\": \"background color\", \"value\": \$background_color}], \"description\": \"SparrowSwap collection\", \"external_url\": \$ipfs_url, \"image\": \$ipfs_url, \"name\": \"Powder Monkey\", \"youtube_url\": null}")
#        '{CID: $cid, Metadata: {animation_url: null, attributes: [{trait_type: "color", value: $fur_color}, {trait_type: "ship name", value: $ship_name}, {trait_type: "clothes", value: $clothes}, {trait_type: "hat", value: $hat}, {trait_type: "action", value: $action}, {trait_type: "eye", value: $eye}, {trait_type: "mouth", value: $mouth}, {trait_type: "background color", value: $background_color}], description: "SparrowSwap collection", external_url: "$ipfs_url", image: "$ipfs_url", name: "Powder Monkey", youtube_url: null}}')
      echo "Metadata: " "$metadata"
      metadata_array+=("$metadata")
    done < <(jq -r 'keys[]' $downloaded_cids_path | grep "^$uuid")
  done < $uuid_path

  metadata_json_array=$(printf '%s\n' "${metadata_array[@]}" | jq -s '.')
  echo $metadata_json_array > "${workspace_root}/archives/Powder_Monkeys/metadata.json"
}

deploy_cw1_whitelist() {
  export workspace_root="$(git rev-parse --show-toplevel)"
  export SCRIPT_NAME="$(basename "$0" .sh)"
  CACHE_DIR="${workspace_root}/bash_project/scripts/cache/Powder_Monkeys/${SCRIPT_NAME}_cache"
  if [ ! -d "$CACHE_DIR" ]; then
      mkdir -p "$CACHE_DIR"
  fi
  CACHE_FILE_FOR_CW1_ADDRESSES="${workspace_root}/bash_project/scripts/cache/Powder_Monkeys/${SCRIPT_NAME}_cache/${SCRIPT_NAME}_addresses.csv"
  while IFS=',' read -r col1 col2 col3; do # Internal Field Separator as ',' to read Comma-Separated Values
      if [[ "$col1" != "CW1 Address" ]]; then
          address_array+=("$col1")
      fi
      if [[ "$col2" != "Code ID" ]]; then
          code_id_array+=("$col2")
      fi
      if [[ "$col3" != "Description" ]]; then
          description_array+=("$col3")
      fi
  done < "$CACHE_FILE_FOR_CW1_ADDRESSES"
  if [[ "${#address_array[@]}" -gt 0 ]]; then
      for ((i=0; i<"${#address_array[@]}"; i++)); do
          echo "You have CW1 Address: ${address_array[$i]} at code id ${code_id_array[$i]} with description ${description_array[$i]}"
      done
  else
      echo "Unable to extract any addresses from the CSV file"
  fi

  CW1_PATH=$(zenity --file-selection --title="Select a WASM file" --file-filter="*.wasm" --filename="${workspace_root}/rust_project/" --separator=",")
  $SEID tx wasm store $CW1_PATH -y --chain-id $CHAIN_ID --from $ACCOUNT_ADDRESS --broadcast-mode=block --gas 16000000 --fees=1600000usei --node=$RPC
  export CW1_WHITELIST_CODE_ID=$($SEID q wasm list-code --output json --chain-id $CHAIN_ID --node=$RPC | jq -r '.code_infos[-1].code_id') # Store code_id for cw20_base.wasm

  export CW1_WHITELIST_INIT='{
      "admins": ["'"$ACCOUNT_ADDRESS"'"],
      "mutable": true
  }'
  yes | $SEID tx wasm instantiate $CW1_WHITELIST_CODE_ID "$CW1_WHITELIST_INIT" --chain-id $CHAIN_ID --from $ACCOUNT_ADDRESS --broadcast-mode=block --admin $ACCOUNT_ADDRESS --label $CW721 --gas 170000 --fees=17000usei --node=$RPC
  echo "Terminal command: $SEID tx wasm instantiate $CW1_WHITELIST_CODE_ID \"$CW1_WHITELIST_INIT\" --chain-id $CHAIN_ID --from $ACCOUNT_ADDRESS --broadcast-mode=block --admin $ACCOUNT_ADDRESS --label $CW721 --gas $GAS --fees=$FEES --node=$RPC"
  export CW1_WHITELIST_ADDRESS=$($SEID q wasm list-contract-by-code $CW1_WHITELIST_CODE_ID --output json --chain-id $CHAIN_ID --node=$RPC | jq -r '.contracts[-1]')
  if [[ -z "$CW1_WHITELIST_ADDRESS" ]]; then
      echo "Empty address error"
      exit 1
  fi

  echo "We got CW1 address " $CW1_WHITELIST_ADDRESS
  echo "Enter description for this CW1: "
  read Description
  echo "$CW721_BASE_ADDRESS,$CW721_BASE_CODE_ID,$Description" >> "$CW1_PATH"
}

csv_to_json() {
  file=$(zenity --file-selection --title="Select a CSV File")
  columns=$(head -n 1 "$file" | tr ',' ' ')
  echo "$columns"
  echo "Select a column to output to JSON"
  IFS=', ' read -r array <<< "$(head -n 1 "$file")" # Read first line of CSV file into "array" variable
  echo "${array[@]}"
  column=$(zenity --list --column=Columns "${array[@]}")
  col_num=$(echo "$columns" | grep -n "^$column$" | cut -d: -f1)

  # Read and parse CSV data and output to a JSON file
  awk -F ',' -v col_num="$col_num" 'NR>1 {print $col_num}' "$file" |
  jq -R . |
  echo "Where to output JSON"
  ADDRESS_JSON_FOLDER=$(zenity --file-selection --title="Select a Folder" --directory)
  jq -s . > ${ADDRESS_JSON_FOLDER}/output.json

}

deploy_cw721_contract() {
    echo 'Enter CW721 contract name: '
    read CW721
    echo 'Enter CW721 collection symbol: '
    read CW721_SYMBOL
    export CW721_BASE_INIT='{
        "minter": "'$ACCOUNT_ADDRESS'",
        "name": "'"$CW721"'",
        "symbol": "'"$CW721_SYMBOL"'"
    }'
    echo 'export CW721_BASE_INIT='\'$CW721_BASE_INIT\' >> testnet_deploy_atlantic-2_log.txt

    export workspace_root="$(git rev-parse --show-toplevel)"
    FUNCTION_NAME="deploy_cw721_base"
    echo "Choose .wasm file to load CW721 contract"
    CW721_path=$(zenity --file-selection --title="Select a WASM file" --file-filter="*.wasm" --filename="${workspace_root}/" --separator=",")
    $SEID tx wasm store $CW721_path -y --chain-id $CHAIN_ID --from $ACCOUNT_ADDRESS --broadcast-mode=block --gas 5097656 --fees=509765usei --node=$RPC
    export CW721_BASE_CODE_ID=$($SEID q wasm list-code --output json --chain-id $CHAIN_ID --node=$RPC --limit 900 | jq -r '.code_infos[-1].code_id') # Store code_id for cw20_base.wasm
    echo "You got CW721 code id " $CW721_BASE_CODE_ID
#    echo 'export CW721_BASE_CODE_ID='$CW721_BASE_CODE_ID >> ${workspace_root}/testnet_deploy_atlantic-2_log.txt

    yes | $SEID tx wasm instantiate $CW721_BASE_CODE_ID "$CW721_BASE_INIT" --chain-id $CHAIN_ID --from $ACCOUNT_ADDRESS --broadcast-mode=block --admin $ACCOUNT_ADDRESS --label $CW721 --gas 170000 --fees=17000usei --node=$RPC
    export CW721_BASE_ADDRESS=$($SEID q wasm list-contract-by-code $CW721_BASE_CODE_ID --output json --chain-id $CHAIN_ID --node=$RPC | jq -r '.contracts[-1]')
    echo "You got CW721 address " $CW721_BASE_ADDRESS
#    echo "You got CW721 address " $CW721_BASE_ADDRESS
}

#deploy_cw721_base() {
#  echo "Type in cw721_base if you have it; otherwise, type empty"
#  read $CW721_BASE_ADDRESS
#  if [[ -z $CW721_BASE_ADDRESS ]]; then
#    echo 'Must be in workspace of cw-nft repo to be able to store w721_base.wasm'
#    echo 'Enter CW721 collection name: '
#    read CW721
#    echo 'Enter CW721 collection symbol: '
#    read CW721_SYMBOL
#    export CW721_BASE_INIT='{
#        "minter": "'$ACCOUNT_ADDRESS'",
#        "name": "'"$CW721"'",
#        "symbol": "'"$CW721_SYMBOL"'"
#    }'
#    echo 'export CW721_BASE_INIT='\'$CW721_BASE_INIT\' >> testnet_deploy_atlantic-2_log.txt
#
#    export workspace_root="$(git rev-parse --show-toplevel)"
#    FUNCTION_NAME="deploy_cw721_base"
#    echo "Choose .wasm file to load CW721 contract"
#    CW721_path=$(zenity --file-selection --title="Select a WASM file" --file-filter="*.wasm" --filename="${workspace_root}/" --separator=",")
#    $SEID tx wasm store $CW721_path -y --chain-id $CHAIN_ID --from $ACCOUNT_ADDRESS --broadcast-mode=block --gas 16000000 --fees=1600000usei --node=$RPC
#    export CW721_BASE_CODE_ID=$($SEID q wasm list-code --output json --chain-id $CHAIN_ID --node=$RPC --limit 300 | jq -r '.code_infos[-1].code_id') # Store code_id for cw20_base.wasm
#    echo 'export CW721_BASE_CODE_ID='$CW721_BASE_CODE_ID >> ${workspace_root}/testnet_deploy_atlantic-2_log.txt
#
#    $SEID tx wasm instantiate $CW721_BASE_CODE_ID "$CW721_BASE_INIT" --chain-id $CHAIN_ID --from $ACCOUNT_ADDRESS --broadcast-mode=block --admin $ACCOUNT_ADDRESS --label $CW721_SYMBOL --gas 170000 --fees=17000usei --node=$RPC
#    export CW721_BASE_ADDRESS=$($SEID q wasm list-contract-by-code $CW721_BASE_CODE_ID --output json --chain-id $CHAIN_ID --node=$RPC | jq -r '.contracts[-1]')
#    if test - z $CW721_BASE_ADDRESS
#    then
#      export CW721_BASE_ADDRESS="sei13h9k5rsrgveg6sdtzg34qg499ns0e5kku74kapnskegtwyfspf6qcqgjyh"
#      echo 'export CW721_BASE_ADDRESS='$CW721_BASE_ADDRESS'#Previous CW721_BASE_ADDRESS' >> testnet_deploy_atlantic-2_log.txt
#    else
#      export CW721_BASE_ADDRESS=$($SEID q wasm list-contract-by-code $CW721_BASE_CODE_ID --output json --chain-id $CHAIN_ID --node=$RPC | jq -r '.contracts[-1]')
#      echo 'export CW721_BASE_ADDRESS='$CW721_BASE_ADDRESS >> testnet_deploy_atlantic-2_log.txt
#    fi
#  fi
#
#  CACHE_FILE_FOR_CW721_BASE_ADDRESS="${CACHE_DIR}/${FUNCTION_NAME}_cache_for_token_id.txt"
#  if [ ! -f "$CACHE_FILE_FOR_CW721_BASE_ADDRESS" ]; then
#      echo $CW721_BASE_ADDRESS >> "$CACHE_FILE_FOR_CW721_BASE_ADDRESS"
#  fi
#  CW721_BASE_ADDRESS=$(tail -n 1 "$CACHE_FILE_FOR_CW721_BASE_ADDRESS") # reads last row
#  echo "Reading CACHE_FILE_FOR_CW721_BASE_ADDRESS at " $CACHE_FILE_FOR_CW721_BASE_ADDRESS ", with CW721: " $CW721_BASE_ADDRESS
#}

mint_nft() {
  echo "Enter the address to mint NFTs for: "
  read ADDRESS_TO_MINT_NFTs_FOR
  if [[ -z "$token_id" ]]; then
    ADDRESS_TO_MINT_NFTs_FOR="$ACCOUNT_ADDRESS"
  fi
  echo "You entered: $ADDRESS_TO_MINT_NFTs_FOR"

  echo "Enter the token url: "
  read token_uri
  echo "You entered: $token_uri"

  echo "Enter the token id: "
  read token_id
  if [[ -z "$token_id" ]]; then
    QUERIED_ADDRESS=$ADDRESS_TO_MINT_NFTs_FOR
    CW721_QUERY_WITH_ADDRESS='{
        "tokens": {
          "owner": "'$QUERIED_ADDRESS'"
        }
    }'
    TOKEN_IDs_IN_JSON=$($SEID q wasm contract-state smart $CW721_BASE_ADDRESS "$CW721_QUERY_WITH_ADDRESS" --output json --chain-id $CHAIN_ID --node=$RPC | jq -r '.data.tokens')
    echo $TOKEN_IDs_IN_JSON
    declare -a TOKEN_IDs_In_ARRAY
    TOKEN_IDs_In_ARRAY=()
    for index in $(seq 0 $(echo "$TOKEN_IDs_IN_JSON" | jq 'length-1')); do
        element=$(echo "$TOKEN_IDs_IN_JSON" | jq -r --argjson index "$index" '.[$index]')
        TOKEN_IDs_In_ARRAY+=("$element")
    done
    echo $TOKEN_IDs_In_ARRAY
    token_id="NFT_$(( ${#TOKEN_IDs_In_ARRAY[@]} + 1 ))"
  fi
  echo "You entered: $token_id"

  export CW721_BASE_MINT='{
     "mint": {
       "owner": '$ADDRESS_TO_MINT_NFTs_FOR',
       "extension": {},
       "token_id": "'$token_id'",
       "token_uri": "https://ipfs.filebase.io/ipfs/QmUvS2soyQb8CLFMBPrVoBEDjfFpHpYxhC3Va3Z6bMFLq1"
     }
  }'

  ATTEMPT=0
  GAS=200000
  FEES=20000
  while true; do
    echo $SEID tx wasm execute $CW721_BASE_ADDRESS "$CW721_BASE_MINT" --chain-id $CHAIN_ID --from $ACCOUNT_ADDRESS --broadcast-mode=block --gas $GAS --fees=${FEES}usei --node=$RPC
    yes | $SEID tx wasm execute $CW721_BASE_ADDRESS "$CW721_BASE_MINT" --chain-id $CHAIN_ID --from $ACCOUNT_ADDRESS --broadcast-mode=block --gas $GAS --fees=${FEES}usei --node=$RPC
    OUTPUT=$(yes | $SEID tx wasm execute $CW721_BASE_ADDRESS "$CW721_BASE_MINT" --chain-id $CHAIN_ID --from $ACCOUNT_ADDRESS --broadcast-mode=block --gas $GAS --fees=${FEES}usei --node=$RPC 2>&1)

    if [[ "$OUTPUT" == *"incorrect account sequence"* || "$OUTPUT" == *"out of gas"* ]]; then
      if [ $ATTEMPT -lt 1 ]; then
        GAS=$((GAS + 100000))
        FEES=$((FEES + 10000))
        ATTEMPT=$((ATTEMPT + 1))
      else
        GAS=400000
        FEES=40000
        ATTEMPT=0
      fi
    else
      break
    fi
  done
}

#!/bin/bash
mint_nft_from_csv() {
  echo "Enter the CW721 contract address: "
  read CW721_BASE_ADDRESS
  export workspace_root="$(git rev-parse --show-toplevel)"
  FUNCTION_NAME="mint_nft_from_csv"
  echo "Choose CSV to load ADDRESS_TO_MINT_NFTs_FOR"
  ADDRESS_CSV_FILE=$(zenity --file-selection --title="Select a CSV file" --file-filter="*.csv" --filename="${workspace_root}/" --separator=",")
  total_rows=$(wc -l < "$ADDRESS_CSV_FILE")
  echo "Total rows: $total_rows"

  column_index=$(python ${workspace_root}/bash_project/scripts/functions_helper.py mint_nft_from_csv_helper "$ADDRESS_CSV_FILE")
  echo "Selected column index: $column_index"

  SCRIPT_NAME="$(basename "$0" .sh)"
  CACHE_DIR="${workspace_root}/bash_project/scripts/cache/Powder_Monkeys/${SCRIPT_NAME}_cache"
  if [ ! -d "$CACHE_DIR" ]; then
      mkdir -p "$CACHE_DIR"
  fi
  ADDRESS_CSV_FILE_FILENAME=$(basename "$ADDRESS_CSV_FILE")
  ADDRESS_CSV_FILE_FILENAME_NO_EXTENSION="${ADDRESS_CSV_FILE_FILENAME%.*}"
  CACHE_FILE_FOR_CSV_ADDRESS_COPY="${CACHE_DIR}/${FUNCTION_NAME}_cache_for_${ADDRESS_CSV_FILE_FILENAME_NO_EXTENSION}_csv_copy.txt"
  if [ ! -f "$CACHE_FILE_FOR_CSV_ADDRESS_COPY" ]; then
    cp "$ADDRESS_CSV_FILE" "$CACHE_FILE_FOR_CSV_ADDRESS_COPY" # Copy so $ADDRESS_CSV_FILE should not be touched again
  fi
  CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER="${CACHE_DIR}/${FUNCTION_NAME}_cache_for_${ADDRESS_CSV_FILE_FILENAME_NO_EXTENSION}_csv_copy_row_counter.txt"
  if [ ! -f "$CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER" ]; then
      echo "1" >> "$CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER"
  fi
  START_ROW=$(tail -n 1 "$CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER") # reads last row
  ROW_COUNTER=$START_ROW
  echo "Reading CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER at " $CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER ", starting from row " $START_ROW

  IPFS_CID_JSON_FILE="${workspace_root}/bash_project/test.json"

  IPFS_CID_JSON_FILE=$(zenity --file-selection --title="Select a JSON file" --file-filter="*.json" --filename="${workspace_root}/node_project/pinata-ipfs-scripts-for-nft-projects/output" --separator=",")
  IPFS_CID_JSON_FILE_FILENAME=$(basename "$IPFS_CID_JSON_FILE")
  IPFS_CID_JSON_FILE_FILENAME_NO_EXTENSION="${IPFS_CID_JSON_FILE_FILENAME%.*}"
  CACHE_FILE_FOR_IPFS_CID_JSON_FILE_COPY="${CACHE_DIR}/${FUNCTION_NAME}_cache_for_${IPFS_CID_JSON_FILE_FILENAME_NO_EXTENSION}_csv_copy.txt"
  if [ ! -f "$CACHE_FILE_FOR_IPFS_CID_JSON_FILE_COPY" ]; then
    cp "$IPFS_CID_JSON_FILE" "$CACHE_FILE_FOR_IPFS_CID_JSON_FILE_COPY" # Copy so $IPFS_CID_JSON_FILE should not be touched again
  fi
  IPFS_FILE_NAMEs=($(jq -r 'keys[]' "$CACHE_FILE_FOR_IPFS_CID_JSON_FILE_COPY"))
  IPFS_CIDs=($(jq -r '.[]' "$CACHE_FILE_FOR_IPFS_CID_JSON_FILE_COPY"))
  num_items=$((${#IPFS_FILE_NAMEs[@]}))
  echo "Total IPFS FILE_NAME-CID pairs: $num_items"
  BASE_URL="https://ipfs.filebase.io/ipfs/"

  CACHE_FILE_FOR_TOKEN_ID="${CACHE_DIR}/${FUNCTION_NAME}_cache_for_token_id.txt"
  if [ ! -f "$CACHE_FILE_FOR_TOKEN_ID" ]; then
      echo "1" >> "$CACHE_FILE_FOR_TOKEN_ID"
  fi
  START_TOKEN_ID=$(tail -n 1 "$CACHE_FILE_FOR_TOKEN_ID") # reads last row
  TOKEN_ID_COUNTER=$START_TOKEN_ID
  echo "Reading CACHE_FILE_FOR_TOKEN_ID at " $CACHE_FILE_FOR_TOKEN_ID ", starting from row " $START_ROW " and from token_id" $START_TOKEN_ID

  awk -v column_index="$column_index" -v START_ROW="$START_ROW" -F, 'NR>START_ROW {print $(column_index)}' "$CACHE_FILE_FOR_CSV_ADDRESS_COPY" | while read -r ADDRESS_TO_MINT_NFTs_FOR; do
    echo "You entered: $ADDRESS_TO_MINT_NFTs_FOR"

    random_index=$(( ($RANDOM % num_items) + 1))
    echo "Random index: " $random_index
    selected_IPFS_FILE_NAME=${IPFS_FILE_NAMEs[$random_index]}
    selected_IPFS_CID=${IPFS_CIDs[$random_index]}
    ipfs_url="${BASE_URL}${selected_IPFS_CID}"
    description=$(echo "$selected_IPFS_FILE_NAME" | sed -E 's/^[^_]*_//; s/_ve.*//; s/_/ /g; s/([a-z])([A-Z])/\1 \2/g' | awk '{for (i=1; i<=NF; i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')
    color=$(echo "$description" | awk 'match(tolower($0), /gray|yellow|blue|purple|green|orange|pink|red/) {print substr($0, RSTART, RLENGTH)}')
    clothes=$(echo "$description" | awk 'match(tolower($0), /navy striped tee|a ragged vest|a striped shirt|a captain\x27s coat|a pirate jacket/) {print substr($0, RSTART, RLENGTH)}')
    echo "Randomly selected pair:"
#    echo "IPFS FILE NAME: $selected_IPFS_FILE_NAME"
#    echo "IPFS CID: $selected_IPFS_CID"
#    echo "Token ID: $TOKEN_ID_COUNTER"
#    echo "IPFS URL: $ipfs_url"
    export CW721_BASE_MINT='{
       "mint": {
         "owner": "'$ADDRESS_TO_MINT_NFTs_FOR'",
         "extension": {
                      "image": null,
                      "image_data": null,
                      "external_url": "'$ipfs_url'",
                      "description": "'$description'",
                      "name": "SparrowSwap - Powder Monkeys",
                      "attributes": [
                                        {
                                          "trait_type": "Color",
                                          "value": "'$color'"
                                        },
                                        {
                                          "trait_type": "Clothes",
                                          "value": "'$clothes'"
                                        }
                                    ],
                      "background_color": null,
                      "animation_url": null,
                      "youtube_url": null
                      },
         "token_id": "'$TOKEN_ID_COUNTER'",
         "token_uri": "'$selected_IPFS_CID'"
       }
    }'

    ATTEMPT=0
    GAS=500000
    FEES=50000

#    OUTPUT_FILE=$(mktemp)
#    echo $SEID tx wasm execute $CW721_BASE_ADDRESS "$CW721_BASE_MINT" --chain-id $CHAIN_ID --from $ACCOUNT_ADDRESS --broadcast-mode=block --gas $GAS --fees=${FEES}usei --node=$RPC
#    yes | $SEID tx wasm execute $CW721_BASE_ADDRESS "$CW721_BASE_MINT" --chain-id $CHAIN_ID --from $ACCOUNT_ADDRESS --broadcast-mode=block --gas $GAS --fees=${FEES}usei --node=$RPC > $OUTPUT_FILE 2>&1 &
#    CMD_PID=$!
    sleep_time=4
    while true; do
      if grep -q -e "raw_log:" -e "Error:" <<<"$OUTPUT"; then
        echo "Output fetched successfully: "
        echo "Output?: " $OUTPUT
        echo "End of output"
        break
      fi
      OUTPUT_FILE=$(mktemp) # if use the same variable name (e.g., OUTPUT_FILE) for each temporary file, the previous value of the variable will be overwritten
      OUTPUT=$(cat $OUTPUT_FILE)
      echo "Terminal command: ${SEID} tx wasm execute ${CW721_BASE_ADDRESS} \"${CW721_BASE_MINT}\" --chain-id ${CHAIN_ID} --from ${ACCOUNT_ADDRESS} --broadcast-mode=block --gas ${GAS} --fees=${FEES}usei --node=${RPC}"
      echo "Terminal command response: "
      yes | $SEID tx wasm execute $CW721_BASE_ADDRESS "$CW721_BASE_MINT" --chain-id $CHAIN_ID --from $ACCOUNT_ADDRESS --broadcast-mode=block --gas $GAS --fees=${FEES}usei --node=$RPC > $OUTPUT_FILE 2>&1 &
      CMD_PID=$!
      sleep_time=$((sleep_time + 1))
      echo "Sleeping for " $sleep_time " seconds"
      sleep ${sleep_time}
      kill $CMD_PID >/dev/null 2>&1 || true
      OUTPUT=$(cat $OUTPUT_FILE)
      rm $OUTPUT_FILE
      echo "Output?: " $OUTPUT
      echo "End of output"
    done
#    sleep 6
#    kill $CMD_PID >/dev/null 2>&1 || true
#    OUTPUT=$(cat $OUTPUT_FILE)
#    rm $OUTPUT_FILE
#    echo "Output?: " $OUTPUT
#    echo "End of output"

    while [[ "$OUTPUT" == *"incorrect account sequence"* || "$OUTPUT" == *"out of gas"* || "$OUTPUT" == *"insufficient funds"* ]]; do
      GAS=$((GAS + 100000))
      FEES=$((FEES + 10000))
      ATTEMPT=$((ATTEMPT + 1))
      echo "Increase gas fee with attempt " $ATTEMPT
      echo "Terminal command: ${SEID} tx wasm execute ${CW721_BASE_ADDRESS} \"${CW721_BASE_MINT}\" --chain-id ${CHAIN_ID} --from ${ACCOUNT_ADDRESS} --broadcast-mode=block --gas ${GAS} --fees=${FEES}usei --node=${RPC}"

#      OUTPUT_FILE=$(mktemp)
#      yes | $SEID tx wasm execute $CW721_BASE_ADDRESS "$CW721_BASE_MINT" --chain-id $CHAIN_ID --from $ACCOUNT_ADDRESS --broadcast-mode=block --gas $GAS --fees=${FEES}usei --node=$RPC > $OUTPUT_FILE 2>&1 &
#      CMD_PID=$!
#      while true; do
#        OUTPUT=$(cat $OUTPUT_FILE)
#        if grep -q -e "raw_log:" -e "Error:" <<<"$OUTPUT"; then
#          break
#        fi
#        echo "Output?: " $OUTPUT
#        echo "End of output"
#        sleep 1
#      done
      while true; do
        if grep -q -e "raw_log:" -e "Error:" <<<"$OUTPUT"; then
          echo "Output fetched successfully: "
          echo "Output?: " $OUTPUT
          echo "End of output"
          break
        fi
        OUTPUT_FILE=$(mktemp) # if use the same variable name (e.g., OUTPUT_FILE) for each temporary file, the previous value of the variable will be overwritten
        OUTPUT=$(cat $OUTPUT_FILE)
        echo "Terminal command response: "
        yes | $SEID tx wasm execute $CW721_BASE_ADDRESS "$CW721_BASE_MINT" --chain-id $CHAIN_ID --from $ACCOUNT_ADDRESS --broadcast-mode=block --gas $GAS --fees=${FEES}usei --node=$RPC > $OUTPUT_FILE 2>&1 &
        CMD_PID=$!
        sleep_time=$((sleep_time + 1))
        echo "Sleeping for " $sleep_time " seconds"
        sleep ${sleep_time}
        kill $CMD_PID >/dev/null 2>&1 || true
        OUTPUT=$(cat $OUTPUT_FILE)
        rm $OUTPUT_FILE
        echo "Output?: " $OUTPUT
        echo "End of output"
      done

      if [[ GAS -gt 1000000 ]]; then
        echo "Too much GAS tried, probably not the reason why transaction failed"
        exit 1
      fi
    done

    if grep -q -e "Error: " <<<"$OUTPUT"; then
      echo "Error in Output, so exit; repeat error response: " $OUTPUT
      exit 1
    fi

    if [ $? -eq 0 ]; then
      echo "Exit status: " $?
      echo "Output? " $OUTPUT
      if [ "$ROW_COUNTER" -lt "$total_rows" ]; then
        ROW_COUNTER=$((ROW_COUNTER + 1))
      fi
      if [[ "$ROW_COUNTER" == "$total_rows" ]]; then
        exit 1
      fi
      echo "$ROW_COUNTER" >> "$CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER"
      TOKEN_ID_COUNTER=$((TOKEN_ID_COUNTER + 1))
      echo "$TOKEN_ID_COUNTER" >> "$CACHE_FILE_FOR_TOKEN_ID"
      echo "Successfully minted NFT $TOKEN_ID_COUNTER for $ADDRESS_TO_MINT_NFTs_FOR" " ROW_COUNTER = $ROW_COUNTER"
    fi

  done # reads the next line of $ADDRESS_CSV_FILE
}


#!/bin/bash
mint_nft_from_json_on_cw721_metadata_onchain() {
  echo "Enter the CW721 contract address: "
  read CW721_BASE_ADDRESS
  export workspace_root="$(git rev-parse --show-toplevel)"
  FUNCTION_NAME="mint_nft_from_csv"
  echo "Choose JSON to load ADDRESS_TO_MINT_NFTs_FOR"
  ADDRESS_CSV_FILE=$(zenity --file-selection --title="Select a CSV file" --file-filter="*.json" --filename="${workspace_root}/" --separator=",")
  total_rows=$(wc -l < "$ADDRESS_CSV_FILE")
  echo "Total rows: $total_rows"

  column_index=$(python ${workspace_root}/bash_project/scripts/functions_helper.py mint_nft_from_csv_helper "$ADDRESS_CSV_FILE")
  echo "Selected column index: $column_index"

  SCRIPT_NAME="$(basename "$0" .sh)"
  CACHE_DIR="${workspace_root}/bash_project/scripts/cache/Powder_Monkeys/${SCRIPT_NAME}_cache"
  if [ ! -d "$CACHE_DIR" ]; then
      mkdir -p "$CACHE_DIR"
  fi
  ADDRESS_CSV_FILE_FILENAME=$(basename "$ADDRESS_CSV_FILE")
  ADDRESS_CSV_FILE_FILENAME_NO_EXTENSION="${ADDRESS_CSV_FILE_FILENAME%.*}"
  CACHE_FILE_FOR_JSON_ADDRESS_COPY="${CACHE_DIR}/${FUNCTION_NAME}_cache_for_${ADDRESS_CSV_FILE_FILENAME_NO_EXTENSION}_json_copy.txt"
  if [ ! -f "$CACHE_FILE_FOR_JSON_ADDRESS_COPY" ]; then
    cp "$ADDRESS_CSV_FILE" "$CACHE_FILE_FOR_JSON_ADDRESS_COPY" # Copy so $ADDRESS_CSV_FILE should not be touched again
  fi
  length=$(echo $JSON_DATA | jq '. | length')
  JSON_DATA=$(cat $CACHE_FILE_FOR_JSON_ADDRESS_COPY)
  CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER="${CACHE_DIR}/${FUNCTION_NAME}_cache_for_${ADDRESS_CSV_FILE_FILENAME_NO_EXTENSION}_csv_copy_row_counter.txt"
  if [ ! -f "$CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER" ]; then
      echo "1" >> "$CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER"
  fi
  START_ROW=$(tail -n 1 "$CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER") # reads last row
  ROW_COUNTER=$START_ROW
  echo "Reading CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER at " $CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER ", starting from row " $START_ROW

  IPFS_CID_JSON_FILE=$(zenity --file-selection --title="Select a JSON file" --file-filter="*.json" --filename="${workspace_root}/node_project/pinata-ipfs-scripts-for-nft-projects/output" --separator=",")
  IPFS_CID_JSON_FILE_FILENAME=$(basename "$IPFS_CID_JSON_FILE")
  IPFS_CID_JSON_FILE_FILENAME_NO_EXTENSION="${IPFS_CID_JSON_FILE_FILENAME%.*}"
  CACHE_FILE_FOR_IPFS_CID_JSON_FILE_COPY="${CACHE_DIR}/${FUNCTION_NAME}_cache_for_${IPFS_CID_JSON_FILE_FILENAME_NO_EXTENSION}_csv_copy.txt"
  if [ ! -f "$CACHE_FILE_FOR_IPFS_CID_JSON_FILE_COPY" ]; then
    cp "$IPFS_CID_JSON_FILE" "$CACHE_FILE_FOR_IPFS_CID_JSON_FILE_COPY" # Copy so $IPFS_CID_JSON_FILE should not be touched again
  fi
  IPFS_FILE_NAMEs=($(jq -r 'keys[]' "$CACHE_FILE_FOR_IPFS_CID_JSON_FILE_COPY"))
  IPFS_CIDs=($(jq -r '.[]' "$CACHE_FILE_FOR_IPFS_CID_JSON_FILE_COPY"))
  num_items=$((${#IPFS_FILE_NAMEs[@]}))
  echo "Total IPFS FILE_NAME-CID pairs: $num_items"
  BASE_URL="https://ipfs.filebase.io/ipfs/"

  CACHE_FILE_FOR_TOKEN_ID="${CACHE_DIR}/${FUNCTION_NAME}_cache_for_token_id.txt"
  if [ ! -f "$CACHE_FILE_FOR_TOKEN_ID" ]; then
      echo "1" >> "$CACHE_FILE_FOR_TOKEN_ID"
  fi
  START_TOKEN_ID=$(tail -n 1 "$CACHE_FILE_FOR_TOKEN_ID") # reads last row
  TOKEN_ID_COUNTER=$START_TOKEN_ID
  echo "Reading CACHE_FILE_FOR_TOKEN_ID at " $CACHE_FILE_FOR_TOKEN_ID ", starting from row " $START_ROW " and from token_id" $START_TOKEN_ID

  # Iterate JSON file of ADDRESS_TO_MINT_NFTs_FOR
  for (( i=0; i<$length; i++ ))
  do
    ADDRESS_TO_MINT_NFTs_FOR=$(echo $JSON_DATA | jq -r ".[$i]")
    echo "You entered: $ADDRESS_TO_MINT_NFTs_FOR"

    random_index=$(( ($RANDOM % num_items) + 1))
    echo "Random index: " $random_index
    selected_IPFS_FILE_NAME=${IPFS_FILE_NAMEs[$random_index]}
    selected_IPFS_CID=${IPFS_CIDs[$random_index]}
    ipfs_url="${BASE_URL}${selected_IPFS_CID}"
    description=$(echo "$selected_IPFS_FILE_NAME" | sed -E 's/^[^_]*_//; s/_ve.*//; s/_/ /g; s/([a-z])([A-Z])/\1 \2/g' | awk '{for (i=1; i<=NF; i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')
    color=$(echo "$description" | awk 'match(tolower($0), /gray|yellow|blue|purple|green|orange|pink|red/) {print substr($0, RSTART, RLENGTH)}')
    clothes=$(echo "$description" | awk 'match(tolower($0), /navy striped tee|a ragged vest|a striped shirt|a captain\x27s coat|a pirate jacket/) {print substr($0, RSTART, RLENGTH)}')
    echo "Randomly selected pair:"
#    echo "IPFS FILE NAME: $selected_IPFS_FILE_NAME"
#    echo "IPFS CID: $selected_IPFS_CID"
#    echo "Token ID: $TOKEN_ID_COUNTER"
#    echo "IPFS URL: $ipfs_url"
    export CW721_BASE_MINT='{
       "mint": {
         "owner": "'$ADDRESS_TO_MINT_NFTs_FOR'",
         "extension": {
                      "image": null,
                      "image_data": null,
                      "external_url": "'$ipfs_url'",
                      "description": "'$description'",
                      "name": "SparrowSwap - Powder Monkeys",
                      "attributes": [
                                        {
                                          "trait_type": "Color",
                                          "value": "'$color'"
                                        },
                                        {
                                          "trait_type": "Clothes",
                                          "value": "'$clothes'"
                                        }
                                    ],
                      "background_color": null,
                      "animation_url": null,
                      "youtube_url": null
                      },
         "token_id": "'$TOKEN_ID_COUNTER'",
         "token_uri": "'$selected_IPFS_CID'"
       }
    }'

    ATTEMPT=0
    GAS=500000
    FEES=50000

#    OUTPUT_FILE=$(mktemp)
#    echo $SEID tx wasm execute $CW721_BASE_ADDRESS "$CW721_BASE_MINT" --chain-id $CHAIN_ID --from $ACCOUNT_ADDRESS --broadcast-mode=block --gas $GAS --fees=${FEES}usei --node=$RPC
#    yes | $SEID tx wasm execute $CW721_BASE_ADDRESS "$CW721_BASE_MINT" --chain-id $CHAIN_ID --from $ACCOUNT_ADDRESS --broadcast-mode=block --gas $GAS --fees=${FEES}usei --node=$RPC > $OUTPUT_FILE 2>&1 &
#    CMD_PID=$!
    sleep_time=4
    while true; do
      if grep -q -e "raw_log:" -e "Error:" <<<"$OUTPUT"; then
        echo "Output fetched successfully: "
        echo "Output?: " $OUTPUT
        echo "End of output"
        break
      fi
      OUTPUT_FILE=$(mktemp) # if use the same variable name (e.g., OUTPUT_FILE) for each temporary file, the previous value of the variable will be overwritten
      OUTPUT=$(cat $OUTPUT_FILE)
      echo "Terminal command: ${SEID} tx wasm execute ${CW721_BASE_ADDRESS} \"${CW721_BASE_MINT}\" --chain-id ${CHAIN_ID} --from ${ACCOUNT_ADDRESS} --broadcast-mode=block --gas ${GAS} --fees=${FEES}usei --node=${RPC}"
      echo "Terminal command response: "
      yes | $SEID tx wasm execute $CW721_BASE_ADDRESS "$CW721_BASE_MINT" --chain-id $CHAIN_ID --from $ACCOUNT_ADDRESS --broadcast-mode=block --gas $GAS --fees=${FEES}usei --node=$RPC > $OUTPUT_FILE 2>&1 &
      CMD_PID=$!
      sleep_time=$((sleep_time + 1))
      echo "Sleeping for " $sleep_time " seconds"
      sleep ${sleep_time}
      kill $CMD_PID >/dev/null 2>&1 || true
      OUTPUT=$(cat $OUTPUT_FILE)
      rm $OUTPUT_FILE
      echo "Output?: " $OUTPUT
      echo "End of output"
    done
#    sleep 6
#    kill $CMD_PID >/dev/null 2>&1 || true
#    OUTPUT=$(cat $OUTPUT_FILE)
#    rm $OUTPUT_FILE
#    echo "Output?: " $OUTPUT
#    echo "End of output"

    while [[ "$OUTPUT" == *"incorrect account sequence"* || "$OUTPUT" == *"out of gas"* || "$OUTPUT" == *"insufficient funds"* ]]; do
      GAS=$((GAS + 100000))
      FEES=$((FEES + 10000))
      ATTEMPT=$((ATTEMPT + 1))
      echo "Increase gas fee with attempt " $ATTEMPT
      echo "Terminal command: ${SEID} tx wasm execute ${CW721_BASE_ADDRESS} \"${CW721_BASE_MINT}\" --chain-id ${CHAIN_ID} --from ${ACCOUNT_ADDRESS} --broadcast-mode=block --gas ${GAS} --fees=${FEES}usei --node=${RPC}"

#      OUTPUT_FILE=$(mktemp)
#      yes | $SEID tx wasm execute $CW721_BASE_ADDRESS "$CW721_BASE_MINT" --chain-id $CHAIN_ID --from $ACCOUNT_ADDRESS --broadcast-mode=block --gas $GAS --fees=${FEES}usei --node=$RPC > $OUTPUT_FILE 2>&1 &
#      CMD_PID=$!
#      while true; do
#        OUTPUT=$(cat $OUTPUT_FILE)
#        if grep -q -e "raw_log:" -e "Error:" <<<"$OUTPUT"; then
#          break
#        fi
#        echo "Output?: " $OUTPUT
#        echo "End of output"
#        sleep 1
#      done
      while true; do
        if grep -q -e "raw_log:" -e "Error:" <<<"$OUTPUT"; then
          echo "Output fetched successfully: "
          echo "Output?: " $OUTPUT
          echo "End of output"
          break
        fi
        OUTPUT_FILE=$(mktemp) # if use the same variable name (e.g., OUTPUT_FILE) for each temporary file, the previous value of the variable will be overwritten
        OUTPUT=$(cat $OUTPUT_FILE)
        echo "Terminal command response: "
        yes | $SEID tx wasm execute $CW721_BASE_ADDRESS "$CW721_BASE_MINT" --chain-id $CHAIN_ID --from $ACCOUNT_ADDRESS --broadcast-mode=block --gas $GAS --fees=${FEES}usei --node=$RPC > $OUTPUT_FILE 2>&1 &
        CMD_PID=$!
        sleep_time=$((sleep_time + 1))
        echo "Sleeping for " $sleep_time " seconds"
        sleep ${sleep_time}
        kill $CMD_PID >/dev/null 2>&1 || true
        OUTPUT=$(cat $OUTPUT_FILE)
        rm $OUTPUT_FILE
        echo "Output?: " $OUTPUT
        echo "End of output"
      done

      if [[ GAS -gt 1000000 ]]; then
        echo "Too much GAS tried, probably not the reason why transaction failed"
        exit 1
      fi
    done

    if grep -q -e "Error: " <<<"$OUTPUT"; then
      echo "Error in Output, so exit; repeat error response: " $OUTPUT
      exit 1
    fi

    if [ $? -eq 0 ]; then
      echo "Exit status: " $?
      echo "Output? " $OUTPUT
      if [ "$ROW_COUNTER" -lt "$total_rows" ]; then
        ROW_COUNTER=$((ROW_COUNTER + 1))
      fi
      if [[ "$ROW_COUNTER" == "$total_rows" ]]; then
        exit 1
      fi
      echo "$ROW_COUNTER" >> "$CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER"
      TOKEN_ID_COUNTER=$((TOKEN_ID_COUNTER + 1))
      echo "$TOKEN_ID_COUNTER" >> "$CACHE_FILE_FOR_TOKEN_ID"
      echo "Successfully minted NFT $TOKEN_ID_COUNTER for $ADDRESS_TO_MINT_NFTs_FOR" " ROW_COUNTER = $ROW_COUNTER"
    fi

  done # reads the next line of JSON
}

#!/bin/bash
mint_nft_for_addresses_in_json_using_cw721_metadata_onchain_from_unique_metadata() {
  echo "Enter the CW721 contract address: "
  read CW721_BASE_ADDRESS
  export workspace_root="$(git rev-parse --show-toplevel)"
  FUNCTION_NAME="mint_nft_from_csv"

  echo "Choose JSON to load ADDRESS_TO_MINT_NFTs_FOR"
  ADDRESS_JSON_FILE=$(zenity --file-selection --title="Select a CSV file" --file-filter="*.json" --filename="${workspace_root}/" --separator=",")
  echo "Enter collection name (for caching): "
  read collection_name
  SCRIPT_NAME="$(basename "$0" .sh)"
  CACHE_DIR="${workspace_root}/bash_project/scripts/cache/${collection_name}/${SCRIPT_NAME}_cache"
  if [ ! -d "$CACHE_DIR" ]; then
      mkdir -p "$CACHE_DIR"
  fi
  ADDRESS_JSON_FILE_FILENAME=$(basename "$ADDRESS_JSON_FILE")
  ADDRESS_JSON_FILE_FILENAME_NO_EXTENSION="${ADDRESS_JSON_FILE_FILENAME%.*}"
  CACHE_FILE_FOR_JSON_ADDRESS_COPY="${CACHE_DIR}/${FUNCTION_NAME}_cache_for_${ADDRESS_JSON_FILE_FILENAME_NO_EXTENSION}_json_copy.txt"
  if [ ! -f "$CACHE_FILE_FOR_JSON_ADDRESS_COPY" ]; then
    cp "$ADDRESS_JSON_FILE" "$CACHE_FILE_FOR_JSON_ADDRESS_COPY" # Copy so $ADDRESS_JSON_FILE should not be touched again
  fi
  JSON_DATA=$(cat $CACHE_FILE_FOR_JSON_ADDRESS_COPY)
  JSON_DATA=$(echo "$JSON_DATA" | tr -dc '\32-\176') # Sometimes JSON file of addresses contain escape characters, need to clean data
#  echo "JSON_DATA: $JSON_DATA"
  total_rows=$(echo "$JSON_DATA" | jq '. | length')
  echo "Total rows: $total_rows"
  CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER="${CACHE_DIR}/${FUNCTION_NAME}_cache_for_${ADDRESS_JSON_FILE_FILENAME_NO_EXTENSION}_csv_copy_row_counter.txt"
  if [ ! -f "$CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER" ]; then
      echo "1" >> "$CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER"
  fi
  START_ROW=$(tail -n 1 "$CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER") # reads last row
  ROW_COUNTER=$START_ROW
  CACHE_FILE_FOR_TOKEN_ID="${CACHE_DIR}/${FUNCTION_NAME}_cache_for_token_id.txt"
  if [ ! -f "$CACHE_FILE_FOR_TOKEN_ID" ]; then
      echo "1" >> "$CACHE_FILE_FOR_TOKEN_ID"
  fi
  START_TOKEN_ID=$(tail -n 1 "$CACHE_FILE_FOR_TOKEN_ID") # reads last row
  TOKEN_ID_COUNTER=$START_TOKEN_ID
  echo "Reading CACHE files at" $CACHE_DIR ", starting from row " $START_ROW " and from token_id" $START_TOKEN_ID

  echo "Choose folder for metadata JSON: "
  folder_path=$(zenity --file-selection --directory --title="Choose a directory")
  json_files=($(ls "$folder_path"/*.json))
  num_files=${#json_files[@]}
  echo "Number of unique metadata jsons: $num_files"

  # Iterate JSON file of ADDRESS_TO_MINT_NFTs_FOR
  for (( i=0; i< $total_rows; i++ ))
  do
    ADDRESS_TO_MINT_NFTs_FOR=$(echo $JSON_DATA | jq -r ".[$i]")
    echo "You entered: $ADDRESS_TO_MINT_NFTs_FOR"

    check_for_tokens $ADDRESS_TO_MINT_NFTs_FOR $total_rows $CW721_BASE_ADDRESS $SEID $CHAIN_ID $RPC
    if [ $? -eq 0 ]; then # $? is # of tokens found
      echo "Before minting, no suitable token_id found for $ADDRESS_TO_MINT_NFTs_FOR"
    else
      echo "Tokens found for $ADDRESS_TO_MINT_NFTs_FOR. Skipping..."
      continue
    fi

    random_index=$((RANDOM % num_files))
    random_file=${json_files[$random_index]}
    metadata=$(jq '.' "$random_file")
    export CW721_MINT='{
       "mint": {
         "extension": '$metadata',
         "owner": "'$ADDRESS_TO_MINT_NFTs_FOR'",
         "token_id": "'$TOKEN_ID_COUNTER'"
       }
    }'

    ATTEMPT=0
    GAS=500000
    FEES=50000

    # Execute mint!
    sleep_time=6
    echo "Terminal command: ${SEID} tx wasm execute ${CW721_BASE_ADDRESS} \"${CW721_MINT}\" --chain-id ${CHAIN_ID} --from ${ACCOUNT_ADDRESS} --broadcast-mode=block --gas ${GAS} --fees=${FEES}usei --node=${RPC}"
    echo "Terminal command response: "
    yes | $SEID tx wasm execute $CW721_BASE_ADDRESS "$CW721_MINT" --chain-id $CHAIN_ID --from $ACCOUNT_ADDRESS --broadcast-mode=block --gas $GAS --fees=${FEES}usei --node=$RPC
    echo "End of output"

    # Check if mint was successful by querying SEID
    if [[ "$ROW_COUNTER" == "$total_rows" ]]; then
      echo "All rows of addresses processed"
      exit 1
    fi
    check_for_tokens $ADDRESS_TO_MINT_NFTs_FOR $total_rows $CW721_BASE_ADDRESS $SEID $CHAIN_ID $RPC
    if [ $? -eq 0 ]; then # $? is # of tokens found
      echo "After minting, "
      echo "No suitable token_id found for $ADDRESS_TO_MINT_NFTs_FOR. Don't increment token ID for next mint iteration"
      continue
    else
      echo "Tokens found for $ADDRESS_TO_MINT_NFTs_FOR. Increment token ID for next mint iteration"
      echo "$TOKEN_ID_COUNTER" >> "$CACHE_FILE_FOR_TOKEN_ID" # Record last token ID successfully minted
      TOKEN_ID_COUNTER=$((TOKEN_ID_COUNTER + 1))
#      echo "$ROW_COUNTER" >> "$CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER"
      continue
    fi


  done # reads the next line of JSON
}

#!/bin/bash
mint_nft_for_addresses_in_json_using_cw721_base_array_from_metadata_jsons() {
  echo "Enter the CW721 contract address: "
  read CW721_BASE_ADDRESS
  export workspace_root="$(git rev-parse --show-toplevel)"
  FUNCTION_NAME="mint_nft_from_csv"

  echo "Choose JSON to load ADDRESS_TO_MINT_NFTs_FOR"
  ADDRESS_JSON_FILE=$(zenity --file-selection --title="Select a CSV file" --file-filter="*.json" --filename="${workspace_root}/" --separator=",")
  echo "Enter collection name (for caching): "
  read collection_name
  SCRIPT_NAME="$(basename "$0" .sh)"
  CACHE_DIR="${workspace_root}/bash_project/scripts/cache/${collection_name}/${SCRIPT_NAME}_cache"
  if [ ! -d "$CACHE_DIR" ]; then
      mkdir -p "$CACHE_DIR"
  fi
  ADDRESS_JSON_FILE_FILENAME=$(basename "$ADDRESS_JSON_FILE")
  ADDRESS_JSON_FILE_FILENAME_NO_EXTENSION="${ADDRESS_JSON_FILE_FILENAME%.*}"
  CACHE_FILE_FOR_JSON_ADDRESS_COPY="${CACHE_DIR}/${FUNCTION_NAME}_cache_for_${ADDRESS_JSON_FILE_FILENAME_NO_EXTENSION}_json_copy.txt"
  cp "$ADDRESS_JSON_FILE" "$CACHE_FILE_FOR_JSON_ADDRESS_COPY" # Copy so $ADDRESS_JSON_FILE should not be touched again
  JSON_DATA=$(cat $CACHE_FILE_FOR_JSON_ADDRESS_COPY)
  JSON_DATA=$(echo "$JSON_DATA" | tr -dc '\32-\176') # Sometimes JSON file of addresses contain escape characters, need to clean data
#  echo "JSON_DATA: $JSON_DATA"
  total_rows=$(echo "$JSON_DATA" | jq '. | length')
  echo "Total rows: $total_rows"
  addresses=($(echo $JSON_DATA | jq -r '.[]'))
  CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER="${CACHE_DIR}/${FUNCTION_NAME}_cache_for_${ADDRESS_JSON_FILE_FILENAME_NO_EXTENSION}_csv_copy_row_counter.txt"
  if [ ! -f "$CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER" ]; then
      echo "1" >> "$CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER"
  fi
  ROW_COUNTER=$START_ROW
  CACHE_FILE_FOR_TOKEN_ID="${CACHE_DIR}/${FUNCTION_NAME}_cache_for_token_id.txt"
  if [ ! -f "$CACHE_FILE_FOR_TOKEN_ID" ]; then
    echo "1" >> "$CACHE_FILE_FOR_TOKEN_ID"
  fi
  echo "Would you like to customize the starting row for address and token ID (if you enter yes, your input is the index of address and of token id from the files where minting starts from? Enter 'y' or 'yes' to customize: "
      read answer
      if [[ $answer = y ]] || [[ $answer = yes ]]; then
          echo "Enter the index of address and of token id from the files where minting starts from: "
          read starting_address_and_token_id
      else
          starting_address_and_token_id=$(tail -n 1 "$CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER") # reads last row
      fi
  echo "Reading CACHE files at" $CACHE_DIR ", starting from row " $START_ROW " and from token_id" $START_TOKEN_ID

  echo "Would you like to customize step size of minting? Enter 'y' or 'yes' to customize: "
        read answer
        if [[ $answer = y ]] || [[ $answer = yes ]]; then
            echo "Enter step size: "
            read iterate_step_size
        else
            iterate_step_size=1000
            echo "Default step size: 1000"
        fi

  echo "Choose folder for metadata JSON: "
  folder_path=$(zenity --file-selection --directory --title="Choose a directory")
  json_files=($(ls "$folder_path"/*.json))
  num_files=${#json_files[@]}
  random_index=$((RANDOM % num_files))
  random_file=${json_files[$random_index]}
  metadata=$(jq '.' "$random_file")
  metadata='{
    "animation_url": null,
    "attributes": [
      {
        "trait_type": "color",
        "value": "yellow"
      },
      {
        "trait_type": "ship name",
        "value": "HMS_ENCORE"
      },
      {
        "trait_type": "background color",
        "value": "gray"
      }
    ],
    "description": "Sparrowswap OG April 2023",
    "external_url": "https://gateway.pinata.cloud/ipfs/QmeeBZKNLjdXX1npae8tPu7xdTSxYUY4rhuE7HzP9PkcoC",
    "image": "https://gateway.pinata.cloud/ipfs/QmeeBZKNLjdXX1npae8tPu7xdTSxYUY4rhuE7HzP9PkcoC",
    "name": "Sparrowswap OG April 2023",
    "youtube_url": null
  }'
  echo "Number of unique metadata jsons: $num_files"
  echo "Metadata JSON file: $metadata"

  # Iterate JSON file of ADDRESS_TO_MINT_NFTs_FOR
  for (( i=${starting_address_and_token_id}; i< $total_rows; i+=${iterate_step_size} ))
  do

    # Create an array with 100 addresses or less if it's the last batch
    ADDRESS_TO_MINT_NFTs_FOR="["
      for (( j=i; j<=$((i+iterate_step_size-1)) && j<$total_rows; j++ ))
      do
        ADDRESS_TO_MINT_NFTs_FOR+="\"${addresses[$j]}\","
      done
      ADDRESS_TO_MINT_NFTs_FOR=${ADDRESS_TO_MINT_NFTs_FOR%?}"]" # remove trailing comma

    TOKEN_ID_COUNTER="["
      for (( k=i; k<=$((i+iterate_step_size-1)) && k<$total_rows; k++ ))
      do
        TOKEN_ID_COUNTER+="\"${k}\","
      done
      TOKEN_ID_COUNTER=${TOKEN_ID_COUNTER%?}"]" # remove trailing comma

    echo "ADDRESS_TO_MINT_NFTs_FOR: $ADDRESS_TO_MINT_NFTs_FOR"
    echo "TOKEN_ID_COUNTER: $TOKEN_ID_COUNTER"

    CW721_MINT=$(jq -n \
                --argjson metadata "$metadata" \
                --argjson owner "$ADDRESS_TO_MINT_NFTs_FOR" \
                --argjson token_id "$TOKEN_ID_COUNTER" \
                '{
                   "mint_batch": {
                     "extension": $metadata,
                     "owners": $owner,
                     "token_ids": $token_id
                   }
                 }')
    GAS=$(( 40000 + 50000 * $iterate_step_size ))
    FEES=$(( 4000 + 5000 * $iterate_step_size ))

    # Execute mint!
    sleep_time=10
    echo "Terminal command: ${SEID} tx wasm execute ${CW721_BASE_ADDRESS} '${CW721_MINT}' --chain-id ${CHAIN_ID} --from ${ACCOUNT_ADDRESS} --broadcast-mode=block --gas ${GAS} --fees=${FEES}usei --node=${RPC}"
    echo "Terminal command response: "
    yes | $SEID tx wasm execute $CW721_BASE_ADDRESS "$CW721_MINT" --chain-id $CHAIN_ID --from $ACCOUNT_ADDRESS --broadcast-mode=block --gas $GAS --fees=${FEES}usei --node=$RPC
    echo "End of output"

  done # reads the next line of JSON
}

query_cw20_users() {
  echo "Enter CW20 Address to query: "
  read CW20_BASE_ADDRESS
  CW20_QUERY_MSG='{
    "all_accounts": {
      "start_after": null,
      "limit": null
    }
  }'
  TOKEN_IDs_IN_JSON=$($SEID q wasm contract-state smart $CW20_BASE_ADDRESS "$CW20_QUERY_MSG" --output json --chain-id $CHAIN_ID --node=$RPC | jq -r '.data.tokens')
  echo $TOKEN_IDs_IN_JSON
}

query_nft_info() {
  echo "Enter CW721 Address to query: "
  read CW721_BASE_ADDRESS
  echo "Enter the address to be queried: "
  read QUERIED_ADDRESS
  if [[ -z "$token_id" ]]; then
      ADDRESS_TO_MINT_NFTs_FOR="$ACCOUNT_ADDRESS"
  fi
  echo "You entered: $QUERIED_ADDRESS"
  CW721_QUERY_WITH_ADDRESS='{
    "tokens": {
      "owner": "'$QUERIED_ADDRESS'"
    }
  }'
  TOKEN_IDs_IN_JSON=$($SEID q wasm contract-state smart $CW721_BASE_ADDRESS "$CW721_QUERY_WITH_ADDRESS" --output json --chain-id $CHAIN_ID --node=$RPC | jq -r '.data.tokens')
#  echo $($SEID q wasm contract-state smart $CW721_BASE_ADDRESS "$CW721_QUERY_WITH_ADDRESS" --output json --chain-id $CHAIN_ID --node=$RPC | jq -r '.data')

  TOKEN_IDs_In_ARRAY=()
  for index in $(seq 0 $(echo "$TOKEN_IDs_IN_JSON" | jq 'length-1')); do
      element=$(echo "$TOKEN_IDs_IN_JSON" | jq -r --argjson index "$index" '.[$index]')
      TOKEN_IDs_In_ARRAY+=("$element")
  done

  echo "You got " ${#TOKEN_IDs_In_ARRAY[@]} "token ids"

  for TOKEN_ID in "${TOKEN_IDs_In_ARRAY[@]}"; do
    # Construct the CW721_QUERY_WITH_TOKEN_ID variable
    CW721_QUERY_WITH_TOKEN_ID='{
      "nft_info": {
        "token_id": "'$TOKEN_ID'"
      }
    }'
    # Run the command with the updated CW721_QUERY_WITH_TOKEN_ID variable
    echo $SEID q wasm contract-state smart $CW721_BASE_ADDRESS "$CW721_QUERY_WITH_TOKEN_ID" --output json --chain-id $CHAIN_ID --node=$RPC
    $SEID q wasm contract-state smart $CW721_BASE_ADDRESS "$CW721_QUERY_WITH_TOKEN_ID" --output json --chain-id $CHAIN_ID --node=$RPC
    echo "Token URI: " $token_uri
    token_uri=$(SEID q wasm contract-state smart $CW721_BASE_ADDRESS $CW721_QUERY_WITH_TOKEN_ID --output json --chain-id $CHAIN_ID --node=$RPC | jq -r '.data.info.token_uri')
    if [[ "$token_uri" =~ ^ipfs://[A-Za-z0-9]+$ ]]; then
        token_uri="https://ipfs.filebase.io${token_uri#ipfs}"
        echo "Token URL: $token_uri"
    fi
  done
}


query_nft_info_from_csv() {
  echo "Enter CW721 contract address: "
  read CW721_BASE_ADDRESS
  export workspace_root="$(git rev-parse --show-toplevel)"
  FUNCTION_NAME="mint_nft_from_csv"
  echo "Choose CSV to load ADDRESS_TO_MINT_NFTs_FOR"
  ADDRESS_CSV_FILE=$(zenity --file-selection --title="Select a CSV file" --file-filter="*.csv" --filename="${workspace_root}/" --separator=",")
  total_rows=$(wc -l < "$ADDRESS_CSV_FILE")
  echo "Total rows: $total_rows"
  column_index=$(python ${workspace_root}/bash_project/scripts/functions_helper.py mint_nft_from_csv_helper "$ADDRESS_CSV_FILE")
  echo "Selected column index: $column_index"

  SCRIPT_NAME="$(basename "$0" .sh)"
  # Get a copy of CSV file as cache s.t. won't mess up original CSV
  ADDRESS_CSV_FILE_FILENAME=$(basename "$ADDRESS_CSV_FILE")
  ADDRESS_CSV_FILE_FILENAME_NO_EXTENSION="${ADDRESS_CSV_FILE_FILENAME%.*}"
  CACHE_DIR="${workspace_root}/bash_project/scripts/cache/Powder_Monkeys/${SCRIPT_NAME}_cache"
  if [ ! -d "$CACHE_DIR" ]; then
      mkdir -p "$CACHE_DIR"
  fi
  CACHE_FILE_FOR_CSV_ADDRESS_COPY="${CACHE_DIR}/${FUNCTION_NAME}_cache_for_${ADDRESS_CSV_FILE_FILENAME_NO_EXTENSION}_csv_copy.txt"
  if [ ! -f "$CACHE_FILE_FOR_CSV_ADDRESS_COPY" ]; then
    cp "$ADDRESS_CSV_FILE" "$CACHE_FILE_FOR_CSV_ADDRESS_COPY" # Copy so $ADDRESS_CSV_FILE should not be touched again
  fi

  # To count how many addresses have been processed
  CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER="${CACHE_DIR}/${FUNCTION_NAME}_cache_for_${ADDRESS_CSV_FILE_FILENAME_NO_EXTENSION}_csv_copy_row_counter.txt"
  if [ ! -f "$CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER" ]; then
      echo "1" >> "$CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER"
  fi
  START_ROW=$(tail -n 1 "$CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER") # reads last row
  ROW_COUNTER=$START_ROW
  echo "Reading CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER at " $CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER ", starting from row " $START_ROW

  awk -v column_index="$column_index" -v START_ROW="$START_ROW" -F, 'NR>START_ROW {print $(column_index)}' "$CACHE_FILE_FOR_CSV_ADDRESS_COPY" | while read -r QUERIED_ADDRESS; do
      echo "You entered: $QUERIED_ADDRESS"
      CW721_QUERY_WITH_ADDRESS='{
          "tokens": {
            "owner": "'$QUERIED_ADDRESS'"
          }
        }'
      echo $SEID q wasm contract-state smart $CW721_BASE_ADDRESS "$CW721_QUERY_WITH_ADDRESS" --output json --chain-id $CHAIN_ID --node=$RPC
      TOKEN_IDs_IN_JSON=$($SEID q wasm contract-state smart $CW721_BASE_ADDRESS "$CW721_QUERY_WITH_ADDRESS" --output json --chain-id $CHAIN_ID --node=$RPC | jq -r '.data.tokens')
      echo "TOKEN_IDs_IN_JSON " $TOKEN_IDs_IN_JSON

      TOKEN_IDs_In_ARRAY=()
        for index in $(seq 0 $(echo "$TOKEN_IDs_IN_JSON" | jq 'length-1')); do
            element=$(echo "$TOKEN_IDs_IN_JSON" | jq -r --argjson index "$index" '.[$index]')
            TOKEN_IDs_In_ARRAY+=("$element")
        done

       echo "$QUERIED_ADDRESS has " ${#TOKEN_IDs_In_ARRAY[@]} "token ids"

      # Flag to check if a number in the range is found
#      ARRAY_LENGTH=$(echo "$TOKEN_IDs_IN_JSON" | jq '. | length')
#      number_found=0
#      # Iterate over the elements in the JSON array
#      for i in $(seq 0 $(($ARRAY_LENGTH - 1))); do
#        # Extract the element at index i and remove quotes
#        element=$(echo "$TOKEN_IDs_IN_JSON" | jq ".[$i]" | tr -d '"')
#        # Check if element is an integer
#        if [[ $element =~ ^[0-9]+$ ]]; then
#          # Check if the element is within the range 1 to TOKEN_ID_MAX
#          if [ "$element" -ge 1 ] && [ "$element" -le "$TOKEN_ID_MAX" ]; then
#            number_found=$(($number_found + 1))
#            TEMP_FILE=$(mktemp)
#            awk -v address="$QUERIED_ADDRESS" -v col_idx="$column_index" -F, 'BEGIN {OFS=","} {if ($col_idx != address) print $0}' "$CACHE_FILE_FOR_CSV_ADDRESS_COPY" > "$TEMP_FILE"
#            echo "Found token_id: $element"
#            echo "Removing $QUERIED_ADDRESS from $CACHE_FILE_FOR_CSV_ADDRESS_COPY"
#            mv "$TEMP_FILE" "$CACHE_FILE_FOR_CSV_ADDRESS_COPY"
#            break
#          fi
#        fi
#      done

#      if [ "$number_found" -eq 0 ]; then
#        echo "No suitable token_id found."
#      fi
#
#     if [ $? -eq 0 ] && [ "$number_found" -ge 0 ] ; then
#       echo "Exit status: " $?
#       if [ "$ROW_COUNTER" -lt "$total_rows" ]; then
       ROW_COUNTER=$((ROW_COUNTER + 1))
#       fi
#       if [[ "$ROW_COUNTER" == "$total_rows" ]]; then
#         exit 1
#       fi
#       echo "$ROW_COUNTER" >> "$CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER"
#     fi
  done
}


query_nft_info_from_json() {
  echo "Enter CW721 contract address: "
  read CW721_BASE_ADDRESS
  export workspace_root="$(git rev-parse --show-toplevel)"
  FUNCTION_NAME="mint_nft_from_csv"
  echo "Choose JSON to load ADDRESS_TO_MINT_NFTs_FOR"
  ADDRESS_JSON_FILE=$(zenity --file-selection --title="Select a JSON file" --file-filter="*.json" --filename="${workspace_root}/" --separator=",")
  total_rows=$(wc -l < "$ADDRESS_JSON_FILE")
  echo "Total rows: $total_rows"

  echo "Enter collection name (for caching): "
  read collection_name
  SCRIPT_NAME="$(basename "$0" .sh)"
  # Get a copy of CSV file as cache s.t. won't mess up original CSV
  ADDRESS_JSON_FILE_FILENAME=$(basename "$ADDRESS_JSON_FILE")
  ADDRESS_JSON_FILE_FILENAME_NO_EXTENSION="${ADDRESS_JSON_FILE_FILENAME%.*}"
  CACHE_DIR="${workspace_root}/bash_project/scripts/cache/${collection_name}/${SCRIPT_NAME}_cache"
  if [ ! -d "$CACHE_DIR" ]; then
      mkdir -p "$CACHE_DIR"
  fi
  CACHE_FILE_FOR_JSON_ADDRESS_COPY="${CACHE_DIR}/${FUNCTION_NAME}_cache_for_${ADDRESS_JSON_FILE_FILENAME_NO_EXTENSION}_csv_copy.txt"
  cp "$ADDRESS_JSON_FILE" "$CACHE_FILE_FOR_JSON_ADDRESS_COPY"
#  if [ -f "$ADDRESS_JSON_FILE" ]; then
#      cp "$ADDRESS_JSON_FILE" "$CACHE_FILE_FOR_JSON_ADDRESS_COPY" # Copy so $ADDRESS_CSV_FILE should not be touched again
#      echo "File has been copied."
#    else
#      echo "File $ADDRESS_JSON_FILE does not exist."
#  fi
  JSON_DATA=$(cat $CACHE_FILE_FOR_JSON_ADDRESS_COPY)
  JSON_DATA=$(echo "$JSON_DATA" | tr -dc '\32-\176') # Sometimes JSON file of addresses contain escape characters, need to clean data
  echo "JSON_DATA: $JSON_DATA"
  total_rows=$(echo "$JSON_DATA" | jq '. | length')
  echo "Total rows: $total_rows"

  # To count how many addresses have been processed
  CACHE_FILE_FOR_ADDRESS_JSON_COPY_ROW_COUNTER="${CACHE_DIR}/${FUNCTION_NAME}_cache_for_${ADDRESS_JSON_FILE_FILENAME_NO_EXTENSION}_csv_copy_row_counter.txt"
  if [ ! -f "$CACHE_FILE_FOR_ADDRESS_JSON_COPY_ROW_COUNTER" ]; then
      echo "1" >> "$CACHE_FILE_FOR_ADDRESS_JSON_COPY_ROW_COUNTER"
  fi
  START_ROW=$(tail -n 1 "$CACHE_FILE_FOR_ADDRESS_JSON_COPY_ROW_COUNTER") # reads last row
  ROW_COUNTER=1 # For now, to be safe
  echo "Reading CACHE_FILE_FOR_ADDRESS_JSON_COPY_ROW_COUNTER at " $CACHE_FILE_FOR_ADDRESS_JSON_COPY_ROW_COUNTER ", starting from row " $START_ROW


  echo "Would you like to customize the starting row for address (if you enter yes, your input is the index of address from the file where minting starts from? Enter 'y' or 'yes' to customize: "
      read answer
      if [[ $answer = y ]] || [[ $answer = yes ]]; then
          echo "Enter the index of address from the file where minting starts from: "
          read starting_address_and_token_id
      else
          starting_address_and_token_id=$(tail -n 1 "$CACHE_FILE_FOR_ADDRESS_CSV_COPY_ROW_COUNTER") # reads last row
      fi

  for (( i=${starting_address_and_token_id}; i< $total_rows; i++ ))
  do
    QUERIED_ADDRESS=$(echo $JSON_DATA | jq -r ".[$i]")
    echo "You entered: $QUERIED_ADDRESS"
    CW721_QUERY_WITH_ADDRESS='{
        "tokens": {
          "owner": "'$QUERIED_ADDRESS'"
        }
      }'
    TOKEN_IDs_IN_JSON=$($SEID q wasm contract-state smart $CW721_BASE_ADDRESS "$CW721_QUERY_WITH_ADDRESS" --output json --chain-id $CHAIN_ID --node=$RPC | jq -r '.data.tokens')
#    echo TOKEN_IDs_IN_JSON

    ARRAY_LENGTH=$(echo "$TOKEN_IDs_IN_JSON" | jq '. | length')
    TOKEN_IDs_In_ARRAY=()
      for index in $(seq 0 $(echo "$TOKEN_IDs_IN_JSON" | jq 'length-1')); do
          element=$(echo "$TOKEN_IDs_IN_JSON" | jq -r --argjson index "$index" '.[$index]')
          TOKEN_IDs_In_ARRAY+=("$element")
      done

      echo "$QUERIED_ADDRESS has " ${#TOKEN_IDs_In_ARRAY[@]} "token ids"
  done
}

query_for_user_tokens() {
  local address=$1
  local token_id_max=$2
  local cw721_base_address=$3
  local seid=$4
  local chain_id=$5
  local rpc=$6
  local cw721_query_with_address='{
      "tokens": {
        "owner": "'$address'"
      }
    }'
  local token_ids_in_json=$($seid q wasm contract-state smart $cw721_base_address "$cw721_query_with_address" --output json --chain-id $chain_id --node=$rpc | jq -r '.data.tokens')

  local array_length=$(echo "$token_ids_in_json" | jq '. | length')
  local number_found=0
  for j in $(seq 0 $(($array_length - 1))); do
    local element=$(echo "$token_ids_in_json" | jq ".[$j]" | tr -d '"')
    if [[ $element =~ ^[0-9]+$ ]]; then
      if [ "$element" -ge 1 ] && [ "$element" -le "$token_id_max" ]; then
        number_found=$(($number_found + 1))
        echo "Found token_id: $element for address $address"
        break
      fi
    fi
  done
  return $number_found
}

query_for_cw20_current_accounts() {
  echo "Enter CW20 contract address to query user balances on: "
    read cw20_address

  echo "Do you want to read in a file? [y/n]"
    read answer
    if [ "$answer" != "${answer#[Yy]}" ]; then
      ADDRESS_CSV_FILE=$(zenity --file-selection --title="Select a CSV file" --file-filter="*.csv" --filename="${workspace_root}/"  --separator=",")
      total_rows=$(wc -l < "$ADDRESS_CSV_FILE")
        echo "Total rows: $total_rows"
      address=$(tail -n 1 $ADDRESS_CSV_FILE)
      echo "Reading from file: $ADDRESS_CSV_FILE"
      echo "Last address in file: $address"
    else
      address="sei0"
      ADDRESS_CSV_FOLDER=$(zenity --file-selection --title="Select a Folder" --directory)
    fi


  while true; do
      output=$($SEID q wasm contract-state smart $cw20_address "{\"all_accounts\": {\"start_after\": \"${address}\", \"limit\": 1000}}" --output json --chain-id atlantic-2 --node=https://sei.kingnodes.com)
      accounts=$(echo "${output}" | jq -r '.data.accounts[]')
      echo $output
      echo "accounts: $accounts"

      if [ "$answer" != "${answer#[Yy]}" ]; then
        for account in $accounts; do
          echo "${account}" >> ${ADDRESS_CSV_FILE}
          done
      else
        for account in $accounts; do
          echo "${account}" >> ${ADDRESS_CSV_FOLDER}/${cw20_address}_addresses.csv
          done
      fi
      # Get the last account for the next loop
       last_account=$(echo "${accounts}" | tail -n 1)
       if [ ! -z "$last_account" ]; then
           address=$last_account
       fi
  done
}

query_seid_bank_account_for_csv_addresses() {
  file_path=$(zenity_file_path)
  counter=0

  # Convert JSON array to bash array
  addresses=$(cat $file_path)
#  echo "Addresses: $addresses"
  element=$(echo $addresses | jq -r '.[919]')
  echo "Element: $element"
  total_rows=$(echo $addresses | jq -r '. | length')
  echo "Total rows: $total_rows"

  # Loop over each address in the array
  for (( i=0; i< $total_rows; i++ ))
  do
    # Run the seid command and save its output
    address=$(echo $addresses | jq -r ".[$i]")
    echo "Querying address: $address"
    echo "Command: $SEID q bank balances $address --output=json --node=https://rpc-sei-testnet.rhinostake.com/"
    output=$($SEID q bank balances $address --output=json --node=https://rpc-sei-testnet.rhinostake.com/)
    echo $output

    # Parse the balances field from the output
    balances=$(echo "$output" | jq -r '.balances')

    # If balances is empty, increment the counter
    if [[ -z "$balances" || "$balances" == "[]" ]]; then
        ((counter++))
    fi
    echo "Counter: $counter"

  done
}

zenity_file_path() {
  echo $(zenity --file-selection --title="Select a file" --file-filter="*.csv *.json" --filename="${workspace_root}/" --separator=",")
}