import Testing
@testable import DotMd

extension MarkdownParserTests {
    @Suite("Headings")
    struct Headings {
        @Test("Example 62: Simple headings")
        func simpleHeadings() {
            var parser = Parser(contents: """
            # foo
            ## foo
            ### foo
            #### foo
            ##### foo
            ###### foo
            """)

            let result = parser.parse()

            let expected: [Block] = [
                .h(.h1, [.text("foo", .regular)]),
                .h(.h2, [.text("foo", .regular)]),
                .h(.h3, [.text("foo", .regular)]),
                .h(.h4, [.text("foo", .regular)]),
                .h(.h5, [.text("foo", .regular)]),
                .h(.h6, [.text("foo", .regular)]),
            ]
            #expect(result == expected)
        }

        @Test("Example 63: Too many leading hashes")
        func tooMany() {
            var parser = Parser(contents: """
            ####### foo
            """)

            let result = parser.parse()

            #expect(result == [
                .p([.text("####### foo", .regular)]),
            ])
        }


        @Test("Example 64: Missing space after hash")
        func noSpaceAfterHash() {
            var parser = Parser(contents: """
            #5 bolt

            #hashtag
            """)

            let result = parser.parse()

            #expect(result == [
                .p([.text("#5 bolt", .regular)]),
                .p([.text("#hashtag", .regular)]),
            ])
        }

        @Test("Example 74: Not-spaces after closing sequence treat as part of the heading")
        func notOnlySpacesAfterClosingSequence() {
            var parser = Parser(contents: """
            ### foo ### b
            """)

            let result = parser.parse()

            #expect(result == [
                .h(.h3, [.text("foo ### b", .regular)]),
            ])
        }

        @Test("Example 79: Empty headers")
        func emptyHeaders() {
            var parser = Parser(contents: """
            ## 
            #
            ### ###
            """)

            let result = parser.parse()

            let expected: [Block] = [
                .h(.h2, []),
                .h(.h1, []),
                .h(.h3, []),
            ]
            #expect(result == expected)
        }
    }
}
