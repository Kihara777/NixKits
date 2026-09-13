# asusd-pd-profile

[中文](../zh/asusd-pd-profile.md) | English | [日本語](../ja/asusd-pd-profile.md)  | [偽中国語](../pcn/asusd-pd-profile.md)

Selects the ASUS platform profile by power source — distinguishing **USB-C PD** from **native/barrel AC**, supplying the third state that `asusd`'s own configuration cannot express.

## Info

| Item | Value |
|------|-------|
| Upstream | [Asus-linux/asusctl](https://github.com/Asus-linux/asusctl) (the `asusd` daemon) |
| Module | `nixosModules.asusd-pd-profile` |
| Dependency | `services.asusd.enable = true` |
| Interface | asusd D-Bus `xyz.ljones.Platform` + udev |
| Note | No resident process, no polling; a udev-event-triggered oneshot service |

## The Problem It Solves

`asusd`'s `asusd.ron` has **only two profile keys**:

```ron
platform_profile_on_ac: Performance,
platform_profile_on_battery: Quiet,
```

**There is no USB-C PD branch.** So a policy such as "use Balanced on PD, Performance on barrel power" cannot be expressed in configuration.

The problem is that the ACPI layer **exposes only one AC supply** — PD and barrel charging are both `1` at `/sys/class/power_supply/AC0/online`, apparently indistinguishable.

**But the kernel additionally exposes USB-C PD as a separate supply**, and this module distinguishes on that basis:

| Signal | Path | When PD is online |
|------|------|----------|
| Type-C port mode | `/sys/class/typec/port*/power_operation_mode` | `usb_power_delivery` |
| USB-type supply | `/sys/class/power_supply/*/` (`type` is `USB`) | `online` is `1` |

The two criteria are mutually redundant, and both use **generic kernel attributes**, so neither depends on a specific machine's UCSI enumeration order.

## Usage

```nix
{
  imports = [ inputs.nixkits.nixosModules.asusd-pd-profile ];

  services.asusd.enable = true;

  nixkits.asusd-pd-profile = {
    enable = true;
    pdProfile = "balanced";        # USB-C PD power (default)
    nativeAcProfile = "performance"; # native/barrel AC power (default)
  };
}
```

Battery power is **not handled by this module** — that is `platform_profile_on_battery`'s job. On detecting battery power this module exits immediately, avoiding a contest with asusd.

### Options

| Option | Type | Default | Description |
|------|------|------|------|
| `enable` | bool | `false` | Enable this module |
| `pdProfile` | enum | `"balanced"` | Profile selected on USB-C PD power |
| `nativeAcProfile` | enum | `"performance"` | Profile selected on native/barrel AC power |

The profile may be `quiet` / `balanced` / `performance`.

## Key Implementation Points

### 1. Never write sysfs directly

**Do not** write `/sys/firmware/acpi/platform_profile` — asusd resets the profile on every AC event according to its own AC profile, immediately overwriting the external write (visible in the log as
`[DEBUG asusd::ctrl_platform] Setting Performance before EPP`).

This module instead writes asusd's **own** persistent setting (`PlatformProfileOnAc`),
so that the two intentions agree and no longer overwrite each other.

### 2. Via D-Bus rather than parsing CLI text

asusd exposes the `xyz.ljones.Platform` interface, in which `PlatformProfileOnAc` is a writable property:

```
.PlatformProfileOnAc  property  u  0  emits-change writable
```

Compared with `asusctl profile set -a <name>`, writing D-Bus directly:

- does not depend on the CLI's **human-readable output format** (upstream rewording silently breaks it)
- does not depend on the `asusctl` binary being in `PATH`

> ⚠️ **Profile enum values** (measured on asusctl 6.4.0):
>
> | Value | Profile |
> |----|------|
> | `0` | balanced |
> | `1` | performance |
> | `2` | quiet |
> | `3` | quiet (alias) |
>
> Note that `0` is **balanced**, not quiet — this **differs** from the order in the ACPI sysfs
> `platform_profile_choices` (`quiet balanced performance`), and the two must not be conflated.
> Do not infer them literally either: `PlatformProfileOnBattery = 2` was once a source of the
> misjudgement that "quiet is 2", whereas measurement shows `3` also maps to quiet.

### 3. udev matching on generic attributes

The rules do not hard-code machine-specific device names (such as `ucsi-source-psy-USBC000:001`,
whose index is decided by UCSI enumeration order and breaks on a different machine), but use generic attributes:

```
ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="Mains", ...
ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="USB", ...
ACTION=="add|change", SUBSYSTEM=="typec", KERNEL=="port[0-9]*", ...
```

## Verification

```bash
# Current profile (D-Bus)
busctl get-property xyz.ljones.Asusd /xyz/ljones xyz.ljones.Platform \
  PlatformProfileOnAc

# Event handling log
journalctl -u asusd-pd-profile --since '5 min ago'
```

Normal output looks like:

```
power source=USB-C PD -> setting PlatformProfileOnAc to 0 (balanced), was 1
PlatformProfileOnAc already 0 (balanced), nothing to do
on battery — asusd handles it (platform_profile_on_battery), no action
```

> ⚠️ **Window-period pitfall**: `power_operation_mode` and the USB supply's `online`
> change **only at the instant of plugging or unplugging**. If read while PD is not connected, `power_operation_mode`
> is always `default` — and that leads to the misjudgement that "the kernel cannot distinguish PD from barrel".
> Before judging, first confirm that PD power is actually connected at the time.

## Measured Power Profile Results

Same prompt, same session, 400-token generation (Strix Halo / Radeon 8060S):

| Profile | Power | sclk | Temperature | Generation speed |
|------|------|------|------|---------|
| quiet | **38.6–43.9 W** | 2228–2464 MHz | **59–78 °C** | 12.12–12.35 t/s |
| balanced | 55.1 W | 2586–2731 MHz | 87–93 °C | 12.84 t/s |
| performance | 76.7 W | 2753–2859 MHz | 90–95 °C | 13.07 t/s |

**quiet versus performance: −49% power, −17~36 °C, only −5~7% speed.**
On a unified-memory device the generation bottleneck is **dependency latency** rather than clock, so dropping the profile costs almost no throughput.
