// NetGraph.qml — Network upload/download speed graph
// Dual-line area chart showing download and upload speeds

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: netGraph

    property string interfaceName: ""
    property real downloadSpeed: 0
    property real uploadSpeed: 0
    property var downloadHistory: []
    property var uploadHistory: []

    // Theme colors (passed from FullRepresentation)
    property color colorDown: "#8be9fd"
    property color colorUp: "#ff79c6"

    spacing: Kirigami.Units.smallSpacing

    // Header with interface name and current speeds
    RowLayout {
        Layout.fillWidth: true

        PlasmaComponents.Label {
            text: "NET"
            font.bold: true
        }

        PlasmaComponents.Label {
            text: netGraph.interfaceName
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            color: Kirigami.Theme.disabledTextColor
        }

        Item { Layout.fillWidth: true }

        PlasmaComponents.Label {
            text: "↓ " + formatSpeed(netGraph.downloadSpeed)
            font.family: "monospace"
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            color: netGraph.colorDown
        }

        PlasmaComponents.Label {
            text: "↑ " + formatSpeed(netGraph.uploadSpeed)
            font.family: "monospace"
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            color: netGraph.colorUp
        }
    }

    // Graph canvas
    Canvas {
        id: canvas
        Layout.fillWidth: true
        Layout.preferredHeight: Kirigami.Units.gridUnit * 4

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            var dlData = netGraph.downloadHistory;
            var ulData = netGraph.uploadHistory;
            if (dlData.length < 2 && ulData.length < 2) return;

            // Find max for scaling
            var maxVal = 1024; // minimum 1 KB/s scale
            for (var i = 0; i < dlData.length; i++) maxVal = Math.max(maxVal, dlData[i]);
            for (var j = 0; j < ulData.length; j++) maxVal = Math.max(maxVal, ulData[j]);
            maxVal *= 1.1; // 10% headroom

            drawLine(ctx, dlData, netGraph.colorDown, Qt.rgba(netGraph.colorDown.r, netGraph.colorDown.g, netGraph.colorDown.b, 0.15), maxVal);
            drawLine(ctx, ulData, netGraph.colorUp, Qt.rgba(netGraph.colorUp.r, netGraph.colorUp.g, netGraph.colorUp.b, 0.15), maxVal);
        }

        function drawLine(ctx, data, lineColor, fillColor, maxVal) {
            if (data.length < 2) return;

            var maxPoints = 50;
            var stepX = width / (maxPoints - 1);
            var startIdx = Math.max(0, data.length - maxPoints);

            // Fill
            ctx.beginPath();
            ctx.moveTo(0, height);
            for (var i = startIdx; i < data.length; i++) {
                var x = (i - startIdx) * stepX;
                var y = height - (data[i] / maxVal) * height;
                ctx.lineTo(x, y);
            }
            ctx.lineTo((data.length - 1 - startIdx) * stepX, height);
            ctx.closePath();
            ctx.fillStyle = fillColor;
            ctx.fill();

            // Line
            ctx.beginPath();
            for (var j = startIdx; j < data.length; j++) {
                var lx = (j - startIdx) * stepX;
                var ly = height - (data[j] / maxVal) * height;
                if (j === startIdx) ctx.moveTo(lx, ly);
                else ctx.lineTo(lx, ly);
            }
            ctx.strokeStyle = lineColor;
            ctx.lineWidth = 1.5;
            ctx.stroke();
        }
    }

    onDownloadHistoryChanged: canvas.requestPaint()
    onUploadHistoryChanged: canvas.requestPaint()

    function formatSpeed(bytesPerSec) {
        if (bytesPerSec >= 1073741824) return (bytesPerSec / 1073741824).toFixed(1) + " GB/s";
        if (bytesPerSec >= 1048576) return (bytesPerSec / 1048576).toFixed(1) + " MB/s";
        if (bytesPerSec >= 1024) return (bytesPerSec / 1024).toFixed(1) + " KB/s";
        return Math.round(bytesPerSec) + " B/s";
    }
}
