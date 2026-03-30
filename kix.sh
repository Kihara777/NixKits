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

curl -sLo "$CONF_VSC" "$CONF_VSC_URL"
sed -i 's/nodejs-\([0-9]\+\)_x/nodejs_latest/g' "$CONF_VSC"

cat <<'CFH'> "$CONF_MHX"
{ config, lib, pkgs, ... }:

let
  cfg = config.services.mihox;
  configDir = "/var/lib/mihomo";
  configFile = "${configDir}/config.yaml";
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
    systemd.tmpfiles.rules =
    [
      "d ${configDir} 0755 mihomo mihomo -"
    ];

    systemd.services.mihox-prepare =
    {
      description = "Prepare initial mihomo config";
      before = [ "mihomo.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig =
      {
        Type = "oneshot";
        User = "mihomo";
        ExecStart =
        "
          ${pkgs.curl}/bin/curl -Lo ${configFile}.tmp ${cfg.url} \
          && mv ${configFile}.tmp ${configFile} \
          || true
        ";
      };
    };

    systemd.services.mihox-fetcher =
    {
      description = "Fetch mihomo subscription";
      serviceConfig =
      {
        Type = "oneshot";
        User = "mihomo";
        ExecStart =
        "
          ${pkgs.curl}/bin/curl -Lo ${configFile}.tmp ${cfg.url} \
          && mv ${configFile}.tmp ${configFile}
        ";
        ExecStartPost = "${pkgs.systemd}/bin/systemctl try-restart mihomo.service";
      };
    };

    systemd.timers.mihoz-fetcher = lib.mkIf (cfg.interval != "")
    {
      description = "Timer for mihomo fetcher";
      wantedBy = [ "timers.target" ];
      timerConfig =
      {
        OnCalendar = cfg.interval;
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
CFK

if curl  -sfIL "https://$MHX_URL" &>/dev/null; then
  echo "Mihomo subscription found."
  cat <<CFKH>> "$CONF_KIX"
  services.mihox =
  {
    enable = true;
    url = "$MHX_URL";
    #interval = "weekly";
  };

  services.mihomo = 
  {
    enable = true;
    configFile = "/var/lib/mihomo/config.yaml";
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
nixos-rebuild switch --upgrade
