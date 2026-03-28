#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Sudo is required for replacing nix config."
    exit 1
elif [ ! -f $CONF_MAIN ]; then
  echo "Main nix config file is missing!"
  exit 1
fi

CONF_DIR="/etc/nixos"
CONF_MAIN="$CONF_DIR/configuration.nix"
CONF_BASE="$CONF_DIR/base.nix"
CONF_VSC="$CONF_DIR/vscode.nix"
CONF_KIX="$CONF_DIR/kits.nix"
CONF_VSC_URL="https://raw.githubusercontent.com/K900/vscode-remote-workaround/main/vscode.nix"
KIX_USER='kix'
KIX_HOSTNAME='HarukaX'

if [ ! -f $CONF_BASE ]; then
  mv $CONF_MAIN $CONF_BASE
  cat <<CFM> $CONF_MAIN
{ config, ... }:

{
  imports = 
  [
    "$CONF_BASE"
    "$CONF_VSC"
    "$CONF_KIX"
  ];
}
CFM
fi

curl -Lo "$CONF_VSC" "$CONF_VSC_URL"
sed -i 's/nodejs-\([0-9]\+\)_x/nodejs_latest/g' "$CONF_VSC"

cat <<CFK> "$CONF_KIX"
{ config, pkgs, ... }:

{
  #
  # Kitsunori Customization
  #

  # Nix Channel
  #nix.nixPath = [ "nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-unstable-small.tar.gz" ];
  
  # Features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Software
  environment.systemPackages = with pkgs;
  [
    # Utilities
    fastfetch
    # Develop
    github-cli git
  ];
  
  # Desktop
  #services.displayManager.sddm.enable = true;
  #services.dIsplayManager.sddm.wayland.enable = true;
  #services.desktopManager.plasma6.enable = true;
  
  # Auto System Update
  system.autoUpgrade.enable = true;
  #system.autoUpgrade.allowReboot = true;
  
  # VS Code
  vscode-remote-workaround.enable = true;

  # Hostname
  networking.hostName = "$kix_hostname";

  # Fonts
  #fonts.enableDefaultPackages = true;
  #fonts.packages = with pkgs; [ terminus_font terminus_font_ttf ];
  
  # Containers
  #users.users.$kix_user.extraGroups = [ "docker" ];
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless.enable = true;
  virtualisation.docker.rootless.setSocketVariable = true;
}
CFK
nix-channel --add https://channels.nixos.org/nixos-unstable-small nixos
nixos-rebuild switch --upgrade
