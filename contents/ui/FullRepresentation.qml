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
    // Resolved from Plasmoid.configuration.theme setting
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

    // Helper: pick CPU color based on theme
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

    // --- Process reader via shell helper ---
    PlasmaCore.DataSource {
        id: processSource
        engine: "executable"
        connectedSources: []

        property var processes: []
        property string helperCmd: "ps aux --sort=-%cpu | head -6 | tail -5 | awk '{split($11, cmd, \"/\"); name=cmd[length(cmd)]; printf \"%s|%s|%s\\n\", name, $3, $4}'"

        function refresh() {
            if (connectedSources.length > 0) {
                disconnectSource(helperCmd);
            }
            connectSource(helperCmd);
        }

        onNewData: function(source, data) {
            var stdout = data["stdout"] || "";
            var lines = stdout.trim().split("\n");
            var procs = [];
            for (var i = 0; i < lines.length; i++) {
                var parts = lines[i].split("|");
                if (parts.length >= 3) {
                    procs.push({
                        name: parts[0],
                        cpu: parseFloat(parts[1]) || 0,
                        mem: parseFloat(parts[2]) || 0
                    });
                }
            }
            processes = procs;
            disconnectSource(source);
        }

        // Refresh every 2 seconds
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
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "/sys/class/thermal/thermal_zone0/temp");
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    var temps = [];
                    var val = parseInt(xhr.responseText.trim());
                    if (!isNaN(val)) {
                        temps.push({ name: "CPU", temp: Math.round(val / 1000) });
                    }
                    readAdditionalZones(temps, 1);
                }
            };
            xhr.send();
        }

        function readAdditionalZones(temps, zoneIdx) {
            if (zoneIdx > 10) {
                temperatures = temps;
                return;
            }
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "/sys/class/thermal/thermal_zone" + zoneIdx + "/temp");
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.responseText && xhr.responseText.trim().length > 0) {
                        var val = parseInt(xhr.responseText.trim());
                        if (!isNaN(val) && val > 0) {
                            temps.push({ name: "Zone " + zoneIdx, temp: Math.round(val / 1000) });
                        }
                    }
                    readAdditionalZones(temps, zoneIdx + 1);
                }
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

    // --- GPU temperature via helper ---
    PlasmaCore.DataSource {
        id: gpuTempSource
        engine: "executable"
        connectedSources: []

        property int gpuTemp: -1
        property string gpuCmd: "cat /sys/class/hwmon/hwmon*/temp1_input 2>/dev/null | head -1"

        function refresh() {
            if (connectedSources.length > 0) disconnectSource(gpuCmd);
            connectSource(gpuCmd);
        }

        onNewData: function(source, data) {
            var stdout = (data["stdout"] || "").trim();
            var val = parseInt(stdout);
            gpuTemp = !isNaN(val) ? Math.round(val / 1000) : -1;
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
