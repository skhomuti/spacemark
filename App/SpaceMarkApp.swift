import SwiftUI

@main
struct SpaceMarkApp: App {
    var body: some Scene {
        Window("SpaceMark", id: "instructions") {
            VStack(alignment: .leading, spacing: 10) {
                Text("SpaceMark")
                    .font(.title2.bold())
                Text("Select a .md or .markdown file in Finder and press Space.")
                Text("Enable SpaceMark in System Settings → General → Login Items & Extensions → Quick Look.")
                    .foregroundStyle(.secondary)
            }
            .padding(24)
            .frame(width: 400, alignment: .leading)
        }
        .windowResizability(.contentSize)
    }
}
