#!/usr/bin/env bash

# Gets the script working directory
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

#Check and source config.sh
if [[ ! -f "$SCRIPT_DIR/config.sh" ]]; then
    echo -e "\n❌ Error: No config.sh found! Expected path: $SCRIPT_DIR$/config.sh\n"
    exit 1
else
    source $SCRIPT_DIR/config.sh
fi

# Checks if all required files are in place
check_required_files

# Changes the script working directory
execdir

# Traps user abortion
trap 'echo -e "${bold}${fg[red]}⚕️ Info: Script closed by user. Exiting...${reset}\n"; exit 130' INT

#Info Greeting
echo -e "${bold}${fg[white]}${bg[magenta]}$greeting${reset}"
echo -e "$proginfo"

check_and_attach_screen_session

select_vpn_server

start_new_session_and_connect
