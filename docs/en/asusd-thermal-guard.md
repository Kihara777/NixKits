# asusd-thermal-guard

[中文](../zh/asusd-thermal-guard.md) | English | [日本語](../ja/asusd-thermal-guard.md)  | [偽中国語](../pcn/asusd-thermal-guard.md)

A temperature watchdog — when the temperature cannot be held down it **automatically steps the platform profile down**, and restores it once the system has cooled.

## Info

| Item | Value |
|------|-------|
| Upstream | [OpenGamingCollective/asusctl](https://github.com/OpenGamingCollective/asusctl) (the `asusd` daemon) |
| Module | `nixosModules.asusd-thermal-guard` |
| Dependency | `services.asusd.enable = true` |
| Implementation | systemd timer + oneshot (no resident process) |
| Note | Only steps down; never steps up above `profileCeiling` |

## Why It Is Needed: The Fan Curve Saturates

Running local LLM inference on a ROG Flow Z13 (Strix Halo) caused **three consecutive thermal shutdowns**.
The investigation itself is the reason this module exists:

| Step | Observation | Conclusion |
|------|------|------|
| ① Check the fan curve | The curve caps at 80 °C (145/255 = 56%), while the chip runs at 90–95 °C | Fix the endpoint value, and the temperature does fall back |
| ② Another shutdown | Fans **already at full speed 8800 RPM**, temperature steady at **85.4 °C for 28 minutes** (90 samples, Δ = −0.3 °C) | Not runaway heating — an ambient equilibrium point |
| ③ Control experiment | Change the curve to the aggressive version that goes full speed at 65 °C | **85.6 °C / 55 W — no difference whatsoever from the gentle curve** |

**Conclusion: once the fans saturate, the shape of the curve no longer matters.**

```
gentle curve (80°C→255):   85.4 °C @ 52 W,  8700–8800 RPM
aggressive curve (65°C→255): 85.6 °C @ 55 W,  8700–8800 RPM
```

Both have their fans already at the hardware limit of 8800 RPM, and the temperatures are identical —
under full speed this chassis can dissipate only about 55 W, **and that is the physical limit**.

So the only effective lever is **reducing power draw**. But "how low is safe" varies with model, ambient temperature,
and how much dust has accumulated; hard-coding a lower PPT is both conservative and rigid —
**dynamic monitoring + stepping down when over the threshold** is more robust.

## Usage

```nix
{
  imports = [ inputs.nixkits.nixosModules.asusd-thermal-guard ];

  services.asusd.enable = true;

  nixkits.asusd-thermal-guard = {
    enable = true;
    profileCeiling = "performance"; # highest profile allowed
    triggerTemp = 88;               # at or above this temperature, step down one level
    resumeTemp = 80;                # restore only at or below this temperature, sustained
    resumeSamples = 6;              # consecutive samples (anti-thrash)
    interval = "10s";               # sampling period
  };
}
```

### Options

| Option | Type | Default | Description |
|------|------|------|------|
| `enable` | bool | `false` | Enable the watchdog |
| `profileCeiling` | enum | `"performance"` | Highest profile allowed; the watchdog **only steps down, never above this value** |
| `triggerTemp` | int | `90` | Temperature that triggers a step-down (°C) |
| `resumeTemp` | int | `78` | Temperature threshold that permits restoration (°C) |
| `resumeSamples` | int | `6` | How many consecutive samples below `resumeTemp` are required before restoring |
| `interval` | str | `"10s"` | Sampling period |

Profile ladder (low to high): `quiet` → `balanced` → `performance`.
Stepping down means taking one level lower; at the lowest level it takes no action.

> ⚠️ `triggerTemp` must be greater than `resumeTemp` (asserted inside the module),
> otherwise it will oscillate around the threshold.

## Key Implementation Points

### 1. Resolve hwmon by `name`, never hard-code `hwmonN`

**Measured on the same machine, the numbering changes after a reboot** (`k10temp` 1→3, `asus` 9→8).
A script with hard-coded numbers inevitably reads the wrong sensor after a reboot:

```bash
for d in /sys/class/hwmon/hwmon*/; do
  [ "$(cat "$d/name" 2>/dev/null)" = k10temp ] && echo "$d"
done
```

### 2. Use the **larger** of CPU and GPU as the criterion

Either one overheating should trigger:

```
max(cpu_tctl, gpu_edge) >= triggerTemp
```

### 3. Change the profile with `asusctl`, not by writing sysfs directly

**Do not** write `/sys/firmware/acpi/platform_profile` —
`asusd` overwrites it on every AC event according to its own persistent profile
(visible in the log as `Setting Performance before EPP`).
`asusctl profile set <profile>` changes asusd's **own** profile, so the two intentions agree.

### 4. Hysteresis + cool-down counting

Allowing restoration immediately after a step-down would flip back and forth around the threshold. Restoration therefore
requires **N consecutive** samples below `resumeTemp`, and any single over-threshold sample resets the count to zero.

## Verification

```bash
# Watchdog log (one sample every 10 seconds)
journalctl -u asusd-thermal-guard --since '5 min ago'
journalctl -u asusd-thermal-guard-resume --since '5 min ago'

# Currently active profile
asusctl profile get

# Run it once by hand (needs root: state lives in /run, and asusctl needs privileges)
sudo "$(systemctl show asusd-thermal-guard -p ExecStart --value | cut -d';' -f1 | awk '{print $1}')"
```

Normal output looks like:

```
cpu=85.1 gpu=86.0 max=86.0 current=performance
below trigger (88C)
```

When it triggers:

```
cpu=90.2 gpu=88.0 max=90.2 current=performance
OVERHEAT (90.2 C >= 88 C) — performance -> balanced
```

## Relationship to `asusd-pd-profile`

The two are complementary and can be enabled at the same time:

| Module | Responsibility |
|------|------|
| `asusd-pd-profile` | Selects the profile by **power source** (PD / native AC / battery) |
| `asusd-thermal-guard` | Steps the profile down by **temperature** (when overheating) |

The watchdog is only responsible for adjusting **downward** when overheating, and does not change the rules for
selecting the profile by power source; after cooling it restores up to what `profileCeiling` allows, and will not
presume to raise it to a higher profile on its own.
