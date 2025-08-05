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

execdir

read AUTOSTART_SERVER_DOMAIN < <(sed -n '2p' $AUTOSTARTTXT)

# Defines the connection string
autostart_connection="sudo /opt/hide.me/hide.me -b resolv_backup.conf -s '$EXC_IP_RANGE' connect '$AUTOSTART_SERVER_DOMAIN'"

# Reset log and connect with a detached screen session
truncate -s 0 "$SCRIPT_DIR/recent_vpn_con.log"
screen -L -Logfile "$SCRIPT_DIR/recent_vpn_con.log" -dmS "$SESSION_NAME" bash -c "$autostart_connection"
