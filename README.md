# RPL Monitor

A btop-style system monitor widget for KDE Plasma 6. Real-time CPU, RAM, network, disk, and temperature monitoring with a terminal-inspired aesthetic.

## Features

- **CPU** — Total usage %, history graph (50 ticks), per-core bars (btop style)
- **RAM/Swap** — Usage bars with GB values
- **Network** — Download/upload speed graph with auto-detected interface
- **Disk I/O** — Read/write throughput graph
- **Temperatures** — CPU zones from `/sys/class/thermal`, GPU via hwmon
- **Processes** — Top 5 by CPU usage
- **Themes** — btop (Dracula), minimal (monochrome), terminal (green CRT)
- **Configurable** — Update interval, toggle sections on/off via KDE config panel
- **Tooltip** — Detailed hover info (CPU, RAM, Swap, network speeds)

## Install

```bash
kpackagetool6 -t Plasma/Applet -i .
```

## Test

```bash
plasmoidviewer -a org.rpl.rplmonitor
```

## Update

```bash
kpackagetool6 -t Plasma/Applet -u .
```

## Uninstall

```bash
kpackagetool6 -t Plasma/Applet -r org.rpl.rplmonitor
```

## Data Sources

All data is read from the Linux pseudo-filesystems — no root required:

| Data | Source |
|------|--------|
| CPU | `/proc/stat` |
| RAM/Swap | `/proc/meminfo` |
| Network | `/proc/net/dev` |
| Disk I/O | `/proc/diskstats` |
| Temperatures | `/sys/class/thermal/thermal_zone*/temp` |
| GPU temp | `/sys/class/hwmon/hwmon*/temp1_input` |
| Processes | `ps aux` via Plasma DataSource |

## Configuration

Right-click the widget > Configure > Appearance:

- **Update interval** — 250ms to 10s (default 1s)
- **Theme** — btop, minimal, or terminal
- **Section toggles** — Show/hide CPU graph, per-core bars, RAM, network, disk, temps, processes

## Requirements

- KDE Plasma 6
- Qt 6 / QML

## License

GPL-3.0
