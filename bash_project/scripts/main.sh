#!/usr/bin/env zsh

export SEID="$HOME/go/bin/seid"
#export RPC="https://sei.kingnodes.com/"
export RPC="https://rpc.atlantic-2.seinetwork.io"
export CHAIN_ID=atlantic-2
export CONFIG_PATH=/Users/tianyu/.sei/config/config.toml
export ACCOUNT_NAME="tianyu"
export ACCOUNT_ADDRESS="sei13e58xcttwm7n5tpnmpcrqm5yjpjm5j28c6wf09"
export PEYTON_ADDRESS="sei135mlnw9ndkyglgx7ma95pw22cl64mpnw58pfpd"
export workspace_root="$(git rev-parse --show-toplevel)"
export CW721_BASE_ADDRESS="sei18u6l0amm6vqwf04us9xpgjspf9a5set59k6fpnlxwjlp4q4m3yss5nn3ke"
export CW721_BASE_INIT='{
          "minter": "sei13e58xcttwm7n5tpnmpcrqm5yjpjm5j28c6wf09",
          "name": "CW721",
          "symbol": "CW721"
      }'
export CW721_BASE_CODE_ID=192

chmod u+x "${workspace_root}/bash_project/scripts/functions.sh"
chmod +r "${workspace_root}/bash_project/scripts/functions.sh"
source "${workspace_root}/bash_project/scripts/functions.sh"

declare -a my_functions
my_functions=($(perl -ne 'print "$1\n" if /^(\w+)\(\)/;' ${workspace_root}/bash_project/scripts/functions.sh | awk -F '(' '{print $1}'))
my_functions_in_array=()
function_index=1
for function in $my_functions; do
    my_functions_in_array+=($function $function_index)
    ((function_index++))
done
while true; do
  selected_function=$(dialog --clear --title "Function Menu" --menu "Choose a function:" 10 80 4 "${my_functions_in_array[@]}" 3>&1 1>&2 2>&3 3>&-)
  selected_function=$(echo "$selected_function" | tr -d '\n')
  clear
  echo $selected_function

  if [ -n "$selected_function" ]; then
      "$selected_function"
  else
      echo "No function selected."
  fi

  echo "Done?: (enter empty to continue)"
  read is_done
  if [[ -z "$is_done" ]]; then
    continue_dialog=$(dialog --clear --title "Continue?" --menu "Choose next step:" 10 30 4 "Continue" 1 "Exit" 2 3>&1 1>&2 2>&3 3>&-)
          clear

    if [ "$?" -eq 0 ]; then
        continue
    else
        break
    fi
  fi
done