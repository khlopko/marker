// Parsed markdown representation
//  (c) Kyrylo Khlopko

public struct Markdown {
    public let blocks: [Block]

    public init(contents: String) throws {
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

public enum Block: Equatable {
    case p([Block])
    case text(String, TextStyle)
    indirect case h(HeaderLevel, Block)
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
        case let .h(level, block):
            return "h(\(level), \(block.debugDescription))"
        }
    }
}

public enum HeaderLevel: Int, Equatable {
    case h1 = 1
    case h2
    case h3
    case h4
    case h5
    case h6
}

public enum TextStyle: Equatable {
    case regular
}

