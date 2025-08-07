#!/usr/bin/env bash

#---------------- USER EDIT THIS - START ----------------
# A comma seperated list of IP ranges(CIDR's) to exclude - Examples: Your local Network and/or tailscale IP range
export EXC_IP_RANGE="192.168.55.0/24,100.64.0.0/10"
#---------------- USER EDIT THIS - END ------------------

# Global static variables
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
SERVERSCSV="$SCRIPT_DIR/serverlist.csv"
AUTOSTARTTXT="$SCRIPT_DIR/autostart-server.txt"
AUTOSTARTSH="$SCRIPT_DIR/vpn_autostart.sh"
VPNCONNECTOR="$SCRIPT_DIR/vpn_connector.sh"
AUTOSTART_SERVER=""
AUTOSTART_SERVER_DOMAIN=""
SESSION_NAME="vpn_connection"

# Enable associative arrays for easy tput colors
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

# Programm Info like author, version info and project url
proginfo="${bold}${fg[magenta]}\nwritten by Seyloria | Version 2.2 | https://github.com/Seyloria/hide.me-server-select\n${reset}"

#Function: Checks for a already running screen session
check_and_attach_screen_session() {
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
}

# Function: Server Selection via fzf
select_vpn_server() {
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
        export seldomain
        export fzfselect
    else
        echo "No selection made. Aborted..."
        exit 1
    fi

    export connection="sudo /opt/hide.me/hide.me -b resolv_backup.conf -s '$EXC_IP_RANGE' connect '$seldomain'"
}

# Function: Autostart Server Selection via fzf
select_autostart_vpn_server() {
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
        export seldomain
        export fzfselect
    else
        echo "No selection made. Aborted..."
        exit 1
    fi
}

# Function: Old Autostart Server read and display
old_autostart_txt() {
    # Read the first and second lines of the autostart file
    read AUTOSTART_SERVER < <(sed -n '1p' "$AUTOSTARTTXT")
    read AUTOSTART_SERVER_DOMAIN < <(sed -n '2p' "$AUTOSTARTTXT")

    # Display the values with formatting
    echo -e "${bold}${fg[magenta]}${uline}Current VPN Autostart Server Selection${reset}"
    echo -e "${bold}${fg[magenta]}󰒒 VPN Autostart Server:${fg[white]}        $AUTOSTART_SERVER${reset}"
    echo -e "${bold}${fg[magenta]}󰇗 VPN Autostart Server Domain:${fg[white]} $AUTOSTART_SERVER_DOMAIN\n\n${reset}"
}

# Function: New Autostart Server write and ending message
new_autostart_txt() {
    # Truncate the file to 0 size
    truncate -s 0 "$AUTOSTARTTXT" || {
        echo -e "${bold}${fg[red]}❌ Error:${fg[white]} Failed to truncate $AUTOSTARTTXT${reset}"
        return 1
    }

    # Write the fzfselect value to the file
    echo "$fzfselect" > "$AUTOSTARTTXT" || {
        echo -e "${bold}${fg[red]}❌ Error:${fg[white]} Failed to write fzfselect to $AUTOSTARTTXT${reset}"
        return 1
    }

    # Append the seldomain value to the file
    echo "$seldomain" >> "$AUTOSTARTTXT" || {
        echo -e "${bold}${fg[red]}❌ Error:${fg[white]} Failed to append seldomain to $AUTOSTARTTXT${reset}"
        return 1
    }

    # Success message
    echo -e "${bold}${fg[green]}✅ Done:${fg[white]} Successfully wrote to $AUTOSTARTTXT${reset}"
    echo -e "${bold}${fg[green]}\nBye... (｡◕‿‿◕｡)${reset}\n"
}

# Function: Checks if all required files are in place
check_required_files() {
  local missing=0

  if [[ ! -f "$SERVERSCSV" ]]; then
    echo -e "${bold}${fg[red]}❌ Error:${reset}${bold}${fg[white]} No serverlist.csv found! Expected path: $SERVERSCSV${reset}"
    missing=1
  fi

  if [[ ! -f "$AUTOSTARTTXT" ]]; then
    echo -e "${bold}${fg[red]}❌ Error:${reset}${bold}${fg[white]} No autostart-server.txt found! Expected path: $AUTOSTARTTXT${reset}"
    missing=1
  fi

  if [[ ! -f "$VPNCONNECTOR" ]]; then
    echo -e "${bold}${fg[red]}❌ Error:${reset}${bold}${fg[white]} No vpn_connector.sh found! Expected path: $VPNCONNECTOR${reset}"
    missing=1
  fi

  if [[ $missing -eq 1 ]]; then
    exit 1
  fi
}

# Function: Establishes the connection
start_new_session_and_connect() {
    if screen -list | grep -q "\.${SESSION_NAME}"; then
        echo -e "${bold}${fg[green]}\n⚕️ INFO:${fg[white]} Running detached VPN connection session detected! Attaching to running screen session '$SESSION_NAME'...\n${reset}"
        echo -e "${bold}${fg[white]}         To get back out of the session screen again press ${fg[red]}Ctrl+A + D${reset}"
        echo -e "${bold}${fg[white]}         To kill the current VPN connection press ${fg[red]}Ctrl+C\n${reset}"
        sleep 5
        screen -r "$SESSION_NAME"
        if [[ $? -ne 0 ]]; then
            echo -e "${bold}${fg[red]}❌ Error:${fg[white]} Failed to attach to screen session '$SESSION_NAME'.${reset}"
            return 1
        fi
    else
        truncate -s 0 "$SCRIPT_DIR/recent_vpn_con.log" || {
            echo -e "${bold}${fg[red]}❌ Error:${fg[white]} Failed to truncate recent_vpn_con.log.${reset}"
            return 1
        }
        screen -L -Logfile "$SCRIPT_DIR/recent_vpn_con.log" -dmS "$SESSION_NAME" bash -c "$VPNCONNECTOR" || {
            echo -e "${bold}${fg[red]}❌ Error:${fg[white]} Failed to start vpn_connector.sh and/or detached screen session '$SESSION_NAME'.${reset}"
            return 1
        }
        echo -e "${bold}\n⚕️${fg[green]} INFO:${fg[white]} Establishing connection to server '$fzfselect'\n\nDetached screen session with the name 'vpn_connection' will be running in the background.\nTo view the output, simply rerun the script or take a look at '$SCRIPT_DIR/recent_vpn_con.log'.\nIt's safe to close the terminal now!\n${reset}"
        echo -e "${bold}${fg[green]}Bye... (｡◕‿‿◕｡)${reset}\n"
        sleep 3
    fi
}

connector_autostart() {
    # Reset log
    truncate -s 0 "$SCRIPT_DIR/recent_vpn_con.log" || {
        echo -e "${bold}${fg[red]}❌ Error:${fg[white]} Failed to truncate recent_vpn_con.log.${reset}"
        return 1
    }

    # Run connector script with autostart option in a detached screen session with logging
    screen -L -Logfile "$SCRIPT_DIR/recent_vpn_con.log" -dmS "$SESSION_NAME" bash -c "$VPNCONNECTOR --syslaunch" || {
        echo -e "${bold}${fg[red]}❌ Error:${fg[white]} Failed to start vpn_connector.sh and/or detached screen session '$SESSION_NAME'.${reset}"
        return 1
    }
}


# Function: Change working dir to excute the hide.me binary
execdir() {
  cd /opt/hide.me/ || {
    echo "Failed to change to /opt/hide.me/. Aborting."
    exit 1
  }
}
