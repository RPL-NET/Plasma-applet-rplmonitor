// DiskGraph.qml — Disk I/O read/write speed display
// Shows read (green) and write (yellow) throughput with mini graph

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: diskGraph

    property real readSpeed: 0
    property real writeSpeed: 0
    property var readHistory: []
    property var writeHistory: []

    spacing: Kirigami.Units.smallSpacing

    // Header with current speeds
    RowLayout {
        Layout.fillWidth: true

        PlasmaComponents.Label {
            text: "DISK"
            font.bold: true
        }

        Item { Layout.fillWidth: true }

        PlasmaComponents.Label {
            text: "R " + formatSpeed(diskGraph.readSpeed)
            font.family: "monospace"
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            color: "#50fa7b"
        }

        PlasmaComponents.Label {
            text: "W " + formatSpeed(diskGraph.writeSpeed)
            font.family: "monospace"
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            color: "#f1fa8c"
        }
    }

    // Graph canvas
    Canvas {
        id: canvas
        Layout.fillWidth: true
        Layout.preferredHeight: Kirigami.Units.gridUnit * 3

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            var rData = diskGraph.readHistory;
            var wData = diskGraph.writeHistory;
            if (rData.length < 2 && wData.length < 2) return;

            var maxVal = 1024;
            for (var i = 0; i < rData.length; i++) maxVal = Math.max(maxVal, rData[i]);
            for (var j = 0; j < wData.length; j++) maxVal = Math.max(maxVal, wData[j]);
            maxVal *= 1.1;

            drawArea(ctx, rData, "#50fa7b", Qt.rgba(0.314, 0.98, 0.482, 0.15), maxVal);
            drawArea(ctx, wData, "#f1fa8c", Qt.rgba(0.945, 0.98, 0.549, 0.15), maxVal);
        }

        function drawArea(ctx, data, lineColor, fillColor, maxVal) {
            if (data.length < 2) return;

            var maxPoints = 50;
            var stepX = width / (maxPoints - 1);
            var startIdx = Math.max(0, data.length - maxPoints);

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

    onReadHistoryChanged: canvas.requestPaint()
    onWriteHistoryChanged: canvas.requestPaint()

    function formatSpeed(bytesPerSec) {
        if (bytesPerSec >= 1073741824) return (bytesPerSec / 1073741824).toFixed(1) + " GB/s";
        if (bytesPerSec >= 1048576) return (bytesPerSec / 1048576).toFixed(1) + " MB/s";
        if (bytesPerSec >= 1024) return (bytesPerSec / 1024).toFixed(1) + " KB/s";
        return Math.round(bytesPerSec) + " B/s";
    }
}
