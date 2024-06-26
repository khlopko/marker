public struct HTMLRenderer {
    private let markdown: Markdown

    public init(markdown: Markdown) {
        self.markdown = markdown
    }
    
    public func render() -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>\(markdown.title)</title>
            <style>
                body {
                    font-family: sans-serif;
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
                h1, h2, h3, h4, h5, h6 {
                    color: black;
                }
                h1 {
                    font-size: 2.5rem;
                }
                h2 {
                    font-size: 2rem;
                }
                h3 {
                    font-size: 1.75rem;
                }
                h4 {
                    font-size: 1.5rem;
                }
                h5 {
                    font-size: 1.25rem;
                }
                h6 {
                    font-size: 1rem;
                }
                p {
                    color: black;
                }
                pre {
                    background-color: #f4f4f4;
                    padding: 10px;
                    border-radius: 5px;
                }
            </style>
        </head>
        <body>
            \(markdown.blocks.map { render($0) }.joined(separator: "\n"))
        </body>
        </html>
        """
    }

    private func render(_ block: Block) -> String {
        switch block {
        case let .p(text):
            "<p>\(text.map { render($0) }.joined())</p>"
        case let .text(value, style):
            render(text: value, style: style)
        case let .list(blocks):
            "<ul>\(blocks.map { "<li>\(render($0))</li>" }.joined())</ul>"
        case let .code(value, info):
            render(code: value, lang: info.lang)
        case let .h(level, blocks):
            "<h\(level.rawValue)>\(blocks.map { render($0) }.joined())</h\(level.rawValue)>"
        }
    }

    private func render(text: String, style: TextStyle) -> String {
        var value = text
        for i in value.indices {
            var newValue: String?
            if value[i] == "<" {
                newValue = "&lt;"
            } else if value[i] == ">" {
                newValue = "&gt;"
            }
            if let newValue {
                value.remove(at: i)
                value.insert(contentsOf: newValue, at: i)
            }
        }
        return "<span class=\"\(style)\">\(value)</span>"
    }

    private func render(code: String, lang: String?) -> String {
        let className = lang.map { " class=\"language-\($0)\"" } ?? ""
        return "<pre><code\(className)>\(code)</code></pre>"
    }
}
