#!/bin/bash
# build-plasmoid.sh — Package RPL Monitor as a .plasmoid file
# A .plasmoid is just a zip archive with the right structure
#
# Usage: ./build-plasmoid.sh
# Output: rplmonitor-0.5.0.plasmoid

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION="0.5.0"
OUTPUT="rplmonitor-${VERSION}.plasmoid"

echo "Building ${OUTPUT}..."

cd "$SCRIPT_DIR"

# Remove old build if exists
rm -f "$OUTPUT"

# Create .plasmoid (zip containing metadata.json + contents/)
zip -r "$OUTPUT" \
    metadata.json \
    contents/ \
    -x "contents/.DS_Store" \
    -x "contents/**/.DS_Store" \
    -x "**/__pycache__/*"

echo ""
echo "Built: ${OUTPUT}"
echo "Size: $(du -h "$OUTPUT" | cut -f1)"
echo ""
echo "Install:  kpackagetool6 -t Plasma/Applet -i ${OUTPUT}"
echo "Update:   kpackagetool6 -t Plasma/Applet -u ${OUTPUT}"
echo "Remove:   kpackagetool6 -t Plasma/Applet -r org.rpl.rplmonitor"
echo "Test:     plasmoidviewer -a org.rpl.rplmonitor"
