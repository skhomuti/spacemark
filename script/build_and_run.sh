#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."
# File Provider metadata on a synced checkout can prevent code signing.
build_dir="${TMPDIR:-/tmp}/SpaceMark-${UID}"
app="$build_dir/Build/Products/Debug/SpaceMark.app"

pkill -xf "$app/Contents/MacOS/SpaceMark" || true
xcodebuild -quiet -workspace SpaceMark.xcodeproj/project.xcworkspace \
    -scheme SpaceMark -configuration Debug -destination "platform=macOS,arch=$(uname -m)" \
    -derivedDataPath "$build_dir" build
printf '%s\n' "$app"
open "$app"
