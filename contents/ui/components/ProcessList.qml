// ProcessList.qml — Top 5 processes by CPU usage
// Displays a simple table of the most CPU-hungry processes

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: processList

    property var processes: []  // [{name: "firefox", cpu: 12.3, mem: 5.1}, ...]

    // Theme colors (passed from FullRepresentation)
    property color colorHigh: "#ff5555"
    property color colorMid: "#f1fa8c"

    spacing: Kirigami.Units.smallSpacing

    // Header
    RowLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        PlasmaComponents.Label {
            text: "PROCESS"
            font.bold: true
            Layout.fillWidth: true
        }

        PlasmaComponents.Label {
            text: "CPU%"
            font.bold: true
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            Layout.minimumWidth: Kirigami.Units.gridUnit * 3
            horizontalAlignment: Text.AlignRight
        }

        PlasmaComponents.Label {
            text: "MEM%"
            font.bold: true
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            Layout.minimumWidth: Kirigami.Units.gridUnit * 3
            horizontalAlignment: Text.AlignRight
        }
    }

    // Process rows
    Repeater {
        model: processList.processes || []

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents.Label {
                text: modelData.name || "?"
                font.family: "monospace"
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            PlasmaComponents.Label {
                property real cpuVal: (typeof modelData.cpu === "number") ? modelData.cpu : 0
                text: cpuVal.toFixed(1)
                font.family: "monospace"
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                Layout.minimumWidth: Kirigami.Units.gridUnit * 3
                horizontalAlignment: Text.AlignRight
                color: {
                    if (cpuVal > 50) return processList.colorHigh;
                    if (cpuVal > 25) return processList.colorMid;
                    return Kirigami.Theme.textColor;
                }
            }

            PlasmaComponents.Label {
                property real memVal: (typeof modelData.mem === "number") ? modelData.mem : 0
                text: memVal.toFixed(1)
                font.family: "monospace"
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                Layout.minimumWidth: Kirigami.Units.gridUnit * 3
                horizontalAlignment: Text.AlignRight
            }
        }
    }

    // Placeholder when no data
    PlasmaComponents.Label {
        visible: !processList.processes || processList.processes.length === 0
        text: "No process data"
        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
        color: Kirigami.Theme.disabledTextColor
        Layout.alignment: Qt.AlignHCenter
    }
}
