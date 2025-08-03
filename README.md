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
 

This small linux bash script lets you easily switch the hide.me VPN Server by making use of the official [Hide.me CLI VPN client for Linux](https://github.com/eventure/hide.client.linux).
There is no need for systemd as it only uses the basic hide.me CLI client, which makes it possible to run on any distro the client itself is compatible with.


## Dependencies
The following dependencies are needed. They are both quite small and are basically available on nearly all distributions.
- [GNU Screen](https://www.gnu.org/software/screen/)
- [fzf](https://github.com/junegunn/fzf)
- Optional: A type of [Nerd Font](https://www.nerdfonts.com/) is recommended to avoid broken characters and symbols.


## Installation
Install the [Hide.me CLI VPN client for Linux](https://github.com/eventure/hide.client.linux) as described.

Open a terminal and navigate to where you want to store the script **and** serverlist.csv(~/vpn-select/ =  your home directory for example).
Then copy the following code into your terminal to download both files:
```sh
curl -O  https://raw.githubusercontent.com/Seyloria/hide.me-server-select/main/vpnselect.sh
curl -O  https://raw.githubusercontent.com/Seyloria/hide.me-server-select/main/vpnselect-autostartserver.sh
curl -O  https://raw.githubusercontent.com/Seyloria/hide.me-server-select/main/vpnautostart.sh
curl -O  https://raw.githubusercontent.com/Seyloria/hide.me-server-select/main/autostart-server.txt
curl -O  https://raw.githubusercontent.com/Seyloria/hide.me-server-select/main/serverlist.csv
```

Make sure the script is executable by setting the chmod permissions:
```sh
chmod +x vpnselect.sh
chmod +x vpnselect-autostartserver.sh
chmod +x vpnautostart.sh
```


Changing the VPN connection via the hide.me CLI client requires sudo privileges.
To make this script work, either the CLI client or the scripts itself need to be added to the sudoers file.
Type 'sudo visudo' and add the following line somewhere near the end of the file:
```
sudo visudo
```
```
your_username ALL=(ALL:ALL) NOPASSWD: /opt/hide.me/hide.me
```
Be careful to not mess up this file, otherwhise you might brick your user permissions!


## Optional Settings
Additionally you can add the following line to your .bashrc, .zshrc or config.fish:
```sh
alias vpn="~/path-to-your-script-inside_your_home_directory/vpnselect.sh"
```
This will create an alias with the name "vpn"(edit it to the name you like), you just have to customize the path to where you saved the script inside your home directory.
Afterwards you can open up the script by simply typing "vpn" into your terminal.


You may wish to set up a VPN connection when you start up your system.
There are multiple ways to achieve this, depending on your distribution and/or desktop environment.
Here is a basic way as an example:
```sh
Run the **vpnselect-autostartserver.sh** script to choose a new autostart vpn server.
Afterwards add the **vpnautostart.sh** to your systems autostart.
```

## Changelog and current state (dd-mm-yyyy)

- [☑️] 03-08-2025 | v1.2 | Basic Autostart Script added.
- [☑️] 03-08-2025 | v1.0 | Basic showcase version. Basic functionality done.

### Disclamer

This is a private project and i am not a dev, nor am i Hide.me related in any form.
I only share this, because it might help others. If you wanna fork it, do so.
If you find any errors, please let me know!
