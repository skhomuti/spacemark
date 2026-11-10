import Foundation
import cmark_gfm
import cmark_gfm_extensions

enum MarkdownHTML {
    private enum RenderError: Error {
        case parserUnavailable
        case renderingFailed
    }

    private static let registerExtensions: Void = cmark_gfm_core_extensions_ensure_registered()

    static func render(_ markdown: Data) throws -> Data {
        _ = registerExtensions
        let options = CMARK_OPT_VALIDATE_UTF8
        guard let parser = cmark_parser_new(options) else { throw RenderError.parserUnavailable }
        defer { cmark_parser_free(parser) }

        guard let table = cmark_find_syntax_extension("table"),
              cmark_parser_attach_syntax_extension(parser, table) != 0 else {
            throw RenderError.parserUnavailable
        }

        markdown.withUnsafeBytes { bytes in
            if let start = bytes.bindMemory(to: CChar.self).baseAddress {
                cmark_parser_feed(parser, start, bytes.count)
            }
        }
        guard let document = cmark_parser_finish(parser) else { throw RenderError.renderingFailed }
        defer { cmark_node_free(document) }

        // The safe renderer suppresses raw HTML. The page policy also blocks resource loads.
        guard let html = cmark_render_html(document, options, cmark_parser_get_syntax_extensions(parser)) else {
            throw RenderError.renderingFailed
        }
        defer { free(html) }

        return Data("""
        <!doctype html>
        <html>
        <head>
        <meta charset="utf-8">
        <meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'; base-uri 'none'; form-action 'none'">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
        :root {
            color-scheme: light dark;
            --ink: light-dark(#24262a, #e6e8eb);
            --paper: light-dark(#fff, #1c1c1e);
            --muted: light-dark(#555b64, #b3bac4);
            --rule: light-dark(#d4d8de, #46494f);
            --surface: light-dark(#f3f5f7, #2a2c30);
            --link: light-dark(#0059b3, #85baff);
            background: var(--paper);
            color: var(--ink);
        }
        body {
            box-sizing: border-box;
            max-width: 78ch;
            margin: 0 auto;
            padding: 28px clamp(16px, 5vw, 44px);
            font: 16px/1.6 -apple-system, sans-serif;
            overflow-wrap: anywhere;
        }
        h1, h2, h3, h4, h5, h6 { margin: 1.25em 0 .45em; line-height: 1.25; }
        body > :first-child { margin-top: 0; }
        p, ol, ul, pre, blockquote, table { margin: 0 0 1em; }
        li > ol, li > ul { margin-bottom: 0; }
        a { color: var(--link); }
        blockquote { margin-inline: 0; padding-inline-start: 1em; border-inline-start: 3px solid var(--rule); color: var(--muted); }
        hr { border: 0; border-top: 1px solid var(--rule); margin: 1.5em 0; }
        code { font: .9em ui-monospace, monospace; background: var(--surface); border-radius: 4px; padding: .12em .3em; }
        pre { background: var(--surface); border-radius: 8px; padding: 12px 16px; overflow-x: auto; overflow-wrap: normal; tab-size: 4; }
        pre code { padding: 0; }
        table { display: block; max-width: 100%; overflow-x: auto; border-collapse: collapse; }
        th, td { border: 1px solid var(--rule); padding: .35em .7em; }
        th { background: var(--surface); }
        img { display: none; }
        </style>
        </head>
        <body>
        \(String(cString: html))
        </body>
        </html>
        """.utf8)
    }
}
