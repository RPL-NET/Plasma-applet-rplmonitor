// TempDisplay.qml — CPU/GPU temperature display
// Reads temperatures passed as array and shows bars with colors

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: tempDisplay

    property var temperatures: []  // [{name: "CPU", temp: 45}, ...]

    // Theme colors (passed from FullRepresentation)
    property color colorCool: "#50fa7b"
    property color colorWarm: "#f1fa8c"
    property color colorHot: "#ffb86c"
    property color colorCritical: "#ff5555"

    function tempColor(degrees) {
        if (degrees > 80) return colorCritical;
        if (degrees > 60) return colorHot;
        if (degrees > 40) return colorWarm;
        return colorCool;
    }

    spacing: Kirigami.Units.smallSpacing

    PlasmaComponents.Label {
        text: "TEMP"
        font.bold: true
    }

    Repeater {
        model: tempDisplay.temperatures

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents.Label {
                text: modelData.name || "?"
                font.family: "monospace"
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                Layout.minimumWidth: Kirigami.Units.gridUnit * 3
            }

            Rectangle {
                Layout.fillWidth: true
                height: Kirigami.Units.gridUnit * 0.8
                color: Kirigami.Theme.backgroundColor
                radius: 2
                border.color: Kirigami.Theme.disabledTextColor
                border.width: 1

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: 1
                    width: Math.max(0, (parent.width - 2) * Math.min(modelData.temp, 110) / 110)
                    radius: 1
                    color: tempDisplay.tempColor(modelData.temp)
                }
            }

            PlasmaComponents.Label {
                text: modelData.temp + "\u00B0C"
                font.family: "monospace"
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                Layout.minimumWidth: Kirigami.Units.gridUnit * 2.5
                horizontalAlignment: Text.AlignRight
                color: tempDisplay.tempColor(modelData.temp)
            }
        }
    }
}
