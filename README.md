# NixKits
Some basic configuraion for NixOS.</br>
...and a workaround for vscode-server-workround.
## Env Vars
For extra features, pass these to the script.
### Custom NixCache and/or NixChannel
'''
sudo NIC_URL="your.cache.server/cachePath" NIR_URL="your.channel.server/channelPath" ./kix.sh
'''
### Mihox Service
This service run before mihomo and automatically update the config from subscription url..
```
sudo MHX_URL="your.provider/identifer" ./kix.sh
```
