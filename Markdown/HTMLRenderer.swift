public struct HTMLRenderer {
    private let markdown: Markdown

    public init(markdown: Markdown) {
        self.markdown = markdown
    }
}

extension HTMLRenderer {
    public struct Parameters: OptionSet, Sendable {
        public static let fullHTML = Parameters(rawValue: 1 << 1)
        public static let withStyles = Parameters(rawValue: 1 << 2)

        public typealias RawValue = Int

        public let rawValue: RawValue

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

extension HTMLRenderer {
    public func render(parameters: Parameters) -> String {
        var decorators: [(String) -> String] = []
        if parameters.contains(.fullHTML) {
            decorators.append(fullHTMLDecorator(parameters: parameters))
        }
        let body = markdown.blocks.map { render($0) }.joined(separator: "\n")
        var output = body
        for decorator in decorators {
            output = decorator(output)
        }
        return output
    }

    private func fullHTMLDecorator(parameters: Parameters) -> (String) -> String {
        return { body in
            var head = """
                <head>
                    <meta charset="utf-8">
                    <title>\(markdown.title)</title>
                """
            if parameters.contains(.withStyles) {
                head += defaultStyle()
                head += "\n"
            }
            head += "</head>"

            return """
                <!DOCTYPE html>
                <html>
                \(head)
                <body>
                    \(body)
                </body>
                </html>
                """
        }
    }

    private func defaultStyle() -> String {
        return """
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
        return "<span class=\"\(style)\">\(text.escapedForHTML())</span>"
    }

    private func render(code: String, lang: String?) -> String {
        let className = lang.map { " class=\"language-\($0)\"" } ?? ""
        return "<pre><code\(className)>\(code.escapedForHTML())</code></pre>"
    }
}
