<p align="center">
  <img src="App/Assets.xcassets/AppIcon.appiconset/Icon-256.png" width="112" height="112" alt="SpaceMark icon">
</p>

# SpaceMark

**Markdown on the space bar.**

Select a `.md` or `.markdown` file in Finder and press **Space** to read it with formatting. SpaceMark is a small Quick Look extension for macOS Tahoe.

- Renders headings, nested lists, links, quotes, code, and tables.
- Follows the system light or dark appearance.
- Renders locally. The preview skips embedded HTML and images and blocks external resource loads.

## Install from a release

Download `SpaceMark-<version>-macOS.zip` from [GitHub Releases](https://github.com/skhomuti/spacemark/releases) when available. Extract it, move `SpaceMark.app` to **Applications**, and open it once. The app supports Apple Silicon and Intel Macs running macOS Tahoe or later.

## Install from source

Requires **macOS 26 Tahoe or later** and **Xcode 26 or later**. Select the full Xcode installation under **Xcode → Settings → Locations → Command Line Tools**.

1. Clone this repository and run the build script from the project directory.

   ```sh
   git clone https://github.com/skhomuti/spacemark.git
   cd spacemark
   ./script/build_and_run.sh
   ```

   The first build downloads a pinned copy of cmark-gfm. The script opens the built app and prints its path.
2. Copy `SpaceMark.app` from that path to **Applications** and open the installed copy once. You can quit it with **⌘Q**. macOS starts the extension on demand.
3. If Finder shows raw Markdown, go to **System Settings → General → Login Items & Extensions → Quick Look** and enable **SpaceMark**. If another Markdown Quick Look extension is active, try disabling it in the same list.

## Releasing

Run **Build and release** from the Actions tab to verify a build and download the CI ZIP. Pushing a tag in the form `vMAJOR.MINOR.PATCH` builds that version and publishes a GitHub Release after Apple accepts the notarization.

Set these repository secrets under **Settings → Secrets and variables → Actions** before pushing a release tag.

| Secret | Value |
| --- | --- |
| `APPLE_CERTIFICATE_BASE64` | Base64 of a Developer ID Application `.p12` export containing the certificate and private key |
| `APPLE_CERTIFICATE_PASSWORD` | Password of the `.p12` export |
| `APPLE_ID` | Apple Account email used for notarization |
| `APPLE_TEAM_ID` | Apple Developer team ID |
| `APPLE_APP_SPECIFIC_PASSWORD` | App-specific password for that Apple Account |

To release the current commit, tag and push it.

```sh
git tag v0.1.0
git push origin v0.1.0
```

## License

SpaceMark is available under the [MIT License](LICENSE). The renderer uses [cmark-gfm](https://github.com/swiftlang/swift-cmark) under its [upstream licenses](Preview/cmark-gfm-LICENSE.txt). The extension bundles the upstream notices. The app icon was generated with OpenAI ImageGen.
