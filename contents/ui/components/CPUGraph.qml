// CPUGraph.qml — Historical CPU usage line graph
// Displays the last 50 CPU readings as a filled area chart

import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: cpuGraph

    property var history: []
    property color lineColor: "#50fa7b"
    property color fillColor: Qt.rgba(lineColor.r, lineColor.g, lineColor.b, 0.2)

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            var data = cpuGraph.history;
            if (data.length < 2) return;

            var maxPoints = 50;
            var stepX = width / (maxPoints - 1);
            var startIdx = Math.max(0, data.length - maxPoints);

            // Fill area
            ctx.beginPath();
            ctx.moveTo(0, height);
            for (var i = startIdx; i < data.length; i++) {
                var x = (i - startIdx) * stepX;
                var y = height - (data[i] / 100) * height;
                if (i === startIdx) {
                    ctx.lineTo(x, y);
                } else {
                    ctx.lineTo(x, y);
                }
            }
            ctx.lineTo((data.length - 1 - startIdx) * stepX, height);
            ctx.closePath();
            ctx.fillStyle = cpuGraph.fillColor;
            ctx.fill();

            // Line
            ctx.beginPath();
            for (var j = startIdx; j < data.length; j++) {
                var lx = (j - startIdx) * stepX;
                var ly = height - (data[j] / 100) * height;
                if (j === startIdx) {
                    ctx.moveTo(lx, ly);
                } else {
                    ctx.lineTo(lx, ly);
                }
            }
            ctx.strokeStyle = cpuGraph.lineColor;
            ctx.lineWidth = 2;
            ctx.stroke();

            // Grid lines at 25%, 50%, 75%
            ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.1);
            ctx.lineWidth = 1;
            for (var g = 1; g <= 3; g++) {
                var gy = height - (height * g / 4);
                ctx.beginPath();
                ctx.moveTo(0, gy);
                ctx.lineTo(width, gy);
                ctx.stroke();
            }
        }
    }

    // Repaint whenever history changes
    onHistoryChanged: canvas.requestPaint()
}
