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
            case let .whitespace(count):
                if count == 4 {
                    parseCodeBlock(info: .empty)
                } else {
                    continue
                }
            case .indent:
                parseCodeBlock(info: .empty)
            case let .line(value):
                parseLine(value: value)
            case let .header(level):
                parseHeader(level: level)
            case .list:
                let elements = parseList()
                blocks.append(.list(elements))
            case let .codeBlock(info):
                parseCodeBlock(info: info)
            case .quote:
                parseQuote()
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
        _ = lexer.nextTok()  // consume newline
    }

    private mutating func parseHeader(level: HeaderLevel) {
        var value: String = ""

        outer: while let tok = lexer.nextTok() {
            switch tok {
            case .indent, .whitespace:
                continue
            case let .line(lineValue):
                value += lineValue
            case .newline, .header:
                break outer
            default:
                assertionFailure("unexpected token in header: \(tok)")
            }
        }

        var components: [Block] = []
        if !value.isEmpty {
            components.append(.text(value, .regular))
        }
        blocks.append(.h(level, components))
    }

    private mutating func parseList() -> [ListElement] {
        var elements: [ListElement] = []
        var elementBlocks: [Block] = []

        var indentLevel: Int = 0
        var leftovers: String = ""

        while let tok: MarkdownToken = lexer.nextTok() {
            switch tok {
            case .list:
                if indentLevel > 0 {
                    elementBlocks.append(.list(parseList()))
                }
                elements.append(ListElement(blocks: elementBlocks))
                elementBlocks = []
                indentLevel = 0
            case let .line(value):
                if indentLevel > 0 {
                    for i in elementBlocks.indices {
                        if case .text = elementBlocks[i] {
                            elementBlocks[i] = .p([elementBlocks[i]])
                        }
                    }
                }

                if indentLevel > 1 {
                    let value = leftovers + value + "\n"
                    elementBlocks.append(.code(value, .empty))
                } else if indentLevel > 0 {
                    elementBlocks.append(.p([.text(value, .regular)]))
                } else {
                    elementBlocks.append(.text(value, .regular))
                }
                leftovers = ""
                indentLevel = 0
            case let .whitespace(count):
                if indentLevel == 0 && count >= 2 {
                    indentLevel += 1
                    leftovers += Array(repeating: " ", count: count - 2).joined()
                } else if count == 4 {
                    indentLevel += 1
                }
            case .indent:
                if indentLevel == 0 {
                    indentLevel += 1
                    leftovers += Array(repeating: " ", count: 2).joined()
                } else {
                    indentLevel += 1
                }
            default:
                indentLevel = 0
            }
        }

        if !elementBlocks.isEmpty {
            elements.append(ListElement(blocks: elementBlocks))
        }
        return elements
    }

    private mutating func parseQuote() {
        var components: [Block] = []

        var indentLevel: Int = 0
        var leftovers: String = ""
        var expectQuote: Bool = false

        while let tok = lexer.nextTok() {
            if expectQuote {
                if case .quote = tok {
                    expectQuote = false
                    continue
                } else {
                    break
                }
            }

            switch tok {
            case let .line(value):
                if indentLevel > 0 {
                    let value = leftovers + value + "\n"
                    components.append(.code(value, .empty))
                } else {
                    components.append(.p([.text(value, .regular)]))
                }
                leftovers = ""
                indentLevel = 0
            case let .whitespace(count):
                if indentLevel == 0 && count >= 2 {
                    indentLevel += 1
                    leftovers += Array(repeating: " ", count: count - 2).joined()
                } else if count == 4 {
                    indentLevel += 1
                }
            case .indent:
                if indentLevel == 0 {
                    indentLevel += 1
                    leftovers += Array(repeating: " ", count: 2).joined()
                } else {
                    indentLevel += 1
                }
            case .newline:
                expectQuote = true
            default:
                indentLevel = 0
            }
        }

        blocks.append(.quote(components))
    }

    private mutating func parseCodeBlock(info: CodeBlockInfo) {
        var value = ""
        while let tok = lexer.nextTok() {
            switch tok {
            case .codeBlock, .indent:
                continue
            case let .whitespace(count):
                if count == 4 {
                    continue
                }
                fallthrough
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
