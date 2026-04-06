// FullRepresentation.qml — Full popup view with all system monitors
// Displays CPU graph, per-core bars, RAM, network, disk, temps, and processes

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import "components" as Components

Item {
    id: fullRoot

    Layout.minimumWidth: Kirigami.Units.gridUnit * 18
    Layout.minimumHeight: Kirigami.Units.gridUnit * 24
    Layout.preferredWidth: Kirigami.Units.gridUnit * 22
    Layout.preferredHeight: Kirigami.Units.gridUnit * 30

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

            // --- CPU Section ---
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                // CPU header with total percentage
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
                        color: {
                            if (cpuReader.cpuPercent > 80) return "#ff5555";
                            if (cpuReader.cpuPercent > 50) return "#f1fa8c";
                            return "#50fa7b";
                        }
                    }
                }

                // CPU history graph
                Components.CPUGraph {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                    history: cpuReader.history
                    lineColor: "#50fa7b"
                }

                // Per-core CPU bars (btop style)
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: Kirigami.Units.smallSpacing
                    rowSpacing: 2

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
                                color: Qt.rgba(1, 1, 1, 0.05)
                                radius: 2

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: Math.max(0, parent.width * (cpuReader.corePercents[index] || 0) / 100)
                                    radius: 2
                                    color: {
                                        var val = cpuReader.corePercents[index] || 0;
                                        if (val > 80) return "#ff5555";
                                        if (val > 50) return "#f1fa8c";
                                        return "#50fa7b";
                                    }

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
                Layout.fillWidth: true
                height: 1
                color: Kirigami.Theme.disabledTextColor
                opacity: 0.3
            }

            // --- RAM Section ---
            Components.RAMGraph {
                Layout.fillWidth: true
                totalGB: ramReader.totalGB
                usedGB: ramReader.usedGB
                usedPercent: ramReader.usedPercent
                swapTotalGB: ramReader.swapTotalGB
                swapUsedGB: ramReader.swapUsedGB
                swapPercent: ramReader.swapPercent
            }

            // --- Separator ---
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Kirigami.Theme.disabledTextColor
                opacity: 0.3
            }

            // --- Network Section ---
            Components.NetGraph {
                Layout.fillWidth: true
                interfaceName: netReader.activeInterface
                downloadSpeed: netReader.downloadSpeed
                uploadSpeed: netReader.uploadSpeed
                downloadHistory: netReader.downloadHistory
                uploadHistory: netReader.uploadHistory
            }

            // --- Separator ---
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Kirigami.Theme.disabledTextColor
                opacity: 0.3
            }

            // --- Disk Section ---
            Components.DiskGraph {
                Layout.fillWidth: true
                readSpeed: diskReader.readSpeed
                writeSpeed: diskReader.writeSpeed
                readHistory: diskReader.readHistory
                writeHistory: diskReader.writeHistory
            }

            // --- Separator ---
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Kirigami.Theme.disabledTextColor
                opacity: 0.3
            }

            // --- Temperature Section ---
            Components.TempDisplay {
                id: tempSection
                Layout.fillWidth: true
                temperatures: tempReader.temperatures
            }

            // --- Separator ---
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Kirigami.Theme.disabledTextColor
                opacity: 0.3
            }

            // --- Process List ---
            Components.ProcessList {
                Layout.fillWidth: true
                processes: processReader.processes
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

    // --- Temperature reader ---
    // Reads from /sys/class/thermal/thermal_zone*/temp
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
                    // Try additional zones
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
                    if (xhr.status === 200 || xhr.responseText.trim().length > 0) {
                        var val = parseInt(xhr.responseText.trim());
                        if (!isNaN(val) && val > 0) {
                            var name = "Zone " + zoneIdx;
                            temps.push({ name: name, temp: Math.round(val / 1000) });
                        }
                    }
                    readAdditionalZones(temps, zoneIdx + 1);
                }
            };
            xhr.send();
        }

        // Read temps on a slower interval (every 3 seconds)
        Timer {
            interval: 3000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: tempReader.readTemps()
        }
    }

    // --- Process reader ---
    // Gets top 5 processes via /proc - reads /proc/[pid]/stat
    QtObject {
        id: processReader

        property var processes: []
        property var prevProcessCpu: ({})  // pid -> {utime, stime, timestamp}

        function readProcesses() {
            // Use DataSource to run ps command (simpler than parsing /proc/[pid]/* for all PIDs)
            var xhr = new XMLHttpRequest();
            // We'll parse /proc/loadavg as a trigger, actual process data comes from helper
            xhr.open("GET", "/proc/loadavg");
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    // Process list requires reading directories which XHR can't do
                    // This will be populated by the sensors-helper.sh via DataSource
                    // For now, leave empty until helper is connected
                }
            };
            xhr.send();
        }

        Timer {
            interval: 2000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: processReader.readProcesses()
        }
    }
}
