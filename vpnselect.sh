#!/usr/bin/env bash

#---------------- EDIT THIS - START ----------------
# General Config -> User should edit this to his usecase

# A comma seperated list of IP ranges to exclude - Examples: your local Network and/or tailscale IP range
EXC_IP_RANGE="192.168.55.0/24,100.64.0.0/10"
#---------------- EDIT THIS - END ------------------

# Gets the directories the script and csv is saved at
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
SERVERSCSV="$SCRIPT_DIR/serverlist.csv"

# Check if the serverlist.csv file exists
if [[ ! -f "$SERVERSCSV" ]]; then
  echo -e "${bold}${fg[red]}❌ Error:${reset}${bold}${fg[white]} No serverlist.csv found! Expected path: $SERVERSCSV${reset}"
  exit 1
fi

# Changes the script working directory
cd /opt/hide.me/ || {
  echo "Failed to change to /opt/hide.me/. Aborting."
  exit 1
}

# Enable associative arrays (Bash 4+)
declare -A fg
declare -A bg
# Foreground colors
fg=(
  [black]="$(tput setaf 0)"
  [red]="$(tput setaf 1)"
  [green]="$(tput setaf 2)"
  [yellow]="$(tput setaf 3)"
  [blue]="$(tput setaf 4)"
  [magenta]="$(tput setaf 5)"
  [cyan]="$(tput setaf 6)"
  [white]="$(tput setaf 7)"
)
# Background colors
bg=(
  [black]="$(tput setab 0)"
  [red]="$(tput setab 1)"
  [green]="$(tput setab 2)"
  [yellow]="$(tput setab 3)"
  [blue]="$(tput setab 4)"
  [magenta]="$(tput setab 5)"
  [cyan]="$(tput setab 6)"
  [white]="$(tput setab 7)"
)
# Text attributes
bold="$(tput bold)"
reset="$(tput sgr0)"
uline="$(tput smul)"
uliner="$(tput rmul)"

trap 'echo -e "${bold}${fg[red]}⚕️ Info: Script closed by user. Exiting...${reset}\n"; exit 130' INT

#Info Greeting
greeting=$(cat <<'EOF'

                                                       
   ██╗  ██╗██╗██████╗ ███████╗   ███╗   ███╗███████╗   
   ██║  ██║██║██╔══██╗██╔════╝   ████╗ ████║██╔════╝   
   ███████║██║██║  ██║█████╗     ██╔████╔██║█████╗     
   ██╔══██║██║██║  ██║██╔══╝     ██║╚██╔╝██║██╔══╝     
   ██║  ██║██║██████╔╝███████╗██╗██║ ╚═╝ ██║███████╗   
   ╚═╝  ╚═╝╚═╝╚═════╝ ╚══════╝╚═╝╚═╝     ╚═╝╚══════╝   
   ┏━┓┏━╸┏━┓╻ ╻┏━╸┏━┓   ┏━┓┏━╸╻  ┏━╸┏━╸╺┳╸             
   ┗━┓┣╸ ┣┳┛┃┏┛┣╸ ┣┳┛   ┗━┓┣╸ ┃  ┣╸ ┃   ┃              
   ┗━┛┗━╸╹┗╸┗┛ ┗━╸╹┗╸   ┗━┛┗━╸┗━╸┗━╸┗━╸ ╹              
                                                       
EOF
)
echo -e "${bold}${fg[white]}${bg[magenta]}$greeting${reset}"
echo -e "${bold}${fg[magenta]}\nwritten by Seyloria | Version 1.2 | https://github.com/Seyloria/hide.me-server-select\n${reset}"

# Declares the screen session name 
SESSION_NAME="vpn_connection"
# Check if the screen session exists
if screen -list | grep -q "\.${SESSION_NAME}"; then
    echo -e "${bold}${fg[green]}⚕️ INFO:${fg[white]} Running detached VPN connection session detected! Attaching to running screen session '$SESSION_NAME'...\n${reset}"
    echo -e "${bold}${fg[white]}         To get back out of the session screen again press ${fg[red]}Ctrl+A + D${reset}"
    echo -e "${bold}${fg[white]}         To kill the current VPN connection press ${fg[red]}Ctrl+C\n${reset}"
    sleep 5
    screen -r "$SESSION_NAME"
else
    echo -e "${bold}${fg[white]}⚕️${fg[magenta]} INFO:${fg[white]} No running VPN connection in detached session named '$SESSION_NAME' found.${reset}\n"
fi

# Arrays to store the csv data
servernames=()
domains=()
# Reads each line in the csv and saves the servernames and domains into arrays
while IFS=";" read -r servername domain; do
    servernames+=("$servername")
    domains+=("$domain")
done < "$SERVERSCSV"

# Lets the user select the server(first column) from the serverlist.csv
fzfselect=$(cut -d';' -f1 $SERVERSCSV | fzf \
    --color="header:green,prompt:green,fg+:magenta:bold" \
    --header="Please select a VPN server" \
    --prompt="Filter ⧐ " \
    --height=40% \
    --layout=reverse \
    --border)

# If user made a selection
if [ -n "$fzfselect" ]; then
    # Extract the second column of the matching row - the corresponding domain
    seldomain=$(awk -F';' -v servername="$fzfselect" '$1 == servername { print $2 }' $SERVERSCSV)
    
    echo -e "${bold}${fg[magenta]}󰒒 Selected Server:${fg[white]} $fzfselect${reset}"
    echo -e "${bold}${fg[magenta]}󰇗 Server Domain:${fg[white]}   $seldomain${reset}"
else
    echo "No selection made. Aborted..."
    exit 1
fi

# 
#connection="sudo /opt/hide.me/hide.me -b resolv_backup.conf -s \"$EXC_IP_RANGE\" connect \"$seldomain\""
connection="sudo /opt/hide.me/hide.me -b resolv_backup.conf -s '$EXC_IP_RANGE' connect '$seldomain'"
if screen -list | grep -q "\.${SESSION_NAME}"; then
    echo -e "${bold}${fg[green]}\n⚕️ INFO:${fg[white]} Running detached VPN connection session detected! Attaching to running screen session '$SESSION_NAME'...\n${reset}"
    echo -e "${bold}${fg[white]}         To get back out of the session screen again press ${fg[red]}Ctrl+A + D${reset}"
    echo -e "${bold}${fg[white]}         To kill the current VPN connection press ${fg[red]}Ctrl+C\n${reset}"
    sleep 5
    screen -r "$SESSION_NAME"
else
    truncate -s 0 "$SCRIPT_DIR/recent_vpn_con.log"
    screen -dmS $SESSION_NAME bash -c "$connection"
    screen -S $SESSION_NAME -X logfile "$SCRIPT_DIR/recent_vpn_con.log"
    screen -S $SESSION_NAME -X log on
    echo -e "${bold}\n⚕️${fg[green]} INFO:${fg[white]} Establishing connection to server '$fzfselect'\n\nDetached screen session with the name 'vpn_connection' will be running in the background.\nTo view the output, simply rerun the script.\nIt's save to close the terminal now!\n${reset}"
    echo -e "${bold}${fg[green]}Bye... (｡◕‿‿◕｡)${reset}\n"
    sleep 3
fi
