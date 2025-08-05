```
   ██╗  ██╗██╗██████╗ ███████╗   ███╗   ███╗███████╗   
   ██║  ██║██║██╔══██╗██╔════╝   ████╗ ████║██╔════╝   
   ███████║██║██║  ██║█████╗     ██╔████╔██║█████╗     
   ██╔══██║██║██║  ██║██╔══╝     ██║╚██╔╝██║██╔══╝     
   ██║  ██║██║██████╔╝███████╗██╗██║ ╚═╝ ██║███████╗   
   ╚═╝  ╚═╝╚═╝╚═════╝ ╚══════╝╚═╝╚═╝     ╚═╝╚══════╝   
   ┏━┓┏━╸┏━┓╻ ╻┏━╸┏━┓   ┏━┓┏━╸╻  ┏━╸┏━╸╺┳╸             
   ┗━┓┣╸ ┣┳┛┃┏┛┣╸ ┣┳┛   ┗━┓┣╸ ┃  ┣╸ ┃   ┃              
   ┗━┛┗━╸╹┗╸┗┛ ┗━╸╹┗╸   ┗━┛┗━╸┗━╸┗━╸┗━╸ ╹
```
<br/>

This small linux bash script lets you easily switch the hide.me VPN Server by making use of the official [Hide.me CLI VPN client for Linux](https://github.com/eventure/hide.client.linux).
There is no need for systemd as it only uses the basic hide.me CLI client, which makes it possible to run on any distro the client itself is compatible with.
<br/>


![Showcase](/showcase.gif)

## :dna: Dependencies
In addition to the [official Hide.me client](https://github.com/eventure/hide.client.linux) you only need two small and common tools, both of which are available in practically any distro.
- [Hide.me CLI VPN client for Linux](https://github.com/eventure/hide.client.linux)
- [GNU Screen](https://www.gnu.org/software/screen/)
- [fzf](https://github.com/junegunn/fzf)
- Optional: A type of [Nerd Font](https://www.nerdfonts.com/) is recommended to avoid broken characters and symbols.
<br/>

## :floppy_disk: Installation
Open a terminal and navigate to where you want to store the script files(Example: ~/vpn-select/ =  your home directory would be suitable).
Then copy the following curl download url's into your terminal and hit enter:
```sh
curl -O  https://raw.githubusercontent.com/Seyloria/hide.me-server-select/main/config.sh
curl -O  https://raw.githubusercontent.com/Seyloria/hide.me-server-select/main/vpnselect.sh
curl -O  https://raw.githubusercontent.com/Seyloria/hide.me-server-select/main/vpnselect-autostartserver.sh
curl -O  https://raw.githubusercontent.com/Seyloria/hide.me-server-select/main/vpnautostart.sh
curl -O  https://raw.githubusercontent.com/Seyloria/hide.me-server-select/main/autostart-server.txt
curl -O  https://raw.githubusercontent.com/Seyloria/hide.me-server-select/main/serverlist.csv
```
<br/>

Make sure the following script files are executable by setting the chmod permissions:
```sh
chmod +x vpnselect.sh
chmod +x vpnselect-autostartserver.sh
chmod +x vpnautostart.sh
```
<br/>

### :no_entry_sign: Exlude IP range in the **<ins>config.sh</ins>**
To exlude an IP range(CIDR) that should not be routed via the VPN connection.
Typically our own LAN or another VPN mesh network like tailscale.
Edit the this variable at the top of the **<ins>config.sh</ins>**
> EXC_IP_RANGE="192.168.55.0/24,100.64.0.0/10"
<br/>

### :key: Making script executable without manual sudo escalation
Changing the VPN connection via the hide.me CLI client requires sudo privileges.
To make this script work, the CLI client needs to be added to the sudoers file with the NOPASSWD option.
Type 'sudo visudo' and add the following line somewhere near the end of the file(edit your username!):
```
sudo visudo
```
```
your_username ALL=(ALL:ALL) NOPASSWD: /opt/hide.me/hide.me
```
:warning: Be careful to not mess up this file, otherwhise you might brick your user permissions!
<br/>
<br/>

## :link: Optional Settings

### Shortcut via alias
Additionally you can add the following line to your .bashrc, .zshrc or config.fish:
```sh
alias vpn="~/path-to-your-script-inside_your_home_directory/vpnselect.sh"
```
This will create an alias with the name "vpn"(edit it to your liking), just customize the path to where you saved the script.
Afterwards you can call the script by simply typing "vpn" into your terminal, no matter in which directory you currently are.
<br/>
<br/>

### Autostart
You may wish to set up a VPN connection when starting up your system.
There are multiple ways to achieve this, depending on your distro and/or desktop environment.
Here is a basic way as an example:
> Add the **vpnautostart.sh** to your systems autostart
> Run the **vpnselect-autostartserver.sh**(In your script folder type ./vpnselect-autostartserver.sh) and choose a new Autostart VPN Server.
<br/>
<br/>

## :scroll: Changelog and current state (dd-mm-yyyy)

- [x] 05-08-2025 | v2.0 | Major rewrite to incorporate a config file
- [x] 03-08-2025 | v1.2 | Basic Autostart Script added.
- [x] 03-08-2025 | v1.0 | Basic showcase version. Basic functionality done.
<br/>

## :construction: In the works
- Atm the hide.me CLI client sometimese fails to to write back the resolv.conf on session logout(system restart). Goal is to run the established connection screen session from a seperate script that traps the session logout.
- if you got any wishes or idea, let me know! 
<br/>

---
### Disclamer

> **This is a private project and I am neither a developer nor affiliated with Hide.me in any way. I am only sharing this because it might help others. If you want to fork it, go ahead! If you find any errors or got suggestions, please let me know!**
