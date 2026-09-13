# asusd-pd-profile — 按供电类型选择平台档位（区分 USB-C PD 与原生/桶形 AC）。
#
# 背景：asusd 的 asusd.ron 只有两个档位键
#   `platform_profile_on_ac` 与 `platform_profile_on_battery`，
# **没有 USB-C PD 分支**。故"PD 供电用 Balanced、桶形 AC 用 Performance"
# 这类策略无法用配置表达，需由本模块补足。
#
# ── 设计要点 ────────────────────────────────────────────────────────
#
# 1. **PD 与桶形 AC 在 ACPI 层是同一信号**（`AC0.online` 两者都为 1），
#    但内核另把 USB-C PD 暴露为独立供应器，可据此区分。本模块用两级判据：
#      a. Type-C 端口 `power_operation_mode` 为 `usb_power_delivery`
#      b. 任一 `POWER_SUPPLY_TYPE == "USB"` 的供应器 `online == 1`
#    二者互为冗余。选用**通用内核属性**而非写死设备名，
#    使规则不依赖具体机型的 UCSI 枚举顺序。
#
# 2. **通过 D-Bus 写入，不解析 asusctl 的文本输出。**
#    asusd 暴露 `xyz.ljones.Platform` 接口，其中 `PlatformProfileOnAc`
#    是 `u` 型可写属性（枚举）。相较 `asusctl profile set -a <名>`：
#      - 不依赖 CLI 的人类可读输出格式（措辞变更会静默失效）
#      - 不依赖 asusctl 二进制在 PATH 中
#    实测枚举映射（asusctl 6.4.0 / Strix Halo）：
#      0 = balanced    1 = performance    2 = quiet    3 = quiet(别名)
#
# 3. **绝不直接写 /sys/firmware/acpi/platform_profile。**
#    asusd 在每次 AC 事件时都会按自己的 AC 档位重设，会覆盖外部写入。
#    写 `PlatformProfileOnAc` 是修改 asusd **自己的**持久化设置，
#    二者意图一致，不再互相覆盖。
#
# 4. **电池态不介入** —— 那是 `platform_profile_on_battery` 的职责。
#    本模块检测到电池供电时立即退出，避免与 asusd 争抢。
{ config, lib, pkgs, ... }:

let
  cfg = config.nixkits.asusd-pd-profile;

  # asusd D-Bus 目标
  busName = "xyz.ljones.Asusd";
  objPath = "/xyz/ljones";
  iface = "xyz.ljones.Platform";

  # 档位名 → asusd 枚举值（实测）
  profileToEnum = {
    balanced = 0;
    performance = 1;
    quiet = 2;
  };

  pdEnum = toString profileToEnum.${cfg.pdProfile};
  acEnum = toString profileToEnum.${cfg.nativeAcProfile};

  # 事件处理器：判定供电形态，把 asusd 的持久化 AC 档位设为对应值。
  apply = pkgs.writeShellScript "asusd-pd-profile-apply" ''
    set -eu
    PATH=${lib.makeBinPath [ pkgs.systemd pkgs.coreutils pkgs.gnugrep pkgs.gawk ]}:$PATH

    # ── 电池供电：交给 asusd 的 platform_profile_on_battery，自身不介入 ──
    ac_online=0
    for f in /sys/class/power_supply/AC*/online; do
      [ -e "$f" ] || continue
      [ "$(cat "$f" 2>/dev/null || echo 0)" = "1" ] && { ac_online=1; break; }
    done
    if [ "$ac_online" != "1" ]; then
      echo "on battery — asusd handles it (platform_profile_on_battery), no action"
      exit 0
    fi

    # ── 判定是否 USB-C PD 供电（两级判据，互为冗余）──
    is_pd=0
    # 判据 a：Type-C 端口进入 PD 模式
    for f in /sys/class/typec/port*/power_operation_mode; do
      [ -e "$f" ] || continue
      if [ "$(cat "$f" 2>/dev/null || true)" = "usb_power_delivery" ]; then
        is_pd=1; break
      fi
    done
    # 判据 b：任一 USB 型供应器在线
    if [ "$is_pd" = "0" ]; then
      for d in /sys/class/power_supply/*/; do
        [ -e "$d/type" ] || continue
        [ "$(cat "$d/type" 2>/dev/null || true)" = "USB" ] || continue
        if [ "$(cat "$d/online" 2>/dev/null || echo 0)" = "1" ]; then
          is_pd=1; break
        fi
      done
    fi

    if [ "$is_pd" = "1" ]; then
      target=${pdEnum}; label=${cfg.pdProfile}
    else
      target=${acEnum}; label=${cfg.nativeAcProfile}
    fi

    # ── 幂等：已是目标值则跳过，避免多余的 D-Bus 往返 ──
    current=$(busctl get-property ${busName} ${objPath} ${iface} PlatformProfileOnAc 2>/dev/null \
              | awk '{print $2}' || echo "")
    if [ "$current" = "$target" ]; then
      echo "PlatformProfileOnAc already $target ($label), nothing to do"
      exit 0
    fi

    echo "power source=$([ "$is_pd" = 1 ] && echo 'USB-C PD' || echo 'native AC') -> setting PlatformProfileOnAc to $target ($label), was ''${current:-unknown}"
    busctl set-property ${busName} ${objPath} ${iface} PlatformProfileOnAc u "$target"
  '';

  # udev 规则：仅在供电形态可能变化时触发。
  # 使用通用属性（POWER_SUPPLY_TYPE）而非机型专属设备名。
  rules = pkgs.writeTextDir "lib/udev/rules.d/99-asusd-pd-profile.rules" ''
    # 电源适配器插拔（AC 供应器：AC / AC0 / ADP1 …）
    ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="Mains", TAG+="systemd", ENV{SYSTEMD_WANTS}+="asusd-pd-profile.service"
    # USB-C PD 协商完成（USB 型供应器）
    ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="USB", TAG+="systemd", ENV{SYSTEMD_WANTS}+="asusd-pd-profile.service"
    # Type-C 端口角色/模式切换
    ACTION=="add|change", SUBSYSTEM=="typec", KERNEL=="port[0-9]*", TAG+="systemd", ENV{SYSTEMD_WANTS}+="asusd-pd-profile.service"
  '';
in
{
  options.nixkits.asusd-pd-profile = {
    enable = lib.mkEnableOption ''
      per-power-source ASUS platform profile selection — distinguishes USB-C PD
      from native/barrel AC, which asusd's own two-state configuration cannot express
    '';

    pdProfile = lib.mkOption {
      type = lib.types.enum [ "quiet" "balanced" "performance" ];
      default = "balanced";
      description = ''
        Platform profile to select while powered by USB-C Power Delivery.
      '';
    };

    nativeAcProfile = lib.mkOption {
      type = lib.types.enum [ "quiet" "balanced" "performance" ];
      default = "performance";
      description = ''
        Platform profile to select while powered by native/barrel AC
        (i.e. AC online, but not via USB-C PD).
      '';
    };
  };

  config = lib.mkIf (cfg.enable && config.services.asusd.enable) {
    services.udev.packages = [ rules ];

    # oneshot：由 udev 拉起，跑完即退 —— 无常驻进程、无轮询。
    systemd.services.asusd-pd-profile = {
      description = "Select ASUS platform profile by power source (native AC vs USB-C PD)";
      # 需 asusd 的 D-Bus 就绪，否则 set-property 失败。
      after = [ "asusd.service" ];
      requires = [ "asusd.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = apply;
        # 访问系统总线上的 xyz.ljones.Asusd 需 root。
        User = "root";
      };
    };

    # 开机首次判定：asusd 就绪后立即按当前供电形态设置一次，
    # 否则会沿用 asusd.ron 里的静态 platform_profile_on_ac。
    systemd.services.asusd-pd-profile-boot = {
      description = "Initial ASUS platform profile selection by power source";
      wantedBy = [ "multi-user.target" ];
      after = [ "asusd.service" ];
      requires = [ "asusd.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = apply;
        User = "root";
      };
    };
  };
}
