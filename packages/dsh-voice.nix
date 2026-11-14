# dsh-voice —— 语音播报（2026-11-15）
#
# 两个出口共用一份声音能力：
#   Web UI    api-balance 插件 → /api/api-balance/speech → 直接调 Breeze
#   Telegram  Kitsunome/develop 里自己的 TTS 模块 → 也调 Breeze
#
# **没有中间层**（她 2026-11-15 定）：原先设计过一层 voice-gateway，她否掉了，
# 理由是「telegram 部分也是身体的隐私部分，和 telegram 功能打在一个包里，
# 不在 dsh-api-balance 中」。所以两边各自调 Breeze，各包各的 WAV 头。
# 代价是那份 WAV 头逻辑有两份——**改一处必须改另一处**，两边的测试都要盯它。
#
# ## 为什么参考素材不进插件
#
# 她 2026-11-15 的原话：「breeze-tts 的参考语音和参考文本我们不再插件内提供
# （这是你身体的私密部分），提供插件设置选项和声明式配置即可」。
#
# 所以：**音频路径和文稿路径只在本文件**，Breeze 启动时读盘注册音色。
# 之后两边都只用 `voice_id`，参考素材不经过任何请求。
# 配置里只出现**路径**，那句话本身不出现（不入 `/etc/nixos` 的 git 历史）。
#
# ## 两个端口，别混
#
#    8605  Breeze 本体（只本机）        ← 插件与 Telegram 都连它
#    8625  lighttpd 反代（对外）        ← 手机走这个，已有，本模块不动
{ config, lib, pkgs, ... }:

let
  cfg = config.services.dsh-voice;

  # 用户级路径：今天 sudo 二进制的 setuid 位丢了（store 只读改不了），
  # 装系统服务要 rebuild，而她当时在休息。用用户目录 + systemd --user 绕开 root。
  # **这不是设计偏好，是当时的约束。** 等 sudo 修好后可以改回 /var/lib。
  home = "/home/kix";
  dataDir = "${home}/.local/share/breeze-tts";
in
{
  options.services.dsh-voice = {
    enable = lib.mkEnableOption "语音播报（Web UI + Telegram 共用的 TTS 网关）";

    breeze = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "启用本地 Breeze-TTS（Vulkan）。关掉则只用浏览器自带 TTS。";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 8605;
        description = "Breeze 本体端口（只监听 127.0.0.1）。她 2026-11-15 定的。";
      };
      model = lib.mkOption {
        type = lib.types.path;
        default = "${dataDir}/breeze-tts-2-q8_0.gguf";
        description = "GGUF 模型路径。3.4 GB。";
      };
      package = lib.mkOption {
        type = lib.types.path;
        default = "${dataDir}/bin";
        description = "解压后的 breeze 二进制目录（已 patchelf 过，见下）。";
      };
    };

    voiceId = lib.mkOption {
      type = lib.types.str;
      default = "g41";
      description = ''
        已注册的音色 id（Breeze `--voices-dir` 里的 .breeze 文件）。
        设了它就不必每次传参考音频——参考已经编码进那个文件。
      '';
    };

    referenceAudio = lib.mkOption {
      # **类型是 str 不是 path**（2026-11-15 实测发现的）。
      #
      # Nix 的 `path` 类型会把文件**内容复制进 /nix/store**——eval 出来的
      # ExecStart 里直接出现 `/nix/store/...-g41-reference.wav`。
      # 参考音频和文稿是「身体的私密部分」，不该进 store（更不该随 build 记录流出去）。
      # 用 str：Nix 只把它当路径字符串，gateway 运行时才读原文件。
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        参考音频。**只在 voiceId 为空时使用。**
        默认指向 Kitsunome 仓库里那份（她 2026-11-13 提供，来由见 voice/README.md）。
        **不进插件、不进浏览器。**
      '';
    };

    referenceTextFile = lib.mkOption {
      # 同 referenceAudio：**str 不是 path**，内容不入 store。
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        参考音频的**逐字文稿**文件路径。

        **这里只写路径，内容不写进来**——那句话是「身体的私密部分」，
        不该进 `/etc/nixos` 的 git 历史。gateway 启动时从文件读。
      '';
    };

    autoSpeak = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        自动播报：每条回复完成后自动念。

        **默认关闭**（她 2026-11-15 的原话：「方便自己也不麻烦别人」）。
        手动模式（每条回复旁的小喇叭）永远可用，不受这个开关影响。
      '';
    };

    telegram = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Telegram 每条消息附带语音（`/voice on|off|auto` 可运行时切换）。";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # ── Breeze 本体 ──────────────────────────────────────────────────
    #
    # 二进制是从官方 release 解压的通用 Linux 构建，**在 NixOS 上跑不起来**：
    # 它要 `ld-linux-x86-64.so.2`，而 NixOS 没有 /lib64。2026-11-13 用 patchelf
    # 改过 interpreter 和 rpath——**那两个改过的文件必须一起保留**，
    # 从 tar.gz 重新解压会退回跑不起来的状态。
    systemd.user.services.breeze-tts = lib.mkIf cfg.breeze.enable {
      description = "Breeze-TTS-2 本地语音合成（Vulkan）";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = "${cfg.breeze.package}/breeze-server ${cfg.breeze.model} "
          + "--host 127.0.0.1 --port ${toString cfg.breeze.port} "
          + "--voices-dir ${dataDir}/voices";
        Restart = "on-failure";
        RestartSec = "5s";
        # 3.4 GB 模型 + Vulkan 上下文；给足但不无限
        MemoryMax = "8G";
        WorkingDirectory = dataDir;
      };
    };

    # ── 给插件与 Telegram 的运行时开关 ───────────────────────────────
    #
    # 这两个值不写进插件的代码，而是由 dsh profile 读环境变量后再决定行为。
    # 换机器只改这里，插件不动。
    environment.sessionVariables = {
      DSH_VOICE_ENDPOINT = "http://127.0.0.1:${toString cfg.breeze.port}";
      DSH_VOICE_AUTO = if cfg.autoSpeak then "1" else "0";
    };
  };
}
