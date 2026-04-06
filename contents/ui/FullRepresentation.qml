// FullRepresentation.qml — Popup view with CPU usage display
// This is the expanded view shown when clicking the panel widget

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: fullRoot

    Layout.minimumWidth: Kirigami.Units.gridUnit * 16
    Layout.minimumHeight: Kirigami.Units.gridUnit * 12
    Layout.preferredWidth: Kirigami.Units.gridUnit * 20
    Layout.preferredHeight: Kirigami.Units.gridUnit * 14

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing

        // Header
        PlasmaComponents.Label {
            text: "RPL Monitor"
            font.bold: true
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.4
            Layout.alignment: Qt.AlignHCenter
        }

        // CPU section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents.Label {
                text: "CPU"
                font.bold: true
            }

            // CPU percentage bar
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Rectangle {
                    Layout.fillWidth: true
                    height: Kirigami.Units.gridUnit * 1.2
                    color: Kirigami.Theme.backgroundColor
                    radius: 3
                    border.color: Kirigami.Theme.disabledTextColor
                    border.width: 1

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: 1
                        width: Math.max(0, (parent.width - 2) * cpuReader.cpuPercent / 100)
                        radius: 2
                        color: {
                            if (cpuReader.cpuPercent > 80) return "#ff5555";
                            if (cpuReader.cpuPercent > 50) return "#f1fa8c";
                            return "#50fa7b";
                        }

                        Behavior on width {
                            NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
                        }
                        Behavior on color {
                            ColorAnimation { duration: 300 }
                        }
                    }
                }

                PlasmaComponents.Label {
                    text: cpuReader.cpuPercent + "%"
                    Layout.minimumWidth: Kirigami.Units.gridUnit * 2.5
                    horizontalAlignment: Text.AlignRight
                    font.family: "monospace"
                }
            }
        }

        // Spacer — will be replaced by more sections in future versions
        Item {
            Layout.fillHeight: true
        }

        // Footer
        PlasmaComponents.Label {
            text: "v0.1.0"
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            color: Kirigami.Theme.disabledTextColor
            Layout.alignment: Qt.AlignRight
        }
    }
}
