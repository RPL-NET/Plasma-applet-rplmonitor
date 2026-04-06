# RPL Monitor

A btop-style system monitor widget for KDE Plasma 6.

## Features (v0.1)

- Real-time CPU usage percentage in panel
- Colored progress bar in popup (green/yellow/red based on load)
- Reads directly from `/proc/stat` - no external dependencies

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

## License

GPL-3.0
