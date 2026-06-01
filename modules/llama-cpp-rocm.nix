{ config, lib, pkgs, ... }:

let
  cfg = config.services.llama-cpp-rocm;
in
{
  options.services.llama-cpp-rocm = {
    enable = lib.mkEnableOption "llama-cpp-rocm service fixes for local model cache access";

    user = lib.mkOption {
      type = lib.types.str;
      default = "llama-cpp";
      description = "User to run the llama-cpp service as";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "llama-cpp";
      description = "Group to run the llama-cpp service as";
    };

    hfCacheDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/${cfg.user}/.cache/huggingface/hub";
      defaultText = "/home/\${user}/.cache/huggingface/hub";
      description = "HuggingFace cache directory for model files";
    };

    fixProcSubset = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Fix /proc access restriction warnings in journalctl";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.llama-cpp.serviceConfig = {
      DynamicUser  = lib.mkForce false;
      PrivateUsers = lib.mkForce false;
      ProtectHome  = lib.mkForce false;
      User  = lib.mkForce cfg.user;
      Group = lib.mkForce cfg.group;
      Environment = lib.mkForce [
        "LLAMA_CACHE=${cfg.hfCacheDir}"
      ];
    } // lib.optionalAttrs cfg.fixProcSubset {
      ProcSubset = lib.mkForce "all";
    };
  };
}
