//  Parsed markdown representation
//  (c) Kyrylo Khlopko

public struct Markdown {
    public let title: String
    public let blocks: [Block]

    public init(title: String, contents: String) throws {
        self.title = title
        var parser = Parser(contents: Array(contents))
        self.blocks = parser.parse()
    }
}

extension Markdown: CustomStringConvertible {
    public var description: String {
        blocks.map(\.description).joined(separator: "\n")
    }
}

extension Markdown: CustomDebugStringConvertible {
    public var debugDescription: String {
        blocks.map(\.debugDescription).joined(separator: "\n")
    }
}

public enum Block: Equatable, Sendable {
    case p([Block])
    case text(String, TextStyle)
    case list([Block])
    case code(String, CodeBlockInfo)
    indirect case h(HeaderLevel, [Block])
}

extension Block: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .p(blocks):
            return blocks.map { block in
                block.description
            }.joined(separator: "") + "\n"
        case let .text(value, _):
            return value
        case let .list(blocks):
            return blocks.map { block in
                block.description
            }.joined(separator: "") + "\n"
        case let .code(value, _):
            return "```\n\(value)\n```"
        case let .h(level, block):
            return "\(String(Array(repeating: "#", count: level.rawValue))) \(block.description)"
        }
    }
}

extension Block: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .p(blocks):
            return "p(\(blocks.map(\.debugDescription).joined(separator: ", ")))"
        case let .text(value, style):
            return "text(\(value), \(style))"
        case let .list(blocks):
            return "list(\(blocks.map(\.debugDescription).joined(separator: ", ")))"
        case let .code(value, info):
            var prefix: String = [info.lang, info.rest].compactMap {
                $0?.description
            }.joined(separator: "")
            if !prefix.isEmpty {
                prefix = "[\(prefix)]"
            }
            return "code\(prefix)(\(value))"
        case let .h(level, block):
            return "h(\(level), \(block.debugDescription))"
        }
    }
}

public enum HeaderLevel: Int, Equatable, Sendable {
    case h1 = 1
    case h2
    case h3
    case h4
    case h5
    case h6
}

public enum TextStyle: Equatable, Sendable {
    case regular
}

public struct CodeBlockInfo: Equatable, Sendable {
    public let lang: String?
    public let rest: String?
}

