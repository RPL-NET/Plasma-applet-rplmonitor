// TempDisplay.qml — CPU/GPU temperature display
// Reads temperatures from /sys/class/thermal and /sys/class/hwmon

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: tempDisplay

    property var temperatures: []  // [{name: "CPU", temp: 45}, ...]

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
                text: modelData.name
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
                    // Scale: 0-100 degrees C
                    width: Math.max(0, (parent.width - 2) * Math.min(modelData.temp, 100) / 100)
                    radius: 1
                    color: {
                        if (modelData.temp > 80) return "#ff5555";
                        if (modelData.temp > 60) return "#ffb86c";
                        if (modelData.temp > 40) return "#f1fa8c";
                        return "#50fa7b";
                    }
                }
            }

            PlasmaComponents.Label {
                text: modelData.temp + "°C"
                font.family: "monospace"
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                Layout.minimumWidth: Kirigami.Units.gridUnit * 2.5
                horizontalAlignment: Text.AlignRight
                color: {
                    if (modelData.temp > 80) return "#ff5555";
                    if (modelData.temp > 60) return "#ffb86c";
                    return Kirigami.Theme.textColor;
                }
            }
        }
    }
}
