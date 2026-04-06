// FullRepresentation.qml — Full popup view with all system monitors
// Displays CPU graph, per-core bars, RAM, network, disk, temps, and processes
// Respects Plasmoid.configuration for section visibility and theme

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import "components" as Components

Item {
    id: fullRoot

    Layout.minimumWidth: Kirigami.Units.gridUnit * 18
    Layout.minimumHeight: Kirigami.Units.gridUnit * 20
    Layout.preferredWidth: Kirigami.Units.gridUnit * 22
    Layout.preferredHeight: Kirigami.Units.gridUnit * 30

    // --- Active theme colors ---
    readonly property var theme: {
        var name = Plasmoid.configuration.theme || "btop";
        if (name === "minimal") return themes.minimal;
        if (name === "terminal") return themes.terminal;
        return themes.btop;
    }

    // Theme definitions (inline to avoid singleton loading issues)
    QtObject {
        id: themes

        property var btop: ({
            cpuLow: "#50fa7b", cpuMid: "#f1fa8c", cpuHigh: "#ff5555",
            ram: "#8be9fd", swap: "#bd93f9",
            netDown: "#8be9fd", netUp: "#ff79c6",
            diskRead: "#50fa7b", diskWrite: "#f1fa8c",
            tempCool: "#50fa7b", tempWarm: "#f1fa8c", tempHot: "#ffb86c", tempCritical: "#ff5555",
            graphBg: Qt.rgba(1, 1, 1, 0.05), separator: Qt.rgba(1, 1, 1, 0.15)
        })

        property var minimal: ({
            cpuLow: "#aaaaaa", cpuMid: "#aaaaaa", cpuHigh: "#cccccc",
            ram: "#aaaaaa", swap: "#888888",
            netDown: "#aaaaaa", netUp: "#888888",
            diskRead: "#aaaaaa", diskWrite: "#888888",
            tempCool: "#aaaaaa", tempWarm: "#aaaaaa", tempHot: "#bbbbbb", tempCritical: "#cccccc",
            graphBg: Qt.rgba(0.5, 0.5, 0.5, 0.05), separator: Qt.rgba(0.5, 0.5, 0.5, 0.15)
        })

        property var terminal: ({
            cpuLow: "#00ff41", cpuMid: "#ffb000", cpuHigh: "#ff3333",
            ram: "#00ff41", swap: "#00aa2a",
            netDown: "#00ff41", netUp: "#ffb000",
            diskRead: "#00ff41", diskWrite: "#ffb000",
            tempCool: "#00aa2a", tempWarm: "#00ff41", tempHot: "#ffb000", tempCritical: "#ff3333",
            graphBg: Qt.rgba(0, 1, 0.25, 0.03), separator: Qt.rgba(0, 1, 0.25, 0.2)
        })
    }

    function cpuColor(percent) {
        if (percent > 80) return theme.cpuHigh;
        if (percent > 50) return theme.cpuMid;
        return theme.cpuLow;
    }

    function tempColor(degrees) {
        if (degrees > 80) return theme.tempCritical;
        if (degrees > 60) return theme.tempHot;
        if (degrees > 40) return theme.tempWarm;
        return theme.tempCool;
    }

    // --- Process reader via shell ---
    // Uses ps with -o for clean field extraction (avoids parsing issues with spaces in commands)
    PlasmaCore.DataSource {
        id: processSource
        engine: "executable"
        connectedSources: []

        property var processes: []
        // Use -o for predictable output: comm gives just the process name, no path
        property string helperCmd: "ps -eo comm:20,%cpu,%mem --sort=-%cpu --no-headers | head -5 | awk '{printf \"%s|%s|%s\\n\", $1, $2, $3}'"

        function refresh() {
            if (connectedSources.indexOf(helperCmd) !== -1) {
                disconnectSource(helperCmd);
            }
            connectSource(helperCmd);
        }

        onNewData: function(source, data) {
            var stdout = data["stdout"] || "";
            var lines = stdout.trim().split("\n");
            var procs = [];
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim();
                if (line.length === 0) continue;
                var parts = line.split("|");
                if (parts.length >= 3) {
                    var cpuVal = parseFloat(parts[1]);
                    var memVal = parseFloat(parts[2]);
                    procs.push({
                        name: parts[0].trim(),
                        cpu: isNaN(cpuVal) ? 0 : cpuVal,
                        mem: isNaN(memVal) ? 0 : memVal
                    });
                }
            }
            processes = procs;
            disconnectSource(source);
        }

        Timer {
            interval: 2000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: processSource.refresh()
        }
    }

    // --- Temperature reader ---
    QtObject {
        id: tempReader
        property var temperatures: []

        function readTemps() {
            readZone([], 0);
        }

        function readZone(temps, zoneIdx) {
            if (zoneIdx > 10) {
                temperatures = temps;
                return;
            }
            var path = "/sys/class/thermal/thermal_zone" + zoneIdx + "/temp";
            var xhr = new XMLHttpRequest();
            xhr.open("GET", path);
            xhr.timeout = 2000;
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    var text = (xhr.responseText || "").trim();
                    if (text.length > 0) {
                        var val = parseInt(text);
                        if (!isNaN(val) && val > 0) {
                            var name = (zoneIdx === 0) ? "CPU" : "Zone " + zoneIdx;
                            temps.push({ name: name, temp: Math.round(val / 1000) });
                        }
                    }
                    readZone(temps, zoneIdx + 1);
                }
            };
            xhr.ontimeout = function() {
                readZone(temps, zoneIdx + 1); // Skip timed-out zone
            };
            xhr.send();
        }

        Timer {
            interval: 3000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: tempReader.readTemps()
        }
    }

    // --- GPU temperature via hwmon ---
    PlasmaCore.DataSource {
        id: gpuTempSource
        engine: "executable"
        connectedSources: []

        property int gpuTemp: -1
        // Try nvidia-smi first, fallback to hwmon amdgpu
        property string gpuCmd: "/bin/sh -c 'nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null || for f in /sys/class/hwmon/hwmon*/temp1_input; do name=$(cat \"$(dirname \"$f\")/name\" 2>/dev/null); if [ \"$name\" = \"amdgpu\" ] || [ \"$name\" = \"nvidia\" ]; then cat \"$f\" 2>/dev/null; break; fi; done'"

        function refresh() {
            if (connectedSources.indexOf(gpuCmd) !== -1) disconnectSource(gpuCmd);
            connectSource(gpuCmd);
        }

        onNewData: function(source, data) {
            var stdout = (data["stdout"] || "").trim();
            var val = parseInt(stdout);
            if (!isNaN(val) && val > 0) {
                // nvidia-smi returns degrees directly, hwmon returns millidegrees
                gpuTemp = val > 1000 ? Math.round(val / 1000) : val;
            } else {
                gpuTemp = -1;
            }
            disconnectSource(source);
        }

        Timer {
            interval: 3000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: gpuTempSource.refresh()
        }
    }

    // --- UI ---
    Flickable {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        contentHeight: mainColumn.implicitHeight
        clip: true

        ColumnLayout {
            id: mainColumn
            width: parent.width
            spacing: Kirigami.Units.largeSpacing

            // --- Header ---
            PlasmaComponents.Label {
                text: "RPL Monitor"
                font.bold: true
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.4
                Layout.alignment: Qt.AlignHCenter
            }

            // --- CPU Section (always visible) ---
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                RowLayout {
                    Layout.fillWidth: true

                    PlasmaComponents.Label {
                        text: "CPU"
                        font.bold: true
                    }

                    Item { Layout.fillWidth: true }

                    PlasmaComponents.Label {
                        text: cpuReader.cpuPercent + "%"
                        font.family: "monospace"
                        color: cpuColor(cpuReader.cpuPercent)
                    }
                }

                // CPU history graph
                Components.CPUGraph {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                    history: cpuReader.history
                    lineColor: theme.cpuLow
                    visible: Plasmoid.configuration.showCpuGraph !== false
                }

                // Per-core CPU bars
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: Kirigami.Units.smallSpacing
                    rowSpacing: 2
                    visible: Plasmoid.configuration.showPerCore !== false

                    Repeater {
                        model: cpuReader.corePercents.length

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Kirigami.Units.smallSpacing

                            PlasmaComponents.Label {
                                text: index.toString()
                                font.family: "monospace"
                                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                                Layout.minimumWidth: Kirigami.Units.gridUnit * 1.2
                                horizontalAlignment: Text.AlignRight
                                color: Kirigami.Theme.disabledTextColor
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: Kirigami.Units.gridUnit * 0.6
                                color: fullRoot.theme.graphBg
                                radius: 2

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: Math.max(0, parent.width * (cpuReader.corePercents[index] || 0) / 100)
                                    radius: 2
                                    color: cpuColor(cpuReader.corePercents[index] || 0)

                                    Behavior on width {
                                        NumberAnimation { duration: 200 }
                                    }
                                }
                            }

                            PlasmaComponents.Label {
                                text: (cpuReader.corePercents[index] || 0) + "%"
                                font.family: "monospace"
                                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                                Layout.minimumWidth: Kirigami.Units.gridUnit * 2
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }
            }

            // --- Separator ---
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Kirigami.Theme.disabledTextColor; opacity: 0.3
                visible: ramSection.visible
            }

            // --- RAM Section ---
            Components.RAMGraph {
                id: ramSection
                Layout.fillWidth: true
                totalGB: ramReader.totalGB
                usedGB: ramReader.usedGB
                usedPercent: ramReader.usedPercent
                swapTotalGB: ramReader.swapTotalGB
                swapUsedGB: ramReader.swapUsedGB
                swapPercent: ramReader.swapPercent
                colorHigh: fullRoot.theme.cpuHigh
                colorMid: fullRoot.theme.cpuMid
                colorRam: fullRoot.theme.ram
                colorSwap: fullRoot.theme.swap
                visible: Plasmoid.configuration.showRam !== false
            }

            // --- Separator ---
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Kirigami.Theme.disabledTextColor; opacity: 0.3
                visible: netSection.visible
            }

            // --- Network Section ---
            Components.NetGraph {
                id: netSection
                Layout.fillWidth: true
                interfaceName: netReader.activeInterface
                downloadSpeed: netReader.downloadSpeed
                uploadSpeed: netReader.uploadSpeed
                downloadHistory: netReader.downloadHistory
                uploadHistory: netReader.uploadHistory
                colorDown: fullRoot.theme.netDown
                colorUp: fullRoot.theme.netUp
                visible: Plasmoid.configuration.showNetwork !== false
            }

            // --- Separator ---
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Kirigami.Theme.disabledTextColor; opacity: 0.3
                visible: diskSection.visible
            }

            // --- Disk Section ---
            Components.DiskGraph {
                id: diskSection
                Layout.fillWidth: true
                readSpeed: diskReader.readSpeed
                writeSpeed: diskReader.writeSpeed
                readHistory: diskReader.readHistory
                writeHistory: diskReader.writeHistory
                colorRead: fullRoot.theme.diskRead
                colorWrite: fullRoot.theme.diskWrite
                visible: Plasmoid.configuration.showDisk !== false
            }

            // --- Separator ---
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Kirigami.Theme.disabledTextColor; opacity: 0.3
                visible: tempSection.visible
            }

            // --- Temperature Section ---
            Components.TempDisplay {
                id: tempSection
                Layout.fillWidth: true
                visible: Plasmoid.configuration.showTemps !== false
                colorCool: fullRoot.theme.tempCool
                colorWarm: fullRoot.theme.tempWarm
                colorHot: fullRoot.theme.tempHot
                colorCritical: fullRoot.theme.tempCritical
                temperatures: {
                    var temps = tempReader.temperatures.slice();
                    if (gpuTempSource.gpuTemp > 0) {
                        temps.push({ name: "GPU", temp: gpuTempSource.gpuTemp });
                    }
                    return temps;
                }
            }

            // --- Separator ---
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Kirigami.Theme.disabledTextColor; opacity: 0.3
                visible: processSection.visible
            }

            // --- Process List ---
            Components.ProcessList {
                id: processSection
                Layout.fillWidth: true
                processes: processSource.processes
                colorHigh: fullRoot.theme.cpuHigh
                colorMid: fullRoot.theme.cpuMid
                visible: Plasmoid.configuration.showProcesses !== false
            }

            // --- Footer ---
            PlasmaComponents.Label {
                text: "v0.5.0"
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                color: Kirigami.Theme.disabledTextColor
                Layout.alignment: Qt.AlignRight
            }
        }
    }
}
