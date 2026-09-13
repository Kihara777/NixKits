# asusd-thermal-guard — 温度看门狗：检测到过热趋势时自动降级平台档位。
#
# ── 为何需要（实机教训）──────────────────────────────────────────────
# 在 ROG Flow Z13 (Strix Halo) 上，AC + Performance 档跑本地 LLM 推理
# **连续三次过热关机**。排查过程与结论：
#
#   ① 先怀疑风扇曲线：原曲线在 80 °C 封顶（145/255 = 56%），而芯片
#      实测跑 90–95 °C —— 最后 44% 散热能力从未启用。修好后温度确实回落。
#   ② 但随后再次关机。实测数据显示：**风扇已满转 8800 RPM、温度平稳
#      85.4 °C 持续 28 分钟**（90 个采样，delta −0.3 °C）后仍被切断。
#   ③ 对照实验（决定性）：把曲线改成 65 °C 即满转的激进版，
#      同负载下 85.6 °C / 55 W —— **与温和曲线毫无差别**。
#
# 结论：**风扇曲线在饱和后就不是有效杠杆了**。8800 RPM / 85.5 °C / ~55 W
# 就是该机箱的物理散热极限。要防关机，只能**降低功耗**。
#
# 又因为「何时算危险」随机型/环境而异，比写死一个更低的 PPT 更稳妥的做法是：
# **动态监测 + 超标自动降档**，即在温度无法压制时把平台档位往下调一档。
#
# ── 设计要点 ────────────────────────────────────────────────────────
# 1. **按 name 解析 hwmon，不写死 hwmonN**。
#    实测同一机器重启后编号会变（k10temp 1→3、asus 9→8），写死必然失效。
# 2. **用 asusctl 改档位，不直接写 sysfs**。
#    asusd 会在 AC 事件时按自己的持久化档位覆盖 /sys/firmware/acpi/platform_profile
#    （日志 `Setting Performance before EPP` 可证）。
# 3. **滞回 + 冷却期**：降档后要等温度真正回落才允许恢复，
#    否则会在阈值附近反复横跳。恢复用「低于 resume 阈值且持续 N 次采样」。
# 4. **只降不升到超过上限**：即恢复时最高恢复到配置的 ceiling，
#    不会自作主张升到 Performance。
{ config, lib, pkgs, ... }:

let
  cfg = config.nixkits.asusd-thermal-guard;

  # 档位顺序（由低到高）。降级即向下取一档。
  ladder = [ "quiet" "balanced" "performance" ];

  # 目标档位在阶梯中的下标；未知值按最低处理。
  ceilingIdx = lib.lists.findFirstIndex (x: x == cfg.profileCeiling) 0 ladder;

  # 可用的降级目标（含 ceiling 自身）。
  usable = lib.sublist 0 (ceilingIdx + 1) ladder;

  # ceiling 之下的一档即为过热时降级的目标。
  fallback =
    if ceilingIdx >= 1
    then lib.elemAt ladder (ceilingIdx - 1)
    else lib.elemAt ladder 0;

  guard = pkgs.writeShellScript "asusd-thermal-guard" ''
    set -eu
    PATH=${lib.makeBinPath [ pkgs.asusctl pkgs.coreutils pkgs.gnugrep pkgs.gawk ]}:$PATH

    # ── 按 name 解析 hwmon（编号在重启后会变，不可写死）──
    hwmon_by_name() {
      for d in /sys/class/hwmon/hwmon*/; do
        [ -r "$d/name" ] || continue
        [ "$(cat "$d/name" 2>/dev/null || true)" = "$1" ] && { echo "$d"; return 0; }
      done
      return 1
    }

    K10=$(hwmon_by_name k10temp || true)
    GPU=$(hwmon_by_name amdgpu || true)

    read_temp() {  # $1 = hwmon dir, 取 temp1_input（毫摄氏度）
      [ -n "$1" ] && [ -r "$1/temp1_input" ] || { echo ""; return; }
      awk "BEGIN{printf \"%.1f\", $(cat "$1/temp1_input" 2>/dev/null)/1000}"
    }

    cpu_t=$(read_temp "$K10")
    gpu_t=$(read_temp "$GPU")

    # 取两者较大者作为判据（任一过热都应触发）
    max_t=$(awk "BEGIN{ a=''${cpu_t:-0}; b=''${gpu_t:-0}; printf \"%.1f\", (a>b?a:b) }")

    printf 'cpu=%s gpu=%s max=%s ' "''${cpu_t:-?}" "''${gpu_t:-?}" "$max_t"

    # ── 读当前档位（asusctl get 输出: "Active profile: X"）──
    cur=$(asusctl profile get 2>/dev/null \
          | sed -n 's/^Active profile: *//p' | head -1 \
          | tr '[:upper:]' '[:lower:]' || true)

    echo "current=''${cur:-unknown}"

    # 未取得有效温度时不动手（宁可不干预，也不误降）
    [ -n "$max_t" ] || { echo "no temperature reading — skip"; exit 0; }

    # 比较前先取整（awk 已保证是数字）
    max_i=$(printf '%.0f' "$max_t")
    if [ "$max_i" -lt ${toString cfg.triggerTemp} ]; then
      echo "below trigger (${toString cfg.triggerTemp}C)"
      exit 0
    fi

    # 已在最低档则无可再降
    if [ "$cur" = "${lib.head usable}" ]; then
      echo "already at lowest profile ''${cur} — cannot downgrade further"
      exit 0
    fi

    # 降级目标：从 usable 里找当前位置的下一档
    target="${fallback}"
    case "$cur" in
      performance) target="${fallback}" ;;
      balanced)    target="quiet" ;;
      *)           target="${lib.head usable}" ;;
    esac

    # 目标必须在允许范围内
    ok=0
    for p in ${lib.concatStringsSep " " usable}; do [ "$p" = "$target" ] && ok=1; done
    [ "$ok" = 1 ] || { echo "target $target outside allowed set — skip"; exit 0; }

    echo "OVERHEAT ($max_t C >= ${toString cfg.triggerTemp} C) — $cur -> $target"
    asusctl profile set "$target" || exit 1
  '';

  # 恢复：仅在温度回落到 resumeTemp 以下、且连续若干次确认后才回升一档。
  resume = pkgs.writeShellScript "asusd-thermal-guard-resume" ''
    set -eu
    PATH=${lib.makeBinPath [ pkgs.asusctl pkgs.coreutils pkgs.gnugrep pkgs.gawk ]}:$PATH

    hwmon_by_name() {
      for d in /sys/class/hwmon/hwmon*/; do
        [ -r "$d/name" ] || continue
        [ "$(cat "$d/name" 2>/dev/null || true)" = "$1" ] && { echo "$d"; return 0; }
      done
      return 1
    }
    K10=$(hwmon_by_name k10temp || true)
    GPU=$(hwmon_by_name amdgpu || true)

    read_temp() {
      [ -n "$1" ] && [ -r "$1/temp1_input" ] || { echo 0; return; }
      awk "BEGIN{printf \"%.0f\", $(cat "$1/temp1_input" 2>/dev/null)/1000}"
    }

    c=$(read_temp "$K10"); g=$(read_temp "$GPU")
    max_t=$(awk "BEGIN{printf \"%.0f\", (($c)>($g)?($c):($g))}")

    cur=$(asusctl profile get 2>/dev/null | sed -n 's/^Active profile: *//p' | head -1 | tr '[:upper:]' '[:lower:]' || true)

    # 状态目录：systemd 会经 RuntimeDirectory 建好；手动运行时兜底自建，
    # 使脚本可脱离 systemd 单独测试。
    S="''${RUNTIME_DIRECTORY:-/run/asusd-thermal-guard}"
    mkdir -p "$S" 2>/dev/null || true

    if [ "$max_t" -ge ${toString cfg.resumeTemp} ]; then
      echo "still warm ($max_t C >= ${toString cfg.resumeTemp} C) — stay at $cur"
      rm -f "$S/cool-streak" 2>/dev/null || true
      exit 0
    fi

    # 冷却计数：连续 N 次达标才恢复，避免阈值抖动
    F="$S/cool-streak"
    n=$(cat "$F" 2>/dev/null || echo 0)
    n=$((n + 1))
    echo "$n" > "$F"

    if [ "$n" -lt ${toString cfg.resumeSamples} ]; then
      echo "cool ($max_t C) streak $n/${toString cfg.resumeSamples} — waiting"
      exit 0
    fi

    echo "0" > "$F"

    # 恢复一档，但绝不超过 ceiling。
    # ceilingIdx: quiet=0 balanced=1 performance=2
    case "$cur" in
      quiet)
        if [ "${toString ceilingIdx}" -ge 1 ]; then
          echo "cooled — quiet -> ${lib.elemAt ladder 1}"
          asusctl profile set "${lib.elemAt ladder 1}" || exit 1
        else
          echo "quiet is the ceiling — stay"
        fi
        ;;
      balanced)
        if [ "${toString ceilingIdx}" -ge 2 ]; then
          echo "cooled — balanced -> performance"
          asusctl profile set performance || exit 1
        else
          echo "balanced is the ceiling — stay"
        fi
        ;;
      performance) echo "already at ceiling" ;;
      *)           echo "unknown profile '$cur' — skip" ;;
    esac
  '';

in
{
  options.nixkits.asusd-thermal-guard = {
    enable = lib.mkEnableOption ''
      ASUS thermal guard — automatically step the platform profile down when
      temperature cannot be held, and restore it once the system has cooled.
      Needed because the fan curve is ineffective once fans saturate: on a
      Flow Z13 the chassis plateaus at ~85.5 C / 55 W with fans at 8800 RPM,
      and only reducing power prevents the EC from cutting power.
    '';

    profileCeiling = lib.mkOption {
      type = lib.types.enum [ "quiet" "balanced" "performance" ];
      default = "performance";
      description = ''
        Highest profile the guard will ever select. The guard only steps
        *down* from here, never above it.
      '';
    };

    triggerTemp = lib.mkOption {
      type = lib.types.int;
      default = 90;
      description = ''
        Temperature (°C, the higher of CPU Tctl and GPU edge) at or above
        which the guard steps the platform profile down one level.
        Must be above `resumeTemp`.
      '';
    };

    resumeTemp = lib.mkOption {
      type = lib.types.int;
      default = 78;
      description = ''
        Temperature (°C) below which the guard may step the profile back up.
        Keep a healthy gap from `triggerTemp` to avoid oscillation.
      '';
    };

    resumeSamples = lib.mkOption {
      type = lib.types.int;
      default = 6;
      description = ''
        Consecutive below-`resumeTemp` samples required before restoring a
        level, preventing thrash near the threshold.
      '';
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "10s";
      description = "How often the guard samples temperature.";
    };
  };

  config = lib.mkIf (cfg.enable && config.services.asusd.enable) {
    assertions = [
      {
        assertion = cfg.triggerTemp > cfg.resumeTemp;
        message = "nixkits.asusd-thermal-guard: triggerTemp must exceed resumeTemp (otherwise the guard oscillates).";
      }
    ];

    # oneshot 触发的常驻守护：用 timer 而不是 loop+sleep，
    # 这样 systemd 能看到每次采样，日志也更清晰。
    systemd.services.asusd-thermal-guard = {
      description = "ASUS thermal guard — step platform profile down when overheating";
      after = [ "asusd.service" ];
      requires = [ "asusd.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = guard;
        # asusctl 需 root 才能访问 xyz.ljones.Asusd 的写方法。
        User = "root";
        # 冷却计数放 /run，重启即清零（保守：重启后重新累积）
        RuntimeDirectory = "asusd-thermal-guard";
      };
    };

    systemd.services.asusd-thermal-guard-resume = {
      description = "ASUS thermal guard — restore platform profile after cooling";
      after = [ "asusd.service" ];
      requires = [ "asusd.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = resume;
        User = "root";
        RuntimeDirectory = "asusd-thermal-guard";
        RuntimeDirectoryPreserve = "yes";
      };
    };

    systemd.timers.asusd-thermal-guard = {
      description = "Sample temperature for the ASUS thermal guard";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "2min";
        OnUnitActiveSec = cfg.interval;
        Unit = "asusd-thermal-guard.service";
      };
    };

    systemd.timers.asusd-thermal-guard-resume = {
      description = "Sample temperature for the ASUS thermal guard (restore)";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "2min";
        OnUnitActiveSec = cfg.interval;
        Unit = "asusd-thermal-guard-resume.service";
      };
    };
  };
}
