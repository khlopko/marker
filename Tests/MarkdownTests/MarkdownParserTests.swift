// Tests for parser of markdown language.

import Testing

@testable import DotMd

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
                .p([.text("First item", .regular)]),
                .p([.text("Second item", .regular)]),
                .p([.text("Third item", .regular)]),
            ]),
            .p([.text("And text after list.", .regular)]),
        ]) 
    }

    @Test("Example 4")
    func example4() {
        var parser = Parser(contents: """
          - foo

            bar
        """)

        let result = parser.parse()

        let expected: [Block] = [
            .list([
                .p([.text("foo", .regular)]),
                .p([.text("bar", .regular)]),
            ])
        ]
        #expect(result == expected)
    }

    @Test("Example 42: Precedence")
    func listOverCodeSpan() {
        var parser = Parser(contents: """
        - `one
        - two`
        """)

        let result = parser.parse()

        let expected: [Block] = [
            .list([
                .p([.text("`one", .regular)]),
                .p([.text("two`", .regular)]),
            ])
        ]
        #expect(result == expected)
    }

    @Test("Bench markdown code block")
    func mdCodeBlockFromBench() {
        var parser = Parser(contents: """
        ``` markdown
        1. one

        2. two
        3. three
        ```
        """)

        let result = parser.parse()

        #expect(result == [
            .code("1. one\n\n2. two\n3. three", CodeBlockInfo(lang: "markdown", rest: nil))
        ])
    }

    @Test("Basic quote parsing")
    func basicQuote() {
        var parser = Parser(contents: """
        Hello!

        > This is quote
        > And this is still the same quote

        Bye?

        > Yep. Second one.

        End.
        """)

        let result = parser.parse()

        let expected: [Block] = [
            .p([.text("Hello!", .regular)]),
            .quote([.text("This is quote", .regular), .text("And this is still the same quote", .regular)]),
            .p([.text("Bye?", .regular)]),
            .quote([.text("Yep. Second one.", .regular)]),
            .p([.text("End.", .regular)]),
        ]
        #expect(result == expected)
    }
}
