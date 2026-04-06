// main.qml — Entry point for RPL Monitor plasmoid
// Holds all data readers (CPU, RAM, network, disk) and exposes them to representations

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root

    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}
    preferredRepresentation: compactRepresentation

    toolTipMainText: "RPL Monitor"
    toolTipSubText: {
        var lines = [];
        lines.push("CPU: " + cpuReader.cpuPercent + "%");
        lines.push("RAM: " + ramReader.usedGB.toFixed(1) + "/" + ramReader.totalGB.toFixed(1) + " GB (" + ramReader.usedPercent + "%)");
        if (ramReader.swapTotalGB > 0)
            lines.push("Swap: " + ramReader.swapUsedGB.toFixed(1) + "/" + ramReader.swapTotalGB.toFixed(1) + " GB");
        if (netReader.activeInterface)
            lines.push("Net: ↓" + formatSpeed(netReader.downloadSpeed) + " ↑" + formatSpeed(netReader.uploadSpeed));
        return lines.join("\n");
    }

    // Format bytes/sec to human readable string
    function formatSpeed(bytesPerSec) {
        if (bytesPerSec >= 1048576) return (bytesPerSec / 1048576).toFixed(1) + " MB/s";
        if (bytesPerSec >= 1024) return (bytesPerSec / 1024).toFixed(1) + " KB/s";
        return Math.round(bytesPerSec) + " B/s";
    }

    // Configurable update interval (milliseconds), clamped to safe range
    property int updateInterval: Math.max(250, Plasmoid.configuration.updateInterval || 1000)

    // --- CPU data reader ---
    // Reads /proc/stat and computes total + per-core CPU usage
    QtObject {
        id: cpuReader

        property int cpuPercent: 0
        property var corePercents: []   // per-core usage array
        property var history: []        // last 50 total CPU readings
        readonly property int historySize: 50

        // Previous tick values for delta calculation
        property var prevIdle: 0
        property var prevTotal: 0
        property var prevCoreIdle: []
        property var prevCoreTotal: []

        function readCpuUsage() {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "/proc/stat");
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    var text = xhr.responseText || "";
                    if (text.length > 0) {
                        parseProcStat(text);
                    }
                }
            };
            xhr.send();
        }

        function parseProcStat(text) {
            var lines = text.split("\n");
            var newCorePercents = [];
            var newPrevCoreIdle = [];
            var newPrevCoreTotal = [];

            for (var i = 0; i < lines.length; i++) {
                var parts = lines[i].trim().split(/\s+/);
                if (parts.length < 5) continue;

                if (parts[0] === "cpu") {
                    // Aggregate CPU line
                    var result = calcCpuDelta(parts, prevIdle, prevTotal);
                    cpuPercent = result.percent;
                    prevIdle = result.idle;
                    prevTotal = result.total;
                } else if (parts[0].indexOf("cpu") === 0 && parts[0].length > 3) {
                    // Per-core lines (cpu0, cpu1, ...)
                    var coreIdx = parseInt(parts[0].substring(3));
                    if (isNaN(coreIdx)) continue;
                    var oldIdle = (prevCoreIdle[coreIdx] !== undefined) ? prevCoreIdle[coreIdx] : 0;
                    var oldTotal = (prevCoreTotal[coreIdx] !== undefined) ? prevCoreTotal[coreIdx] : 0;
                    var coreResult = calcCpuDelta(parts, oldIdle, oldTotal);
                    newCorePercents[coreIdx] = coreResult.percent;
                    newPrevCoreIdle[coreIdx] = coreResult.idle;
                    newPrevCoreTotal[coreIdx] = coreResult.total;
                }
            }

            prevCoreIdle = newPrevCoreIdle;
            prevCoreTotal = newPrevCoreTotal;
            corePercents = newCorePercents;

            // Update history ring buffer
            var h = history.slice();
            h.push(cpuPercent);
            if (h.length > historySize) h.shift();
            history = h;
        }

        function calcCpuDelta(parts, oldIdle, oldTotal) {
            var user    = parseInt(parts[1]) || 0;
            var nice    = parseInt(parts[2]) || 0;
            var system  = parseInt(parts[3]) || 0;
            var idle    = parseInt(parts[4]) || 0;
            var iowait  = parseInt(parts[5]) || 0;
            var irq     = parseInt(parts[6]) || 0;
            var softirq = parseInt(parts[7]) || 0;
            var steal   = parseInt(parts[8]) || 0;

            var totalIdle = idle + iowait;
            var total = user + nice + system + idle + iowait + irq + softirq + steal;

            var diffIdle  = totalIdle - oldIdle;
            var diffTotal = total - oldTotal;

            var percent = 0;
            if (diffTotal > 0) {
                percent = Math.round(Math.min(100, Math.max(0, (1.0 - diffIdle / diffTotal) * 100)));
            }

            return { percent: percent, idle: totalIdle, total: total };
        }
    }

    // --- RAM/Swap data reader ---
    // Reads /proc/meminfo for memory and swap usage
    QtObject {
        id: ramReader

        property real totalGB: 0
        property real usedGB: 0
        property int usedPercent: 0
        property real swapTotalGB: 0
        property real swapUsedGB: 0
        property int swapPercent: 0

        function readMemInfo() {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "/proc/meminfo");
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    var text = xhr.responseText || "";
                    if (text.length > 0) {
                        parseMemInfo(text);
                    }
                }
            };
            xhr.send();
        }

        function parseMemInfo(text) {
            var values = {};
            var lines = text.split("\n");
            for (var i = 0; i < lines.length; i++) {
                var match = lines[i].match(/^(\w+):\s+(\d+)/);
                if (match) {
                    var val = parseInt(match[2]);
                    if (!isNaN(val)) {
                        values[match[1]] = val; // in kB
                    }
                }
            }

            var memTotal = values["MemTotal"] || 0;
            var memAvailable = values["MemAvailable"] || 0;
            var memUsed = memTotal - memAvailable;

            totalGB = memTotal / 1048576;
            usedGB = memUsed / 1048576;
            usedPercent = memTotal > 0 ? Math.round(memUsed / memTotal * 100) : 0;

            var swTotal = values["SwapTotal"] || 0;
            var swFree = values["SwapFree"] || 0;
            var swUsed = swTotal - swFree;

            swapTotalGB = swTotal / 1048576;
            swapUsedGB = swUsed / 1048576;
            swapPercent = swTotal > 0 ? Math.round(swUsed / swTotal * 100) : 0;
        }
    }

    // --- Network data reader ---
    // Reads /proc/net/dev for upload/download speeds
    QtObject {
        id: netReader

        property string activeInterface: ""
        property real downloadSpeed: 0  // bytes per second
        property real uploadSpeed: 0    // bytes per second
        property var downloadHistory: []
        property var uploadHistory: []
        readonly property int historySize: 50

        property var prevRxBytes: 0
        property var prevTxBytes: 0
        property bool firstRead: true

        function readNetDev() {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "/proc/net/dev");
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    var text = xhr.responseText || "";
                    if (text.length > 0) {
                        parseNetDev(text);
                    }
                }
            };
            xhr.send();
        }

        function parseNetDev(text) {
            var lines = text.split("\n");
            var bestIface = "";
            var bestRx = 0;
            var bestTx = 0;

            for (var i = 2; i < lines.length; i++) { // skip header lines
                var line = lines[i].trim();
                if (line.length === 0) continue;

                var colonIdx = line.indexOf(":");
                if (colonIdx < 0) continue;

                var iface = line.substring(0, colonIdx).trim();
                var rest = line.substring(colonIdx + 1).trim().split(/\s+/);

                // Skip loopback
                if (iface === "lo") continue;

                var rxBytes = parseInt(rest[0]) || 0;
                var txBytes = (rest.length > 8) ? (parseInt(rest[8]) || 0) : 0;

                // Pick the interface with the most traffic
                if (rxBytes + txBytes > bestRx + bestTx) {
                    bestIface = iface;
                    bestRx = rxBytes;
                    bestTx = txBytes;
                }
            }

            activeInterface = bestIface;

            if (firstRead) {
                prevRxBytes = bestRx;
                prevTxBytes = bestTx;
                firstRead = false;
                return;
            }

            var intervalSec = Math.max(1, root.updateInterval) / 1000;
            downloadSpeed = Math.max(0, (bestRx - prevRxBytes) / intervalSec);
            uploadSpeed = Math.max(0, (bestTx - prevTxBytes) / intervalSec);

            prevRxBytes = bestRx;
            prevTxBytes = bestTx;

            // Update histories
            var dh = downloadHistory.slice();
            dh.push(downloadSpeed);
            if (dh.length > historySize) dh.shift();
            downloadHistory = dh;

            var uh = uploadHistory.slice();
            uh.push(uploadSpeed);
            if (uh.length > historySize) uh.shift();
            uploadHistory = uh;
        }
    }

    // --- Disk I/O reader ---
    // Reads /proc/diskstats for read/write throughput
    QtObject {
        id: diskReader

        property real readSpeed: 0   // bytes per second
        property real writeSpeed: 0  // bytes per second
        property var readHistory: []
        property var writeHistory: []
        readonly property int historySize: 50

        property var prevReadSectors: 0
        property var prevWriteSectors: 0
        property bool firstRead: true
        property string diskName: ""

        function readDiskStats() {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "/proc/diskstats");
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    var text = xhr.responseText || "";
                    if (text.length > 0) {
                        parseDiskStats(text);
                    }
                }
            };
            xhr.send();
        }

        function parseDiskStats(text) {
            var lines = text.split("\n");
            var totalReadSectors = 0;
            var totalWriteSectors = 0;

            for (var i = 0; i < lines.length; i++) {
                var parts = lines[i].trim().split(/\s+/);
                if (parts.length < 14) continue;

                var name = parts[2];
                // Match whole disks: sda-sdz, sdaa+, nvmeXnY, vda-vdz, hda-hdz, mmcblkN
                if (/^(sd[a-z]+|nvme\d+n\d+|vd[a-z]+|hd[a-z]|mmcblk\d+)$/.test(name)) {
                    totalReadSectors += parseInt(parts[5]) || 0;  // sectors read
                    totalWriteSectors += parseInt(parts[9]) || 0; // sectors written
                    if (!diskName) diskName = name;
                }
            }

            if (firstRead) {
                prevReadSectors = totalReadSectors;
                prevWriteSectors = totalWriteSectors;
                firstRead = false;
                return;
            }

            var intervalSec = Math.max(1, root.updateInterval) / 1000;
            // Sector size is typically 512 bytes
            readSpeed = Math.max(0, (totalReadSectors - prevReadSectors) * 512 / intervalSec);
            writeSpeed = Math.max(0, (totalWriteSectors - prevWriteSectors) * 512 / intervalSec);

            prevReadSectors = totalReadSectors;
            prevWriteSectors = totalWriteSectors;

            var rh = readHistory.slice();
            rh.push(readSpeed);
            if (rh.length > historySize) rh.shift();
            readHistory = rh;

            var wh = writeHistory.slice();
            wh.push(writeSpeed);
            if (wh.length > historySize) wh.shift();
            writeHistory = wh;
        }
    }

    // --- Main update timer ---
    Timer {
        interval: root.updateInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuReader.readCpuUsage();
            ramReader.readMemInfo();
            netReader.readNetDev();
            diskReader.readDiskStats();
        }
    }
}
