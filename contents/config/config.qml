// config.qml — Configuration entry point
// Registers the appearance settings page in KDE's widget config dialog

import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("Appearance")
        icon: "preferences-desktop-color"
        source: "ConfigAppearance.qml"
    }
}
