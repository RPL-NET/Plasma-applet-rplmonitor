// CompactRepresentation.qml — Panel view (small icon + CPU %)
// Shows a concise CPU percentage in the system tray / panel
// Color respects the active theme

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

MouseArea {
    id: compactRoot

    // Theme colors passed from main.qml
    property color themeHigh: "#ff5555"
    property color themeMid: "#f1fa8c"

    Layout.minimumWidth: row.implicitWidth
    Layout.preferredWidth: row.implicitWidth

    onClicked: Plasmoid.expanded = !Plasmoid.expanded

    RowLayout {
        id: row
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            source: "utilities-system-monitor"
            Layout.preferredWidth: Kirigami.Units.iconSizes.small
            Layout.preferredHeight: Kirigami.Units.iconSizes.small
        }

        Text {
            text: cpuReader.cpuPercent + "%"
            font.family: "monospace"
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
            color: {
                if (cpuReader.cpuPercent > 80) return compactRoot.themeHigh;
                if (cpuReader.cpuPercent > 50) return compactRoot.themeMid;
                return Kirigami.Theme.textColor;
            }
        }
    }
}
