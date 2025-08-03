#!/usr/bin/env bash

# Gets the directories the script and csv is saved at
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
SERVERSCSV="$SCRIPT_DIR/serverlist.csv"
AUTOSTARTTXT="$SCRIPT_DIR/autostart-server.txt"
AUTOSTARTSH="$SCRIPT_DIR/vpnautostart.sh"

# Check if all files exists
if [[ ! -f "$SERVERSCSV" ]]; then
  echo -e "${bold}${fg[red]}❌ Error:${reset}${bold}${fg[white]} No serverlist.csv found! Expected path: $SERVERSCSV${reset}"
  exit 1
fi
if [[ ! -f "$AUTOSTARTTXT" ]]; then
  echo -e "${bold}${fg[red]}❌ Error:${reset}${bold}${fg[white]} No autostart-server.txt found! Expected path: $SERVERSCSV${reset}"
  exit 1
fi
if [[ ! -f "$AUTOSTARTSH" ]]; then
  echo -e "${bold}${fg[red]}❌ Error:${reset}${bold}${fg[white]} No vpnautostart.sh found! Expected path: $SERVERSCSV${reset}"
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
echo -e "${bold}${fg[red]}\nAutostart VPN Server Selection\n${reset}"

# Declares the screen session name 
SESSION_NAME="vpn_connection"
# Define, read and display Autostart Server
AUTOSTART_SERVER=""
AUTOSTART_SERVER_DOMAIN=""
read AUTOSTART_SERVER < <(sed -n '1p' $AUTOSTARTTXT)
read AUTOSTART_SERVER_DOMAIN < <(sed -n '2p' $AUTOSTARTTXT)
echo -e "${bold}${fg[magenta]}${uline}Current VPN Autostart Server Selection${reset}"
echo -e "${bold}${fg[magenta]}󰒒 VPN Autostart Server:${fg[white]}        $AUTOSTART_SERVER${reset}"
echo -e "${bold}${fg[magenta]}󰇗 VPN Autostart Server Domain:${fg[white]} $AUTOSTART_SERVER_DOMAIN\n\n${reset}"

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
    --header="Please select a new VPN Autostart Server" \
    --prompt="Filter ⧐ " \
    --height=40% \
    --layout=reverse \
    --border)

# If user made a selection
if [ -n "$fzfselect" ]; then
    # Extract the second column of the matching row - the corresponding domain
    seldomain=$(awk -F';' -v servername="$fzfselect" '$1 == servername { print $2 }' $SERVERSCSV)
    echo -e "${bold}${fg[green]}${uline}New VPN Autostart Server Selection${reset}"
    echo -e "${bold}${fg[magenta]}󰒒${fg[green]} VPN Autostart Server:${fg[white]}          $fzfselect${reset}"
    echo -e "${bold}${fg[magenta]}󰇗${fg[green]} VPN Autostart Server Domain:${fg[white]}   $seldomain${reset}"
else
    echo "No selection made. Aborted..."
    exit 1
fi

truncate -s 0 "$AUTOSTARTTXT"
echo "$fzfselect" > $AUTOSTARTTXT
echo "$seldomain" >> $AUTOSTARTTXT

echo -e "${bold}${fg[green]}\nBye... (｡◕‿‿◕｡)${reset}\n"
