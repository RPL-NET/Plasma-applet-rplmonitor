// btop.qml — Dracula-inspired btop color theme (default)
// Bright, high-contrast colors on dark backgrounds

pragma Singleton
import QtQuick

QtObject {
    readonly property string name: "btop"

    // CPU colors
    readonly property color cpuLow: "#50fa7b"      // green
    readonly property color cpuMid: "#f1fa8c"      // yellow
    readonly property color cpuHigh: "#ff5555"     // red

    // RAM colors
    readonly property color ram: "#8be9fd"          // cyan
    readonly property color swap: "#bd93f9"         // purple

    // Network colors
    readonly property color netDown: "#8be9fd"      // cyan
    readonly property color netUp: "#ff79c6"        // pink

    // Disk colors
    readonly property color diskRead: "#50fa7b"     // green
    readonly property color diskWrite: "#f1fa8c"    // yellow

    // Temperature colors
    readonly property color tempCool: "#50fa7b"     // green
    readonly property color tempWarm: "#f1fa8c"     // yellow
    readonly property color tempHot: "#ffb86c"      // orange
    readonly property color tempCritical: "#ff5555" // red

    // UI colors
    readonly property color graphBg: Qt.rgba(1, 1, 1, 0.05)
    readonly property color separator: Qt.rgba(1, 1, 1, 0.15)
    readonly property color gridLine: Qt.rgba(1, 1, 1, 0.1)

    function cpuColor(percent) {
        if (percent > 80) return cpuHigh;
        if (percent > 50) return cpuMid;
        return cpuLow;
    }

    function tempColor(degrees) {
        if (degrees > 80) return tempCritical;
        if (degrees > 60) return tempHot;
        if (degrees > 40) return tempWarm;
        return tempCool;
    }
}
