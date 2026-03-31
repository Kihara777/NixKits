# NixKits
Some basic configuraion for NixOS.</br>
...and a workaround for vscode-server-workround.
## VS Code in WSL
If you see ```/Path/to/Code.exe: cannot execute binary file: Exec format error```,</br>
make sure 
```
wsl.interop.register = true;
```
is enabled in your base config.
## Mihox Service
This service run before mihomo. To use it, pass ```$MHX_URL``` to the script.
```
sudo MHX_URL="your.provider/identifer" ./kix.sh
```
