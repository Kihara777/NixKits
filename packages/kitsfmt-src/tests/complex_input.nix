{ pkgs, lib, config, ... }:
let
  # Version management
  version = "1.0.0";
  name = "my-app";

  # Core libraries
  inherit (pkgs) stdenv fetchFromGitHub cmake;
  inherit (lib) mkOption types mkEnableOption;

  # Build configuration
  build = {
    # Debug settings
    debug = true;
    optimize = false;
    # Target platform
    target = "x86_64-linux";
  };

  # Service definitions with comments
  services = {
    # HTTP server configuration
    http = {
      enable = true;
      port = 8080;
    };
    # Database connection
    database = {
      enable = true;
      host = "localhost";
      port = 5432;
    };
  };
in
{
  # Main configuration
  config = {
    # Inherited packages
    inherit (pkgs) curl jq ripgrep htop;

    # Application settings
    app = {
      enable = true;
      name = name;
      version = version;
    };

    # Nested service configuration
    services = {
      nginx = {
        enable = true;
        # Virtual host setup
        virtualHosts."example.com" = {
          enableACME = true;
          forceSSL = true;
          # Root location
          locations."/" = {
            extraConfig = "try_files $uri $uri/ =404;";
            index = "index.html index.htm";
            root = "/var/www/example.com";
            proxyPass = "http://localhost:8080";
          };
        };
      };

      postgresql = {
        enable = true;
        # Database initialization
        initialScript = pkgs.writeText
          "init.sql"
          ''
            CREATE DATABASE mydb;
            CREATE USER myuser WITH PASSWORD 'password';
            GRANT ALL PRIVILEGES ON DATABASE mydb TO myuser;
          '';
        package = pkgs.postgresql_16;
      };
    };

    # Build steps
    systemd.services.build-app = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c 'echo Building...'";
      };
    };
  };
}
