// terminal.qml — Classic terminal green-on-black theme
// Retro CRT monitor aesthetic

pragma Singleton
import QtQuick

QtObject {
    readonly property string name: "terminal"

    readonly property color green: "#00ff41"
    readonly property color dimGreen: "#00aa2a"
    readonly property color amber: "#ffb000"

    readonly property color cpuLow: green
    readonly property color cpuMid: amber
    readonly property color cpuHigh: "#ff3333"

    readonly property color ram: green
    readonly property color swap: dimGreen

    readonly property color netDown: green
    readonly property color netUp: amber

    readonly property color diskRead: green
    readonly property color diskWrite: amber

    readonly property color tempCool: dimGreen
    readonly property color tempWarm: green
    readonly property color tempHot: amber
    readonly property color tempCritical: "#ff3333"

    readonly property color graphBg: Qt.rgba(0, 1, 0.25, 0.03)
    readonly property color separator: Qt.rgba(0, 1, 0.25, 0.2)
    readonly property color gridLine: Qt.rgba(0, 1, 0.25, 0.08)

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
