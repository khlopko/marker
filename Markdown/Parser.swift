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
            if case .line = tok {
                // do nothing
            } else {
                checkParagraph()
            }
            switch tok {
            case .newline:
                break
            case let .line(value):
                parseLine(value: value)
            case let .header(level):
                parseHeader(level: level)
            case .list:
                parseList()
            case let .codeBlock(info):
                parseCodeBlock(info: info)
            case .quote:
                var components: [Block] = []
                while case let .line(value) = lexer.nextTok() {
                    components.append(.text(value, .regular))
                    lexer.nextTok() // new line
                    guard case .quote = lexer.nextTok() else {
                        break
                    }
                }
                blocks.append(.quote(components))
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
        var components: [Block] = []
        if case let .line(value) = nextTok {
            components.append(.text(value, .regular))
        }
        blocks.append(.h(level, components))
    }

    private mutating func parseList() {
        var items: [Block] = []
        var consequentiveLines = 0
        while consequentiveLines < 2, let tok = lexer.nextTok() {
            switch tok {
            case .list:
                consequentiveLines = 0
            case let .line(value):
                items.append(.p([.text(value, .regular)]))
            default:
                consequentiveLines += 1
            }
        }
        blocks.append(.list(items))
    }

    private mutating func parseCodeBlock(info: CodeBlockInfo) {
        var value = ""
        while let tok = lexer.nextTok(eatWhitespaces: false) {
            switch tok {
            case .codeBlock:
                var i = value.startIndex
                while i < value.endIndex && value[i] == "\n" {
                    value.removeFirst()
                    i = value.startIndex
                }
                if !value.isEmpty {
                    i = value.index(before: value.endIndex)
                    while i >= value.startIndex && value[i] == "\n" {
                        value.removeLast()
                        i = value.index(before: value.endIndex) 
                    }
                }
                blocks.append(.code(value, info))
                return
            default:
                value += tok.rawValue
            }
        }
        blocks.append(.code(value, info))
    }

    private mutating func checkParagraph() {
        if readingParagraph {
            blocks.append(.p([.text(paragraphValue, .regular)]))
            readingParagraph = false
        }
    }
}

