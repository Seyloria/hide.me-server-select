# hide.me-server-select

This small linux bash script lets you easily switch the hide.me VPN Server by making use of the official [Hide.me CLI VPN client for Linux](https://github.com/eventure/hide.client.linux).
There is no need for systemd.

## Dependencies
The following dependencies are needed, both quite small and basically available on nearly all distros
- [GNU Screen](https://www.gnu.org/software/screen/)
- [fzf](https://github.com/junegunn/fzf)

## Installation
Install the [Hide.me CLI VPN client for Linux](https://github.com/eventure/hide.client.linux) as described.


Open a terminal and navigate to where you want to store the script **and** serverlist.csv(~/vpn-select/ =  your home directory for example).
Then copy the following code into your terminal to download both files:

```sh
curl -O  https://raw.githubusercontent.com/Seyloria/hide.me-server-select/main/vpnselect.sh
curl -O  https://raw.githubusercontent.com/Seyloria/hide.me-server-select/main/vpnselect-autostart.sh
curl -O  https://raw.githubusercontent.com/Seyloria/hide.me-server-select/main/serverlist.csv
```

Make sure the script is executable by setting the chmod permissions:
```sh
chmod +x vpnselect.sh
```


The changing the vpn connection via the hide.me CLI client need sudo privileges.
In order do make this script work the CLI client or this script needs to be added to the sudoers file.
Type sudo visudo and at the following line near the somewhere near the end of the file.
Be careful to not mess up this file, otherwhise you might brick your user permissions!
```
sudo visudo
your_username ALL=(ALL:ALL) NOPASSWD: /opt/hide.me/hide.me
```


## Optional Settings
Additionally you can add the following line to your .bashrc, .zshrc or config.fish:
```sh
alias vpn="~/path-to-your-script-inside_your_home_directory/vpnselect.sh"
```
This will create an alias with the name "vpn"(edit it to the name you like), you just have to customize the path to where you saved the script inside your home directory.
Afterwards you can open up the script by simply typing "vpn" into your terminal.


You may want to esteblish a vpn connection on system startup.
This can be achived in several ways depending on your distro and/or DE.
Here is a basic example:
```sh
Info comming soon...
```

## Changelog and current state

- [☑️] 18-04-2024 | v1.0 | Basic showcase version. Basic funtionality done

### Disclamer

This is a private project and i am not a dev, nor am i Hide.me related in any form.
I only share this, because it might help others. If you wanna fork it, do so.
If you find any errors, please let me know!
