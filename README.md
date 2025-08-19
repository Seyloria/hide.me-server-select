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

This small linux bash script lets you easily switch the hide.me VPN Server by making use of the [Official hide.me CLI VPN client for Linux](https://github.com/eventure/hide.client.linux).
There is no need for systemd as it only uses the basic hide.me CLI client, which makes it possible to run on any distro the client itself is compatible with.
<br/>
<br/>

## :beginner: Features & How It Works
Thx to [fzf](https://github.com/junegunn/fzf) you get a pretty and filterable list of all the hide.me servers to choose from. With the help of [GNU Screen](https://www.gnu.org/software/screen/), the script can run in the background without the need for an open terminal. You can even set a new [Autostart Server](#autostart) which starts the VPN connection on session login. It also fixes the raw CLI client's inability to correctly rewrite **`/etc/resolv.conf`** when shutting down the system without first disconnecting the VPN connection(see [Autostart Section](#autostart)).
<br/>

![Showcase](/showcase.gif)
<br/>
<br/>

## :dna: Dependencies
In addition to the [Official hide.me client](https://github.com/eventure/hide.client.linux) you only need two small and common tools, both of which are available in practically any distro.
- [hide.me CLI VPN client for Linux](https://github.com/eventure/hide.client.linux)
- [GNU Screen](https://www.gnu.org/software/screen/) - Let's you run the VPN connection in the background
- [fzf](https://github.com/junegunn/fzf) - Gives you those fancy menu's
- **Optional:** A type of [Nerd Font](https://www.nerdfonts.com/) is recommended to avoid broken characters and symbols.
<br/>

## :floppy_disk: Installation
Open a terminal and navigate to where you want to store the script files(Example: **`~/vpn/`** =  your home directory would be suitable).
Then copy the following curl download url's into your terminal and hit enter:
```sh
curl -O  https://raw.githubusercontent.com/Seyloria/hide.me-server-select/main/config.sh
curl -O  https://raw.githubusercontent.com/Seyloria/hide.me-server-select/main/vpn_select.sh
curl -O  https://raw.githubusercontent.com/Seyloria/hide.me-server-select/main/vpn_connector.sh
curl -O  https://raw.githubusercontent.com/Seyloria/hide.me-server-select/main/serverlist.csv
curl -O  https://raw.githubusercontent.com/Seyloria/hide.me-server-select/main/autostart-server.txt
```
<br/>

Make sure the following script files are executable by setting the correct file permissions via chmod:
```sh
chmod +x vpn_select.sh
chmod +x vpn_connector.sh
```
<br/>

### :no_entry_sign: Exlude IP range in the **<ins>config.sh</ins>**
To exlude an IP range(CIDR) that should not be routed via the VPN connection.
Typically our own LAN or another VPN mesh network like tailscale.
Edit this variable at the top of the **<ins>config.sh</ins>**
> EXC_IP_RANGE="192.168.55.0/24,100.64.0.0/10"
<br/>

### :key: Making the script work without manual sudo escalation
Changing the VPN connection via the hide.me CLI Client and the **cp** command inside the vpn_connector.sh require sudo privileges.
Therefor, the CLI Client and the exact **cp** command need to be added to the sudoers file with the NOPASSWD option.
Type **'sudo visudo'** and add the following lines somewhere near the end of the file(don't forget to replace your username!):
```
sudo visudo
```
```
your_username ALL=(ALL:ALL) NOPASSWD: /opt/hide.me/hide.me
your_username ALL=(ALL:ALL) NOPASSWD: /bin/cp /opt/hide.me/resolv_backup.conf /etc/resolv.conf
```
:warning: Be careful to not mess up this file, otherwhise you might brick your user permissions!
<br/>
<br/>

### :rocket: Autostart
From version >= 4.0 on the autostart feature should be used no matter a autostart server is set or not.
This ensures that the **`/etc/resolv.conf`** gets correctly written back on syslaunch, otherwise you might end up with broken dns resolution.(This is a flaw in the [Official hide.me CLI VPN client for Linux](https://github.com/eventure/hide.client.linux) not this script!)
There are multiple ways to set the autostart, depending on your distro and/or desktop environment.
Here is a basic way as an example:
> In CLI run the **vpn_select.sh** with the **`--autostart`** flag and choose a new Autostart VPN Server.
> To invoke the correct startup behavior, the **vpn_select.sh** needs to be launched with the **`--syslaunch`** flag via your distro's autostart mechanism. An example desktop entry for **GNOME** can be found in the [Autostart directory](/Autostart/)(file path usually **`~/.config/autostart/`**). Other distro's may have their own unique mechanism.
<br/>
<br/>

## :link: Optional Settings

### :heavy_equals_sign: Shortcut via alias
Additionally you can add the following line to your **.bashrc**, **.zshrc** or **config.fish**:
```sh
alias vpn="~/path-to-your-script-inside_your_home_directory/vpn_select.sh"
```
This will create an alias with the name **`vpn`**(edit it to your liking), just customize the path to where you saved the script.
Afterwards you can call the script by simply typing **`vpn`** into your terminal, no matter in which directory you currently are.
<br/>
<br/>

## :scroll: Changelog and current state (dd-mm-yyyy)

- [x] 11-08-2025 | v4.3 | Small code and comment cleanup
- [x] 11-08-2025 | v4.2 | Watching current log is now searchable and made the menu fancier
- [x] 10-08-2025 | v4.0 | Rewrite now with a fancy selection menu. resolv.conf issue now completely fixed. Everyone should use the vpn_select.sh --syslaunch by now, even if no autostart server is set. This keeps the resolv.conf writeback working correctly.
- [x] 09-08-2025 | v3.0 | The broken CLI Client behavior for the resolv.conf writeback on system shutdown/restart/logout has been fixed. There are no known issues atm and the tool now is more or less finished.
- [x] 07-08-2025 | v2.5 | Another Major rewrite to incorporate less files and make autostart more reliable.
- [x] 05-08-2025 | v2.2 | Basic Autostart works. Tested only on GNOME so far
- [x] 05-08-2025 | v2.0 | Major rewrite to incorporate a config file
- [x] 03-08-2025 | v1.2 | Basic Autostart Script added.
- [x] 03-08-2025 | v1.0 | Basic showcase version. Basic functionality done.
<br/>

## :construction: In the works
- [x] Nothing atm, the tool is more or less finished. If you have any wishes or ideas, please let me know!
<br/>

---
### :cyclone: Disclamer

> **This is a private project and I am neither a developer nor affiliated with Hide.me in any way. I am only sharing this because it might help others. If you want to fork it, go ahead! If you find any errors or got suggestions, please let me know!**
