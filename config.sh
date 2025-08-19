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
proginfo="${bold}${fg[magenta]}\nwritten by Seyloria | Version 4.2 | https://github.com/Seyloria/hide.me-server-select\n${reset}"

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
        echo -e "${bold}🚪${fg[yellow]} Info:${fg[white]}No selection made. Aborted...${reset}"
        exit 1
    fi
}

# Function: Old Autostart Server read and display
old_autostart_txt() {
    # Read the first and second lines of the autostart file
    read AUTOSTART_SERVER < <(sed -n '1p' "$AUTOSTARTTXT")
    read AUTOSTART_SERVER_DOMAIN < <(sed -n '2p' "$AUTOSTARTTXT")
    if [[ -s "$AUTOSTARTTXT" ]]; then
        read AUTOSTART_SERVER < <(sed -n '1p' "$AUTOSTARTTXT")
        read AUTOSTART_SERVER_DOMAIN < <(sed -n '2p' "$AUTOSTARTTXT")
        # Display the values with formatting
        echo -e "${bold}${fg[magenta]}${uline}Current VPN Autostart Server Selection${reset}"
        echo -e "${bold}${fg[magenta]}󰒒 VPN Autostart Server:${fg[white]}        $AUTOSTART_SERVER${reset}"
        echo -e "${bold}${fg[magenta]}󰇗 VPN Autostart Server Domain:${fg[white]} $AUTOSTART_SERVER_DOMAIN\n\n${reset}"
    else
        echo -e "${bold}${fg[magenta]}${uline}Current VPN Autostart Server Selection${reset}"
        echo -e "${bold}${fg[magenta]}󰒒 VPN Autostart Server:${fg[white]}        None${reset}"
        echo -e "${bold}${fg[magenta]}󰇗 VPN Autostart Server Domain:${fg[white]} None\n\n${reset}"
    fi
    
}

autostart_select() {
    # Build menu options array
    options=(
        "Select New VPN Autostart Server"
        "Exit"
    )

    # Add 'Disable VPN Autostart' only if file exists and is non-empty
    if [[ -s "$AUTOSTARTTXT" ]]; then
        # Insert 'Disable VPN Autostart' before Exit
        options=(
            "Select New VPN Autostart Server"
            "Disable VPN Autostart"
            "Exit"
        )
    fi
    
    choice=$(
        printf "%s\n" \
            "${options[@]}" |
        fzf --height=10% \
            --color="header:green,prompt:green,fg+:magenta:bold" \
            --reverse \
            --border \
            --no-info \
            --disabled \
            --prompt '' \
            --header=$'\n(✿◠‿◠)  Please select an option  (◕‿◕✿)\n\n' \
            --bind "change:clear-query"
    )

    if [[ -z "$choice" ]]; then
        echo -e "${bold}🚪${fg[yellow]} Info:${fg[white]}No selection made. Aborted...${reset}"
        exit 1
    fi

    case "$choice" in
        "Select New VPN Autostart Server")
            select_autostart_vpn_server
            new_autostart_txt
            ;;
        "Disable VPN Autostart")
            if truncate -s 0 "$AUTOSTARTTXT"; then
                echo -e "${bold}${fg[green]}⚕️ INFO:${fg[white]} Disabled VPN Autostart Server and cleared '$AUTOSTARTTXT'\n${reset}"
            else
                echo "❌ Error: Failed to truncate and clear '$AUTOSTARTTXT'"
                exit 1
            fi
            ;;
        "Exit")
            echo -e "${bold}🚪${fg[yellow]} Exit:${fg[green]} Bye... (｡◕‿‿◕｡)\n${reset}"
            exit 0
            ;;
    esac
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

# Function: Check for script dependencies
check_dependencies() {
    local deps=("screen" "fzf")
    local missing=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done

    if (( ${#missing[@]} > 0 )); then
        echo -e "${bold}${fg[red]}❌ Error:${fg[white]} Missing dependencies: ${fg[red]}${missing[*]}${reset}"
        echo -e "${bold}${fg[white]}          Please install them before running this script${reset}"
        echo -e "${bold}\n🚪${fg[red]}  Exit:${fg[white]} Bye... ${fg[red]}( ✜︵✜ )\n${reset}"
        exit 1
    fi
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
    echo -e "${bold}\n🚪${fg[red]}  Exit:${fg[white]} Bye... ${fg[red]}( ✜︵✜ )\n${reset}"
    exit 1
  fi
}

# Function: Checks if there is a backup_resolv.conf and writes it back on syslaunch
write_backup_resolv_conf() {
    local backup_file="/opt/hide.me/resolv_backup.conf"

    if [[ -f "$backup_file" ]]; then
        if sudo cp "$backup_file" /etc/resolv.conf; then
            echo -e "${bold}${fg[green]}\n⚕️ INFO:${fg[white]} /etc/resolv.conf overwritten successfully from $backup_file\n${reset}"
        else
            echo -e "${bold}${fg[red]}\n❌ ERROR:${fg[white]} Failed to overwrite /etc/resolv.conf\n${reset}"
            return 1
        fi
    else
        echo -e "${bold}${fg[green]}\n⚕️ INFO:${fg[white]} No backup file found at: $backup_file\n${reset}"
        return 1
    fi
}

vpnserver_select() {
    while true; do
        # Build menu options array
        options=("Select new VPN Server connection" "Exit")

        # Add extra options if screen session is active
        if screen -list | grep -q "\.${SESSION_NAME}"; then
            options=(
                "Terminate current VPN Server connection"
                "See current VPN Server connection log"
                "Select new VPN Server connection"
                "Exit"
            )
        fi
        
        choice=$(
            printf "%s\n" "${options[@]}" |
            fzf --height=10% \
                --color="header:green,prompt:green,fg+:magenta:bold" \
                --reverse \
                --border \
                --no-info \
                --disabled \
                --prompt '' \
                --header=$'\n(✿◠‿◠)  Please select an option  (◕‿◕✿)\n\n' \
                --bind "change:clear-query"
        )

        if [[ -z "$choice" ]]; then
            echo -e "${bold}🚪${fg[yellow]} Info:${fg[white]} No selection made. Aborted...${reset}"
            exit 1
        fi

        case "$choice" in
            "Terminate current VPN Server connection")
                screen -S "$SESSION_NAME" -X stuff $'\003'
                echo -e "${bold}🚪${fg[yellow]} Exit:${fg[green]} VPN connection terminating...${reset}"
            
                # Wait until the session disappears
                while screen -list | grep -q "\.${SESSION_NAME}"; do
                    sleep 0.2
                done
            
                echo -e "${bold}✅${fg[green]} Termination complete. Returning to menu...${reset}"
                ;;
            "See current VPN Server connection log")
                bash -c "tr -d '\r' < '$SCRIPT_DIR/recent_vpn_con.log' | \
                    fzf --ansi \
                        --no-info \
                        --border \
                        --layout=reverse \
                        --height=60% \
                        --prompt='Search log ⧐ ' \
                        --header 'Press CTRL+C, Ctrl+Q or Escape to return to menu' \
                        --color="header:green,prompt:green,fg+:magenta:bold" \
                        --preview-window=follow"
                ;;
            "Select new VPN Server connection")
                select_vpn_server
                start_new_session_and_connect
                break
                ;;
            "Exit")
                echo -e "${bold}🚪${fg[yellow]} Exit:${fg[green]} Bye... (｡◕‿‿◕｡)\n${reset}"
                break  # Exit the loop
                ;;
        esac
    done
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
        echo -e "${bold}${fg[magenta]}\n󰒒 Selected Server:${fg[white]} $fzfselect${reset}"
        echo -e "${bold}${fg[magenta]}󰇗 Server Domain:${fg[white]}   $seldomain\n${reset}"
        export seldomain
        export fzfselect
    else
        echo "No selection made. Aborted..."
        exit 1
    fi

    export connection="sudo /opt/hide.me/hide.me -b resolv_backup.conf -s '$EXC_IP_RANGE' connect '$seldomain'"
}

# Function: Establishes the connection
start_new_session_and_connect() {
    if screen -list | grep -q "\.${SESSION_NAME}"; then
        echo -e "${bold}${fg[green]}⚕️ INFO:${fg[white]} Running detached VPN connection session detected!${reset}"
        echo -e "${bold}${fg[white]}         Killing running VPN Connection in screen session '$SESSION_NAME'${reset}"
        screen -S "$SESSION_NAME" -X stuff $'\003'
        timeout=10
        elapsed=0
        
        while screen -list | grep -q "\.${SESSION_NAME}"; do
            if (( elapsed >= timeout )); then
                echo -e "${bold}${fg[red]}❌ Error:${fg[white]} Timeout reached: screen session '$SESSION_NAME' is still running.\n plz terminate manually!${reset}"
                break
            fi
            sleep 1
            ((elapsed++))
        done
        
        if (( elapsed < timeout )); then
            echo -e "${bold}${fg[white]}         Screen session '$SESSION_NAME' has ended\n${reset}"
        fi
        truncate -s 0 "$SCRIPT_DIR/recent_vpn_con.log" || {
            echo -e "${bold}${fg[red]}❌ Error:${fg[white]} Failed to truncate recent_vpn_con.log.${reset}"
            return 1
        }
        screen -L -Logfile "$SCRIPT_DIR/recent_vpn_con.log" -dmS "$SESSION_NAME" bash -c "$VPNCONNECTOR" || {
            echo -e "${bold}${fg[red]}❌ Error:${fg[white]} Failed to start vpn_connector.sh and/or detached screen session '$SESSION_NAME'.${reset}"
            return 1
        }
        echo -e "${bold}${fg[green]}⚕️ INFO:${fg[white]} Establishing connection to server '$fzfselect'\n\nBackground VPN Connection now running in a detached screen session named 'vpn_connection'\nIt's safe to close the terminal now!\n${reset}"
        echo -e "${bold}${fg[green]}Bye... (｡◕‿‿◕｡)${reset}\n"
        sleep 3
    else
        truncate -s 0 "$SCRIPT_DIR/recent_vpn_con.log" || {
            echo -e "${bold}${fg[red]}❌ Error:${fg[white]} Failed to truncate recent_vpn_con.log${reset}"
            return 1
        }
        screen -L -Logfile "$SCRIPT_DIR/recent_vpn_con.log" -dmS "$SESSION_NAME" bash -c "$VPNCONNECTOR" || {
            echo -e "${bold}${fg[red]}❌ Error:${fg[white]} Failed to start vpn_connector.sh and/or detached screen session '$SESSION_NAME'${reset}"
            return 1
        }
        echo -e "${bold}${fg[green]}⚕️ INFO:${fg[white]} Establishing connection to server '$fzfselect'\n\nBackground VPN Connection now running in a detached screen session named 'vpn_connection'\nIt's safe to close the terminal now!\n${reset}"
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
