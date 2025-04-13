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
                    line-height: 1.5;
                    max-width: 67%;
                    margin: 0 auto;
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
                    font-size: 1.67rem;
                }
                h2 {
                    font-size: 1.5rem;
                }
                h3 {
                    font-size: 1.4rem;
                }
                h4 {
                    font-size: 1.2rem;
                }
                h5 {
                    font-size: 1.1rem;
                }
                h6 {
                    font-size: 1rem;
                }
                p {
                    color: black;
                }
                pre, blockquote {
                    background-color: #f4f4f4;
                    padding: 17px 11px;
                    border-radius: 5px;
                }
                pre {
                    margin: 21px;
                }
                blockquote {
                    margin: 21px;
                    border-left: 10px solid #e4e4e4;
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
        case let .list(elements):
            "<ul>\(elements.map { element in "<li>\(element.blocks.map(render).joined(separator: "\n"))</li>" }.joined())</ul>"
        case let .code(value, info):
            render(code: value, lang: info.lang)
        case let .quote(blocks):
            "<blockquote>\(blocks.map(render).joined(separator: " "))</blockquote>"
        case let .h(level, blocks):
            "<h\(level.rawValue)>\(blocks.map { render($0) }.joined())</h\(level.rawValue)>"
        }
    }

    private func render(text: String, style: TextStyle) -> String {
        switch style {
        case .regular:
            return "\(text.escapedForHTML())"
        }
    }

    private func render(code: String, lang: String?) -> String {
        let className = lang.map { " class=\"language-\($0)\"" } ?? ""
        return "<pre><code\(className)>\(code.escapedForHTML())</code></pre>"
    }
}
