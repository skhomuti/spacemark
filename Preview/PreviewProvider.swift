import QuickLookUI
import UniformTypeIdentifiers

final class PreviewProvider: QLPreviewProvider, QLPreviewingController {
    func providePreview(for request: QLFilePreviewRequest) async throws -> QLPreviewReply {
        let url = request.fileURL
        guard ["md", "markdown"].contains(url.pathExtension.lowercased()) else {
            throw CocoaError(.fileReadUnsupportedScheme)
        }

        return QLPreviewReply(dataOfContentType: .html, contentSize: CGSize(width: 760, height: 720)) { _ in
            try MarkdownHTML.render(Data(contentsOf: url))
        }
    }
}
