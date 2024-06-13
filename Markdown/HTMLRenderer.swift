public struct HTMLRenderer {
    private let markdown: Markdown

    public init(markdown: Markdown) {
        self.markdown = markdown
    }
    
    public func render() -> String {
        /*
        """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>\(markdown.title)</title>
            <style>
                body {
                    font-family: sans-serif;
                    color: #333;
                }
                .bold {
                    font-weight: bold;
                }
                .italic {
                    font-style: italic;
                }
                .underline {
                    text-decoration: underline;
                }
                pre {
                    background-color: #f4f4f4;
                    padding: 10px;
                    border-radius: 5px;
                }
            </style>
        </head>
        <body>
        */
        
            "\(markdown.blocks.map { render($0) }.joined(separator: "\n"))"
            /*
        </body>
        </html>
        """
             */
    }

    private func render(_ block: Block) -> String {
        switch block {
        case let .p(text):
            "<p>\(text.map { render($0) }.joined())</p>"
        case let .text(value, style):
            "<span class=\"\(style)\">\(value)</span>"
        case let .list(blocks):
            "<ul>\(blocks.map { "<li>\(render($0))</li>" }.joined())</ul>"
        case let .code(value, info):
            render(code: value, lang: info.lang)
        case let .h(level, blocks):
            "<h\(level.rawValue)>\(blocks.map { render($0) }.joined())</h\(level.rawValue)>"
        }
    }

    private func render(code: String, lang: String?) -> String {
        let className = lang.map { " class=\"language-\($0)\"" } ?? ""
        return "<pre><code\(className)>\(code)</code></pre>"
    }
}
