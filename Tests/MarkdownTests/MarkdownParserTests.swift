// Tests for parser of markdown language.

import Testing

@testable import DotMd

extension Block: CustomTestStringConvertible {
    public var testDescription: String {
        description
    }
}

@Suite("Markdown > Parser Tests")
struct MarkdownParserTests {
    @Test("Empty input")
    func empty() {
        var parser = Parser(contents: "")

        let result = parser.parse()
        
        #expect(result == []) 
    }

    @Test("Just one simple paragraph")
    func simpleParagraph() {
        var parser = Parser(contents: "This is simple paragraph of text.")

        let result = parser.parse()
        
        let expected: [Block] = [
            .p([.text("This is simple paragraph of text.", .regular)])
        ]
        #expect(result == expected) 
    }

    @Test("Multiple paragraphs and headers intermixed")
    func multipleParagraphsAndHeaderParagraphs() {
        var parser = Parser(contents:
        """
        This is a paragraph.
        Still the same paragraph.

        And this is another one.
        # And this is a header paragraph
        ### This one as well
        Paragraph after header.
        """)

        let result = parser.parse()
        
        let expected: [Block] = [
            .p([.text("This is a paragraph.\nStill the same paragraph.", .regular)]),
            .p([.text("And this is another one.", .regular)]),
            .h(.h1, [.text("And this is a header paragraph", .regular)]),
            .h(.h3, [.text("This one as well", .regular)]),
            .p([.text("Paragraph after header.", .regular)]),
        ]
        #expect(result == expected) 
    }

    @Test("Parse a simple list")
    func lists() {
        var parser = Parser(contents: """
        Here is a list:
        - First item
        - Second item
        - Third item

        And text after list.
        """)

        let result = parser.parse()
        
        #expect(result == [
            .p([.text("Here is a list:", .regular)]),
            .list([
                .text("First item", .regular),
                .text("Second item", .regular),
                .text("Third item", .regular),
            ]),
            .p([.text("And text after list.", .regular)]),
        ]) 
    }

    /// Targets to cover examples from 119 to 147
    @Suite("4.5 Fenced code blocks (from CommonMark Spec)")
    struct FencedCodeBlocks {
        struct Argument: CustomTestStringConvertible {
            let name: String
            let input: String
            let expectedResult: [Block]

            var testDescription: String { name }
        }

        private static let arguments: [Argument] = [
            Argument(
                name: "Example 119: Simple fence with backticks",
                input: """
                ```
                <
                 >
                ```
                """,
                expectedResult: [
                    .code("<\n >", .init(lang: nil, rest: nil))
                ]
            ),
            Argument(
                name: "Example 121: Not enough backticks",
                input: """
                ``
                foo
                ``
                """,
                expectedResult: [
                    .p([.text("``\nfoo\n``", .regular)])
                ]
            ),
            Argument(
                name: "Example 126: Unclosed code block at the end of the document",
                input: """
                ```
                """,
                expectedResult: [.code("", .init(lang: nil, rest: nil))]
            ),
            Argument(
                name: "Example 140: Interrupt paragraphs without a blank line",
                input: """
                foo
                ```
                bar
                ```
                baz
                """,
                expectedResult: [
                    .p([.text("foo", .regular)]),
                    .code("bar", CodeBlockInfo(lang: nil, rest: nil)),
                    .p([.text("baz", .regular)]),
                ]
            ),
            Argument(
                name: "Example 142: Info string with language name",
                input: """
                ```ruby
                def foo(x)
                  return 3
                end
                ```
                """,
                expectedResult: [
                    .code("def foo(x)\n  return 3\nend", CodeBlockInfo(lang: "ruby", rest: nil))
                ]
            ),
        ]

        @Test(arguments: arguments)
        func example(argument: Argument) throws {
            var parser = Parser(contents: argument.input)

            let result = parser.parse()

            #expect(result == argument.expectedResult)
        }

        @Test("Parse the most basic code block")
        func simpleCodeBlock() {
            var parser = Parser(contents: """
            Look at the following sample code:
            ```
            let x = 5
            let y = 10
            let z = x + y
            ```
            Isn't it cool?
            """)

            let result = parser.parse()
            
            #expect(result == [
                .p([.text("Look at the following sample code:", .regular)]),
                .code("let x = 5\nlet y = 10\nlet z = x + y", CodeBlockInfo(lang: nil, rest: nil)),
                .p([.text("Isn't it cool?", .regular)]),
            ])
        }

        @Test("Carry language information within the block")
        func codeBlockWithLanguage() {
            var parser = Parser(contents: """
            Look at the following sample code:
            ``` swift
            let x = 5
            let y = 10
            let z = x + y
            ```
            Isn't it cool?
            """)

            let result = parser.parse()
            
            #expect(result == [
                .p([.text("Look at the following sample code:", .regular)]),
                .code("let x = 5\nlet y = 10\nlet z = x + y", CodeBlockInfo(lang: "swift", rest: nil)),
                .p([.text("Isn't it cool?", .regular)]),
            ])
        }
    }
}
