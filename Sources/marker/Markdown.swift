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

    mutating func parse() -> [Block] {
        var blocks: [Block] = []
        while let tok = lexer.nextTok() {
            switch tok {
            case let .paragraph(value):
                blocks.append(.p(components: [.text(value, style: .regular)]))
            case let .header(level, value):
                blocks.append(parseHeader(level: level, value: value))
            }
        }
        return blocks
    }

    private func parseHeader(level: MarkdownLexer.Token.HeaderLevel, value: String) -> Block {
        switch level {
        case .h1: return .h1(.text(value, style: .regular))
        case .h2: return .h2(.text(value, style: .regular))
        case .h3: return .h3(.text(value, style: .regular))
        case .h4: return .h4(.text(value, style: .regular))
        case .h5: return .h5(.text(value, style: .regular))
        case .h6: return .h6(.text(value, style: .regular))
        }
    }
}

struct MarkdownLexer {
    enum Token {
        case paragraph(String)
        case header(level: HeaderLevel, String)
        
        enum HeaderLevel: Int {
            case h1 = 1
            case h2 = 2
            case h3 = 3
            case h4 = 4
            case h5 = 5
            case h6 = 6
        }
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
        while lastPos < contents.count {
            switch contents[lastPos] {
            case "#":
                return parseHeader(start: start)
            case "\n": 
                guard let token = parseParagraph(start: start) else {
                    fallthrough
                }
                return token
            default: 
                lastPos += 1
            }
        }
        return .paragraph(String(contents[start..<lastPos]))
    }

    private mutating func parseHeader(start: Int) -> Token {
        lastPos += 1
        var level = 1
        while lastPos < contents.count && contents[lastPos] == "#" && level < 7 {
            level += 1
            lastPos += 1
        }
        let h = Token.HeaderLevel(rawValue: level)!
        while lastPos < contents.count && contents[lastPos] != "\n" {
            lastPos += 1
        }
        let token: Token = .header(level: h, String(contents[start..<lastPos]))
        lastPos += 1
        return token
    }

    private mutating func parseParagraph(start: Int) -> Token? {
        guard lastPos + 1 < contents.count else {
            return nil
        }
        lastPos += 1
        switch contents[lastPos] {
        case "\n", "#": 
            let token: Token = .paragraph(String(contents[start..<lastPos - 1]))
            if contents[lastPos] == "\n" {
                lastPos += 1
            }
            return token
        default: 
            return nil
        }
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

