#!/usr/bin/env bash

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
CONF_MHX="$CONF_DIR/mihomo.nix"
CONF_KIX="$CONF_DIR/kits.nix"
CONF_VSC_URL="https://raw.githubusercontent.com/K900/vscode-remote-workaround/main/vscode.nix"
KIX_USER="kix"
KIX_HOSTNAME="HarukaX"
MHX_FILE="/etc/mihomo/config.yaml"
MHX_DIR="${MHX_FILE%/*}"

if [ ! -f $CONF_BASE ]; then
  mv $CONF_MAIN $CONF_BASE
fi
cat <<CFM> "$CONF_MAIN"
{ config, ... }:

{
  imports =
  [
    "$CONF_BASE"
    "$CONF_VSC"
    "$CONF_MHX"
    "$CONF_KIX"
  ];
}
CFM

if curl -sfLo "$CONF_VSC" "$CONF_VSC_URL"; then
  echo "VS Code workaround downloaded."
else
  echo "Failed to download VS Code workaroun."
  exit 1
fi
echo "Preparing workaround for workaround..."
sed -i 's/nodejs-\([0-9]\+\)_x/nodejs_latest/g' "$CONF_VSC"

cat <<CFH> "$CONF_MHX"
{ config, lib, pkgs, ... }:

let
  cfg = config.services.mihox;
  configDir = "$MHX_DIR";
  configFile = "$MHX_FILE";
CFH
cat <<'CFH'>> "$CONF_MHX"
in
{
  options.services.mihox =
  {
    enable = lib.mkEnableOption "Subscription auto updater for mihomo";
    
    url = lib.mkOption
    {
      type = lib.types.str;
      description = "Mihomo subscripition";
      example = "your.provider/identifer";
    };
    
    interval = lib.mkOption
    {
      type = lib.types.str;
      default = "weekly";
      description = "Accept systemd time format like 'hourly', 'daily', '*:0/30'. Leave empty to disable";
    };
  };
  
  config = lib.mkIf cfg.enable
  {
    systemd.services.mihox =
    {
      description = "Fetch mihomo config and restart mihomo";
      requires = [ "network-online.target" ];
      before = [ "mihomo.service" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig =
      {
        Type = "oneshot";
        User = "root";
        ExecStart = pkgs.writeShellScript "update-mihomo-config"
        ''
          tmp=$(mktemp)
          mkdir -p "${configDir}"
          if ${pkgs.curl}/bin/curl -fsLo "$tmp" ${cfg.url}; then
            cp "$tmp" "${configFile}"
            rm -f "$tmp"
            echo "Subscription updated."
          else
            echo "Failed to update subscription."
            exit 1
          fi
        '';
      };
    };
    
    systemd.timers.mihox = lib.mkIf (cfg.interval != "")
    {
      description = "Timer for mihomo config update";
      wantedBy = [ "timers.target" ];
      timerConfig =
      {
        OnCalendar = "${cfg.interval}";
        Persistent = true;
      };
    };
  };
}
CFH

cat <<CFK> "$CONF_KIX"
{ config, pkgs, ... }:

{
  #
  # Kitsunori Customization
  #
  
  # Features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Software
  environment.systemPackages = with pkgs;
  [
    # Utilities
    fastfetch wget
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
  vscode-remote-workaround.package = pkgs.nodejs_latest;
  
  
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
CFK

if curl -sfIL "https://$MHX_URL" &>/dev/null; then
  echo "Mihomo subscription found."
  cat <<CFKH>> "$CONF_KIX"
  services.mihox =
  {
    enable = true;
    url = "$MHX_URL";
    interval = "";
  };

  services.mihomo =
  {
    enable = true;
    configFile = "$MHX_FILE";
    tunMode = true;
  };
}
CFKH
else
  cat <<CFKH>> "$CONF_KIX"
}
CFKH
fi

nix-channel --add https://channels.nixos.org/nixos-unstable-small nixos
nixos-rebuild switch --upgrade-all
nix-store --gc
