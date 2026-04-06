// ConfigAppearance.qml — Appearance settings page
// Allows users to toggle sections, pick theme, and set update interval

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configPage

    property alias cfg_updateInterval: updateIntervalSpinBox.value
    // Initialized from saved config, defaults to "btop" on first use
    property string cfg_theme: Plasmoid.configuration.theme || "btop"
    property alias cfg_showCpuGraph: showCpuGraphCheck.checked
    property alias cfg_showPerCore: showPerCoreCheck.checked
    property alias cfg_showRam: showRamCheck.checked
    property alias cfg_showNetwork: showNetworkCheck.checked
    property alias cfg_showDisk: showDiskCheck.checked
    property alias cfg_showTemps: showTempsCheck.checked
    property alias cfg_showProcesses: showProcessesCheck.checked

    property var themeNames: ["btop", "minimal", "terminal"]

    Kirigami.FormLayout {

        // Update interval
        QQC2.SpinBox {
            id: updateIntervalSpinBox
            Kirigami.FormData.label: i18n("Update interval (ms):")
            from: 250
            to: 10000
            stepSize: 250
            value: Plasmoid.configuration.updateInterval
        }

        // Theme selector
        QQC2.ComboBox {
            id: themeCombo
            Kirigami.FormData.label: i18n("Theme:")
            model: [
                i18n("btop (Dracula colors)"),
                i18n("Minimal (Monochrome)"),
                i18n("Terminal (Green CRT)")
            ]
            currentIndex: themeNames.indexOf(cfg_theme)
            onCurrentIndexChanged: {
                cfg_theme = themeNames[currentIndex] || "btop";
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Visible sections")
        }

        QQC2.CheckBox {
            id: showCpuGraphCheck
            Kirigami.FormData.label: i18n("CPU history graph:")
            checked: Plasmoid.configuration.showCpuGraph
        }

        QQC2.CheckBox {
            id: showPerCoreCheck
            Kirigami.FormData.label: i18n("Per-core CPU bars:")
            checked: Plasmoid.configuration.showPerCore
        }

        QQC2.CheckBox {
            id: showRamCheck
            Kirigami.FormData.label: i18n("RAM / Swap:")
            checked: Plasmoid.configuration.showRam
        }

        QQC2.CheckBox {
            id: showNetworkCheck
            Kirigami.FormData.label: i18n("Network:")
            checked: Plasmoid.configuration.showNetwork
        }

        QQC2.CheckBox {
            id: showDiskCheck
            Kirigami.FormData.label: i18n("Disk I/O:")
            checked: Plasmoid.configuration.showDisk
        }

        QQC2.CheckBox {
            id: showTempsCheck
            Kirigami.FormData.label: i18n("Temperatures:")
            checked: Plasmoid.configuration.showTemps
        }

        QQC2.CheckBox {
            id: showProcessesCheck
            Kirigami.FormData.label: i18n("Top processes:")
            checked: Plasmoid.configuration.showProcesses
        }
    }
}
