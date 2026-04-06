// minimal.qml — Monochrome minimal theme
// Clean, single-color design that blends with any Plasma theme

pragma Singleton
import QtQuick

QtObject {
    readonly property string name: "minimal"

    // All sections use the same accent color at different opacities
    readonly property color accent: "#aaaaaa"

    readonly property color cpuLow: accent
    readonly property color cpuMid: accent
    readonly property color cpuHigh: Qt.lighter(accent, 1.3)

    readonly property color ram: accent
    readonly property color swap: Qt.darker(accent, 1.3)

    readonly property color netDown: accent
    readonly property color netUp: Qt.darker(accent, 1.2)

    readonly property color diskRead: accent
    readonly property color diskWrite: Qt.darker(accent, 1.2)

    readonly property color tempCool: accent
    readonly property color tempWarm: accent
    readonly property color tempHot: Qt.lighter(accent, 1.2)
    readonly property color tempCritical: Qt.lighter(accent, 1.5)

    readonly property color graphBg: Qt.rgba(0.5, 0.5, 0.5, 0.05)
    readonly property color separator: Qt.rgba(0.5, 0.5, 0.5, 0.15)
    readonly property color gridLine: Qt.rgba(0.5, 0.5, 0.5, 0.08)

    function cpuColor(percent) {
        if (percent > 80) return cpuHigh;
        return cpuLow;
    }

    function tempColor(degrees) {
        if (degrees > 80) return tempCritical;
        if (degrees > 60) return tempHot;
        return tempCool;
    }
}
