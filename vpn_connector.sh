#!/usr/bin/env bash

# Gets the script working directory
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

#Check and source config.sh
if [[ ! -f "$SCRIPT_DIR/config.sh" ]]; then
    echo -e "\n❌ Error: No config.sh found! Expected path: $SCRIPT_DIR/config.sh\n"
    exit 1
else
    source "$SCRIPT_DIR/config.sh"
fi

check_dependencies
check_required_files

execdir

read AUTOSTART_SERVER < <(sed -n '1p' "$AUTOSTARTTXT")
read AUTOSTART_SERVER_DOMAIN < <(sed -n '2p' "$AUTOSTARTTXT")

# Defines the connection string
autostart_connection="sudo /opt/hide.me/hide.me -b resolv_backup.conf -s '$EXC_IP_RANGE' connect '$AUTOSTART_SERVER_DOMAIN'"

# Start connection and run in background of the script screen session so SIGTERM can be caught and is not blocked by the foreground running vpn connection
if [[ "$1" == "--syslaunch" ]]; then
    # Check if autostart-server.txt exists and is not empty
    if [[ -s "$AUTOSTARTTXT" ]]; then
        write_backup_resolv_conf
        echo -e "${bold}${fg[green]}\n⚕️ Info:${fg[white]} Starting connection to server: $AUTOSTART_SERVER ($AUTOSTART_SERVER_DOMAIN)\n${reset}"
        eval "$autostart_connection"
    else
        write_backup_resolv_conf
        echo -e "${bold}${fg[yellow]}\n⚕️ Info:${fg[white]} Autostart Server not set. Skipping Autostart Connection\n${reset}"
    fi
else
    echo -e "${bold}${fg[green]}\n⚕️ INFO:${fg[white]} Starting connection to server: $fzfselect ($seldomain)\n${reset}"
    eval "$connection"
fi
