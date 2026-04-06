#!/bin/bash
# sensors-helper.sh — Helper script for RPL Monitor
# Provides data that can't be easily read from /proc via XHR:
# - Top 5 processes by CPU usage
# - GPU temperature (if nvidia-smi or sensors available)
#
# Output format: JSON for easy parsing in QML
# Usage: Called periodically by the plasmoid via PlasmaCore.DataSource

set -euo pipefail

# --- Top 5 processes by CPU ---
get_top_processes() {
    ps aux --sort=-%cpu | head -6 | tail -5 | awk '{
        # Remove path from command name
        split($11, cmd, "/")
        name = cmd[length(cmd)]
        printf "{\"name\":\"%s\",\"cpu\":%s,\"mem\":%s}\n", name, $3, $4
    }' | paste -sd',' | sed 's/^/[/;s/$/]/'
}

# --- GPU temperature ---
get_gpu_temp() {
    # Try nvidia-smi first
    if command -v nvidia-smi &>/dev/null; then
        temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -1)
        if [ -n "$temp" ]; then
            echo "{\"name\":\"GPU\",\"temp\":$temp}"
            return
        fi
    fi

    # Try AMD via hwmon
    for hwmon in /sys/class/hwmon/hwmon*/; do
        if [ -f "${hwmon}name" ]; then
            name=$(cat "${hwmon}name")
            if [ "$name" = "amdgpu" ]; then
                if [ -f "${hwmon}temp1_input" ]; then
                    temp=$(($(cat "${hwmon}temp1_input") / 1000))
                    echo "{\"name\":\"GPU\",\"temp\":$temp}"
                    return
                fi
            fi
        fi
    done

    echo "null"
}

# --- Main output ---
echo "{"
echo "  \"processes\": $(get_top_processes),"
echo "  \"gpu_temp\": $(get_gpu_temp)"
echo "}"
