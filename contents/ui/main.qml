// main.qml — Entry point for RPL Monitor plasmoid
// Switches between compact (panel) and full (popup) representations

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root

    // Compact view shown in the panel
    compactRepresentation: CompactRepresentation {}

    // Full view shown in the popup
    fullRepresentation: FullRepresentation {}

    preferredRepresentation: compactRepresentation

    toolTipMainText: "RPL Monitor"
    toolTipSubText: cpuReader.cpuPercent + "% CPU"

    // --- CPU data reader ---
    // Reads /proc/stat every updateInterval ms and computes total CPU usage
    QtObject {
        id: cpuReader

        property int cpuPercent: 0
        property int updateInterval: 1000

        // Previous tick values for delta calculation
        property var prevIdle: 0
        property var prevTotal: 0

        function readCpuUsage() {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "/proc/stat");
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    parseCpuLine(xhr.responseText);
                }
            };
            xhr.send();
        }

        function parseCpuLine(text) {
            // First line of /proc/stat: cpu  user nice system idle iowait irq softirq steal
            var lines = text.split("\n");
            if (lines.length === 0) return;

            var parts = lines[0].split(/\s+/);
            if (parts[0] !== "cpu") return;

            var user    = parseInt(parts[1]) || 0;
            var nice    = parseInt(parts[2]) || 0;
            var system  = parseInt(parts[3]) || 0;
            var idle    = parseInt(parts[4]) || 0;
            var iowait  = parseInt(parts[5]) || 0;
            var irq     = parseInt(parts[6]) || 0;
            var softirq = parseInt(parts[7]) || 0;
            var steal   = parseInt(parts[8]) || 0;

            var totalIdle = idle + iowait;
            var total = user + nice + system + idle + iowait + irq + softirq + steal;

            var diffIdle  = totalIdle - prevIdle;
            var diffTotal = total - prevTotal;

            if (diffTotal > 0) {
                cpuPercent = Math.round((1.0 - diffIdle / diffTotal) * 100);
            }

            prevIdle  = totalIdle;
            prevTotal = total;
        }

        property Timer timer: Timer {
            interval: cpuReader.updateInterval
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: cpuReader.readCpuUsage()
        }
    }
}
