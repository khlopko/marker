// Markdown.swift

import Foundation 

struct Markdown {
    let blocks: [Block]

    init(path: String) throws {
        let contents = try String(contentsOfFile: path)
        var parser = MarkdownParser(contents: Array(contents))
        self.blocks = parser.parse()
    }
}

struct MarkdownParser {
    private var lexer: MarkdownLexer

    init(contents: String) {
        lexer = MarkdownLexer(contents: contents)
    }

    init(contents: [Character]) {
        lexer = MarkdownLexer(contents: contents)
    }

    private var blocks: [Block] = []
    private var paragraphValue: String = ""
    private var readingParagraph = false

    mutating func parse() -> [Block] {
        blocks = []
        paragraphValue = ""
        readingParagraph = false
        while let tok = lexer.nextTok() {
            switch tok {
            case .newline:
                checkParagraph()
            case let .line(value):
                if readingParagraph {
                    paragraphValue += value
                } else {
                    readingParagraph = true
                    paragraphValue = value
                }
                _ = lexer.nextTok() // consume newline
            case let .header(level):
                checkParagraph()
                let nextTok = lexer.nextTok()
                var headerValue: Block = .p(components: [.text("", style: .regular)])
                if case let .line(value) = nextTok {
                    headerValue = .p(components: [.text(value, style: .regular)])
                }
                switch level {
                case 1: blocks.append(.h1(headerValue))
                case 2: blocks.append(.h2(headerValue))
                case 3: blocks.append(.h3(headerValue))
                case 4: blocks.append(.h4(headerValue))
                case 5: blocks.append(.h5(headerValue))
                case 6: blocks.append(.h6(headerValue))
                default: break
                }
                _ = lexer.nextTok() // consume newline
            }
        }
        checkParagraph()
        return blocks
    }

    private mutating func checkParagraph() {
        if readingParagraph {
            blocks.append(.p(components: [.text(paragraphValue, style: .regular)]))
            readingParagraph = false
        }
    }
}

struct MarkdownLexer {
    enum Token {
        case newline
        case line(String)
        case header(level: Int)
    }

    private let contents: [Character]
    private(set) var lastPos = 0

    init(contents: String) {
        self.contents = Array(contents)
    }

    init(contents: [Character]) {
        self.contents = contents
    }

    mutating func nextTok() -> Token? {
        guard lastPos < contents.count else {
            return nil
        }
        let start = lastPos
        switch contents[lastPos] {
        case "\n":
            lastPos += 1
            return .newline
        case "#":
            return header(start: start)
        default: 
            return line(start: start)
        }
    }

    private mutating func header(start: Int) -> Token {
        var level = 0
        while lastPos < contents.count && contents[lastPos] == "#" {
            level += 1
            lastPos += 1
        }
        guard level < 7 && contents[lastPos] == " " else {
            return line(start: start)
        }
        lastPos += 1
        return .header(level: level)
    }

    private mutating func line(start: Int) -> Token {
        guard start < contents.count else {
            return .line(String(contents[start...]))
        }
        while lastPos < contents.count && contents[lastPos] != "\n" {
            lastPos += 1
        }
        return .line(String(contents[start..<lastPos]))
    }
}

enum Block: Equatable {
    indirect case h1(Block)
    indirect case h2(Block)
    indirect case h3(Block)
    indirect case h4(Block)
    indirect case h5(Block)
    indirect case h6(Block)
    case p(components: [Block])
    case text(String, style: TextStyle)
}

enum TextStyle: Equatable {
    case regular
}

