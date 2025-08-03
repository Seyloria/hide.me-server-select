#!/usr/bin/env bash

# A comma seperated list of IP ranges to exclude - Examples: your local Network and/or tailscale IP range
EXC_IP_RANGE="192.168.55.0/24,100.64.0.0/10"
#---------------- EDIT THIS - END ------------------
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
SESSION_NAME="vpn_connection"
AUTOSTARTTXT="$SCRIPT_DIR/autostart-server.txt"
AUTO_SERVER_DOMAIN=""
read AUTOSTART_SERVER_DOMAIN < <(sed -n '2p' $AUTOSTARTTXT)

# Changes the script working directory
cd /opt/hide.me/ || {
  echo "Failed to change to /opt/hide.me/. Aborting."
  exit 1
}

# Defines the connection string
connection="sudo /opt/hide.me/hide.me -b resolv_backup.conf -s '$EXC_IP_RANGE' connect '$AUTOSTART_SERVER_DOMAIN'"

# Reset log and connect with a detached screen session
truncate -s 0 "$SCRIPT_DIR/recent_vpn_con.log"
screen -L -Logfile "$SCRIPT_DIR/recent_vpn_con.log" -dmS "$SESSION_NAME" bash -c "$connection"
