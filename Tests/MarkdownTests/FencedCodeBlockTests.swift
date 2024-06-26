// Fenced code blocks parsing tests

import Testing
@testable import DotMd

extension MarkdownParserTests {
    /// Targets to cover examples from 119 to 147
    @Suite("4.5 Fenced code blocks (from CommonMark Spec)")
    struct FencedCodeBlocks {
        struct Argument: CustomTestStringConvertible, Sendable {
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
