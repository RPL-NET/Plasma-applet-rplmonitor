// CompactRepresentation.qml — Panel view (small icon + CPU %)
// Shows a concise CPU percentage in the system tray / panel

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

MouseArea {
    id: compactRoot

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
            color: Kirigami.Theme.textColor
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
        }
    }
}
