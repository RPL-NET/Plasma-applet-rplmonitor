// RAMGraph.qml — RAM and Swap usage bars
// Shows memory usage as horizontal bars with labels

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
                    if (ramGraph.usedPercent > 80) return "#ff5555";
                    if (ramGraph.usedPercent > 60) return "#f1fa8c";
                    return "#8be9fd";
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
                    if (ramGraph.swapPercent > 50) return "#ff5555";
                    if (ramGraph.swapPercent > 25) return "#f1fa8c";
                    return "#bd93f9";
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
