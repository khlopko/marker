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

enum Block: Equatable {
    case p([Block])
    case text(String, TextStyle)
    indirect case h(HeaderLevel, Block)
}

enum HeaderLevel: Int, Equatable {
    case h1 = 1
    case h2
    case h3
    case h4
    case h5
    case h6
}

enum TextStyle: Equatable {
    case regular
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

enum MarkdownToken {
    case newline
    case line(String)
    case header(HeaderLevel)
}

struct MarkdownLexer {
    private let contents: [Character]
    private var lastPos = 0

    init(contents: String) {
        self.contents = Array(contents)
    }

    init(contents: [Character]) {
        self.contents = contents
    }

    mutating func nextTok() -> MarkdownToken? {
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

    private mutating func header(start: Int) -> MarkdownToken {
        var level = 0
        while lastPos < contents.count && contents[lastPos] == "#" {
            level += 1
            lastPos += 1
        }
        guard 
            let headerLevel = HeaderLevel(rawValue: level),
            contents[lastPos] == " " 
        else {
            return line(start: start)
        }
        lastPos += 1
        return .header(headerLevel)
    }

    private mutating func line(start: Int) -> MarkdownToken {
        guard start < contents.count else {
            return .line(String(contents[start...]))
        }
        while lastPos < contents.count && contents[lastPos] != "\n" {
            lastPos += 1
        }
        return .line(String(contents[start..<lastPos]))
    }
}

