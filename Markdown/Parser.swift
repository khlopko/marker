//  Markdown parser implementation
//  (c) Kyrylo Khlopko

internal struct Parser {
    private var lexer: Lexer

    init(contents: String) {
        lexer = Lexer(contents: contents)
    }

    init(contents: [Character]) {
        lexer = Lexer(contents: contents)
    }

    private var blocks: [Block] = []
    private var paragraphValue: String = ""
    private var readingParagraph = false

    mutating func parse() -> [Block] {
        setup()
        while let tok = lexer.nextTok() {
            switch tok {
            case .newline:
                checkParagraph()
            case let .line(value):
                parseLine(value: value)
            case let .header(level):
                checkParagraph()
                parseHeader(level: level)
            }
        }
        checkParagraph()
        return blocks
    }

    private mutating func setup() {
        blocks = []
        paragraphValue = ""
        readingParagraph = false
    }

    private mutating func parseLine(value: String) {
        if readingParagraph {
            paragraphValue += "\n"
            paragraphValue += value
        } else {
            readingParagraph = true
            paragraphValue = value
        }
        _ = lexer.nextTok() // consume newline
    }

    private mutating func parseHeader(level: HeaderLevel) {
        let nextTok = lexer.nextTok()
        var headerValue: Block = .p([.text("", .regular)])
        if case let .line(value) = nextTok {
            headerValue = .p([.text(value, .regular)])
        }
        blocks.append(.h(level, headerValue))
        _ = lexer.nextTok() // consume newline
    }

    private mutating func checkParagraph() {
        if readingParagraph {
            blocks.append(.p([.text(paragraphValue, .regular)]))
            readingParagraph = false
        }
    }
}
