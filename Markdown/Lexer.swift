//  Markdown lexer implementation
//  (c) Kyrylo Khlopko

internal enum MarkdownToken {
    case newline
    case line(String)
    case list
    case header(HeaderLevel)
    case codeBlock(CodeBlockInfo)
    case quote
    case indent
    case whitespace(count: Int)

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
        case let .codeBlock(info):
            return "```\(info.lang ?? "") \(info.rest ?? "")"
        case .quote:
            return ">"
        case .indent:
            return "\t"
        case let .whitespace(count):
            return Array(repeating: " ", count: count).joined()
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
        case "\t":
            lastPos += 1
            return .indent
        case "\n":
            lastPos += 1
            return .newline
        case "#":
            return header(start: start)
        case "-":
            lastPos += 1
            if lastPos < contents.count && contents[lastPos] == " " {
                lastPos += 1
            }
            return .list
        case ">":
            if lastPos + 1 < contents.count && contents[lastPos + 1].isWhitespace {
                lastPos += 1 // eat whitespace
                lastPos += 1 // advance to next char
                return .quote
            }
            return line(start: start)
        case "`":
            // consume 3 backticks
            while lastPos < contents.count && lastPos - start < 3 && contents[lastPos] == "`" {
                lastPos += 1
            }
            if lastPos - start < 3 {
                fallthrough
            }
            var lang: String?
            var rest: String?
            var restStart: Int?
            while lastPos < contents.count && contents[lastPos] != "\n" {
                if contents[lastPos] == " " {
                    if restStart == nil {
                        restStart = lastPos
                    }
                    lastPos += 1
                    continue
                }
                if lang == nil {
                    lang = ""
                }
                lang! += String(contents[lastPos])
                restStart = nil
                lastPos += 1
            }
            if let restStart {
                rest = String(contents[restStart..<lastPos])
            }
            let info = CodeBlockInfo(lang: lang, rest: rest)
            return .codeBlock(info)
        case " ":
            var countOfWhitespaces = 0
            while lastPos < contents.count && contents[lastPos] == " " {
                lastPos += 1
                countOfWhitespaces += 1
            }

            return .whitespace(count: countOfWhitespaces)
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
            lastPos >= contents.count || contents[lastPos] == " " || contents[lastPos] == "\n"
        else {
            return line(start: start)
        }
        lastPos += 1
        return .header(headerLevel)
    }

    private mutating func line(start: Int) -> MarkdownToken {
        let value = consumeText(start: start)
        return .line(value)
    }

    private mutating func consumeText(start: Int) -> String {
        guard start < contents.count else {
            return String(contents[start...])
        }
        while lastPos < contents.count && contents[lastPos] != "\n" {
            lastPos += 1
        }
        let value = String(contents[start..<lastPos])
        return value
    }
}
