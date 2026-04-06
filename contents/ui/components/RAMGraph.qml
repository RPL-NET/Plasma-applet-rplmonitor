// RAMGraph.qml — RAM and Swap usage bars
// Shows memory usage as horizontal bars with labels
// Colors are passed in from the parent via theme properties

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: ramGraph

    property real totalGB: 0
    property real usedGB: 0
    property int usedPercent: 0
    property real swapTotalGB: 0
    property real swapUsedGB: 0
    property int swapPercent: 0

    // Theme colors (passed from FullRepresentation)
    property color colorHigh: "#ff5555"
    property color colorMid: "#f1fa8c"
    property color colorRam: "#8be9fd"
    property color colorSwap: "#bd93f9"

    spacing: Kirigami.Units.smallSpacing

    // RAM bar
    RowLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        PlasmaComponents.Label {
            text: "RAM"
            font.bold: true
            Layout.minimumWidth: Kirigami.Units.gridUnit * 2.5
        }

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
                width: Math.max(0, (parent.width - 2) * ramGraph.usedPercent / 100)
                radius: 2
                color: {
                    if (ramGraph.usedPercent > 80) return ramGraph.colorHigh;
                    if (ramGraph.usedPercent > 60) return ramGraph.colorMid;
                    return ramGraph.colorRam;
                }

                Behavior on width {
                    NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
                }
            }
        }

        PlasmaComponents.Label {
            text: ramGraph.usedGB.toFixed(1) + "/" + ramGraph.totalGB.toFixed(1) + " GB"
            Layout.minimumWidth: Kirigami.Units.gridUnit * 5
            horizontalAlignment: Text.AlignRight
            font.family: "monospace"
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
        }
    }

    // Swap bar (only visible if swap exists)
    RowLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing
        visible: ramGraph.swapTotalGB > 0

        PlasmaComponents.Label {
            text: "SWP"
            font.bold: true
            Layout.minimumWidth: Kirigami.Units.gridUnit * 2.5
        }

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
                width: Math.max(0, (parent.width - 2) * ramGraph.swapPercent / 100)
                radius: 2
                color: {
                    if (ramGraph.swapPercent > 50) return ramGraph.colorHigh;
                    if (ramGraph.swapPercent > 25) return ramGraph.colorMid;
                    return ramGraph.colorSwap;
                }

                Behavior on width {
                    NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
                }
            }
        }

        PlasmaComponents.Label {
            text: ramGraph.swapUsedGB.toFixed(1) + "/" + ramGraph.swapTotalGB.toFixed(1) + " GB"
            Layout.minimumWidth: Kirigami.Units.gridUnit * 5
            horizontalAlignment: Text.AlignRight
            font.family: "monospace"
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
        }
    }
}
