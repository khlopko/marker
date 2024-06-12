//  Markdown lexer implementation
//  (c) Kyrylo Khlopko

internal enum MarkdownToken {
    case newline
    case line(String)
    case list
    case header(HeaderLevel)
    case codeBlock(lang: String?)

    var rawValue: String {
        switch self {
        case .newline:
            return "\n"
        case let .line(value):
            return value
        case .list:
            return "_"
        case let .header(level):
            return Array(repeating: "#", count: level.rawValue).joined()
        case let .codeBlock(lang):
            return "```\(lang ?? "")"
        }
    }
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
        case "-":
            lastPos += 1
            return .list
        case "`":
            // consume 3 backticks
            let start = lastPos
            while lastPos < contents.count && lastPos - start < 3 && contents[lastPos] == "`" {
                lastPos += 1
            }
            var lang: String? = nil
            /*
            while lastPos < contents.count && (contents[lastPos] != "\n" || contents[lastPos] != " ") {
                lastPos += 1
            }
            lang = String(contents[start + 3..<lastPos])
            print(lastPos, lang)
            */
            return .codeBlock(lang: lang)
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

