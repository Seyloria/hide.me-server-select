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

check_required_files

execdir

read AUTOSTART_SERVER < <(sed -n '1p' "$AUTOSTARTTXT")
read AUTOSTART_SERVER_DOMAIN < <(sed -n '2p' $AUTOSTARTTXT)

# Defines the connection string
autostart_connection="sudo /opt/hide.me/hide.me -b resolv_backup.conf -s '$EXC_IP_RANGE' connect '$AUTOSTART_SERVER_DOMAIN'"


# Start connection and run in background of the script screen session so SIGTERM can be caught and is not blocked by the foreground running vpn connection
if [[ "$1" == "--syslaunch" ]]; then
    eval "$autostart_connection" &
    echo -e "${bold}${fg[green]}\n⚕️ INFO:${fg[white]} Starting connection to server: $AUTOSTART_SERVER ($AUTOSTART_SERVER_DOMAIN)\n${reset}"
else
    eval "$connection" &
    echo -e "${bold}${fg[green]}\n⚕️ INFO:${fg[white]} Starting connection to server: $fzfselect ($seldomain)\n${reset}"
fi


# Trap SIGTERM and EXIT for cleanup
break_connection() {
    echo -e "${bold}${fg[green]:-}⚕️ TRAP:${fg[white]:-} SIGTERM caught. Sending Ctrl+C to screen session: $SESSION_NAME${reset:-}"
    screen -S "$SESSION_NAME" -X stuff $'\003'
    exit 0
}
trap break_connection SIGTERM SIGHUP EXIT

# Keep script alive to catch SIGTERM
wait
