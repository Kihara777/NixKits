{ config, lib, pkgs, ... }:

let
  cfg = config.nixkits.llama-cpp-rocm;
  modelsPresetIni =
    if cfg.modelsPreset != null then
      pkgs.writeText "llama-models.ini" (lib.generators.toINI { } cfg.modelsPreset)
    else
      null;
in
{
  options.nixkits.llama-cpp-rocm = {
    enable = lib.mkEnableOption "llama-cpp-rocm service fixes and model preset convenience";

    user = lib.mkOption {
      type = lib.types.str;
      default = "llama-cpp";
      description = "User to run the llama-cpp service as.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "llama-cpp";
      description = "Group to run the llama-cpp service as.";
    };

    hfCacheDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.users.users.${cfg.user}.home}/.cache/huggingface/hub";
      defaultText = "\${config.users.users.\${user}.home}/.cache/huggingface/hub";
      description = "HuggingFace cache directory for model files.";
    };

    fixProcSubset = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Fix /proc access restriction warnings in journalctl.";
    };

    modelsPreset = lib.mkOption {
      type = lib.types.nullOr (lib.types.attrsOf (lib.types.attrsOf lib.types.str));
      default = null;
      description = ''
        Models preset configuration as a Nix attribute set.
        An INI file is generated and passed to llama-server via `--models-preset`.

        This restores the convenience removed from nixpkgs'
        `services.llama-cpp.modelsPreset`.

        Each top-level key is a model name. Values are INI-style key-value
        pairs for that model (e.g., `hf-repo`, `hf-file`, `alias`, `temp`, `top-p`).
      '';
      example = lib.literalExpression ''
        {
          "Qwen3-Coder-Next" = {
            hf-repo = "unsloth/Qwen3-Coder-Next-GGUF";
            hf-file = "Qwen3-Coder-Next-UD-Q4_K_XL.gguf";
            alias   = "unsloth/Qwen3-Coder-Next";
            temp    = "1.0";
            top-p   = "0.95";
            min-p   = "0.01";
            top-k   = "40";
            jinja   = "on";
          };
        }
      '';
    };

    sleepIdleSeconds = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = ''
        Number of seconds of idleness after which llama-server will
        sleep and unload the model from memory.

        Passed as `--sleep-idle-seconds` to llama-server.
        Set to `null` (default) to leave the server default (-1, disabled).
        A typical value is `600` (10 minutes).
      '';
      example = 600;
    };
  };

  config = lib.mkIf cfg.enable {
    # ── modelsPreset + sleep-idle-seconds → settings ────────────────────
    # Works with nixpkgs post-refactor where services.llama-cpp.settings
    # is a freeform attrset passed to llama-server as CLI arguments.
    # nixpkgs removed services.llama-cpp.extraFlags; pass via freeform settings.
    services.llama-cpp.settings = lib.mkMerge [
      (lib.mkIf (modelsPresetIni != null) {
        models-preset = toString modelsPresetIni;
      })
      (lib.mkIf (cfg.sleepIdleSeconds != null) {
        "sleep-idle-seconds" = toString cfg.sleepIdleSeconds;
      })
    ];

    # ── systemd hardening overrides ──────────────────────────────────────
    systemd.services.llama-cpp.serviceConfig = {
      DynamicUser  = lib.mkForce false;
      PrivateUsers = lib.mkForce false;
      ProtectHome  = lib.mkForce false;
      User         = lib.mkForce cfg.user;
      Group        = lib.mkForce cfg.group;
      Environment  = lib.mkForce [
        "LLAMA_CACHE=${cfg.hfCacheDir}"
      ];
    } // lib.optionalAttrs cfg.fixProcSubset {
      ProcSubset = lib.mkForce "all";
    };
  };
}
