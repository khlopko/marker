//  Markdown lexer implementation
//  (c) Kyrylo Khlopko

internal enum MarkdownToken {
    case newline
    case line(String)
    case header(HeaderLevel)
}

internal struct Lexer {
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

