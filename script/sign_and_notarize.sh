#!/bin/bash
set -euo pipefail

app="$1"
preview="$app/Contents/PlugIns/MarkdownPreview.appex"

for secret in APPLE_CERTIFICATE_BASE64 APPLE_CERTIFICATE_PASSWORD APPLE_ID APPLE_TEAM_ID APPLE_APP_SPECIFIC_PASSWORD; do
    if [[ -z "${!secret:-}" ]]; then
        echo "::error::Missing release secret $secret. See Releasing in README.md."
        exit 1
    fi
done

signing_dir=$(mktemp -d "${RUNNER_TEMP:-${TMPDIR:-/tmp}}/spacemark-sign.XXXXXX")
keychain="$signing_dir/release.keychain-db"
trap 'security delete-keychain "$keychain" >/dev/null 2>&1 || true; rm -rf "$signing_dir"' EXIT

keychain_password=$(openssl rand -hex 24)
printf '%s' "$APPLE_CERTIFICATE_BASE64" | /usr/bin/base64 -D > "$signing_dir/certificate.p12"
security create-keychain -p "$keychain_password" "$keychain"
security set-keychain-settings -lut 3600 "$keychain"
security unlock-keychain -p "$keychain_password" "$keychain"
security import "$signing_dir/certificate.p12" -k "$keychain" \
    -P "$APPLE_CERTIFICATE_PASSWORD" -T /usr/bin/codesign
security set-key-partition-list -S apple-tool:,apple: -s -k "$keychain_password" "$keychain"
security list-keychains -d user -s "$keychain"

# Keep the sandbox entitlements, strip debugging access, and sign the extension first.
entitlements="$signing_dir/entitlements.plist"
for bundle in "$preview" "$app"; do
    codesign --display --entitlements - --xml "$bundle" > "$entitlements"
    if /usr/libexec/PlistBuddy -c 'Print :com.apple.security.get-task-allow' "$entitlements" >/dev/null 2>&1; then
        /usr/libexec/PlistBuddy -c 'Delete :com.apple.security.get-task-allow' "$entitlements"
    fi
    codesign --force --sign 'Developer ID Application' --keychain "$keychain" \
        --timestamp --options runtime --entitlements "$entitlements" "$bundle"
done
codesign --verify --deep --strict "$app"

submission="$signing_dir/SpaceMark.zip"
ditto -c -k --sequesterRsrc --keepParent "$app" "$submission"
if ! xcrun notarytool submit "$submission" --apple-id "$APPLE_ID" --team-id "$APPLE_TEAM_ID" \
    --password "$APPLE_APP_SPECIFIC_PASSWORD" --wait --timeout 20m --output-format json > "$signing_dir/result.json" ||
    ! jq -e '.status == "Accepted"' "$signing_dir/result.json" >/dev/null; then
    cat "$signing_dir/result.json"
    echo "::error::Apple did not accept the notarization submission."
    exit 1
fi

xcrun stapler staple "$app"
xcrun stapler validate "$app"
codesign --verify --deep --strict "$app"
