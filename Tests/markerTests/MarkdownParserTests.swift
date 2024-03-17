// Tests for parser of markdown language.

import Testing

@testable import marker

@Suite("MarkdownParserTests")
struct MarkdownParserTests {
    @Test
    func empty() {
        var parser = MarkdownParser(contents: "")

        let result = parser.parse()
        
        #expect(result == []) 
    }

    @Test
    func simpleParagraph() {
        var parser = MarkdownParser(contents: "This is simple paragraph of text.")

        let result = parser.parse()
        
        let expected: [Block] = [
            .p(components: [
                .text("This is simple paragraph of text.", style: .regular)
            ])
        ]
        #expect(result == expected) 
    }

    func multipleParagraphs() {
        var parser = MarkdownParser(contents: "This is a paragraph.\n\nAnd this is another one.")

        let result = parser.parse()
        
        let expected: [Block] = [
            .p(components: [
                .text("This is a paragraph.", style: .regular),
            ]),
            .p(components: [
                .text("And this is another one.", style: .regular),
            ])
        ]
        #expect(result == expected) 
    }

    @Test
    func multipleParagraphsAndHeaderParagraphs() {
        var parser = MarkdownParser(contents:
        """
        This is a paragraph. 
        Still the same paragraph.

        And this is another one.
        # And this is a header paragraph
        ### This one as well
        Paragraph after header.
        """)

        let result = parser.parse()
        print(result)
        
        let expected: [Block] = [
            .p(components: [.text("This is a paragraph. Still the same paragraph.", style: .regular)]),
            .p(components: [.text("And this is another one.", style: .regular)]),
            .h1(.p(components: [.text("And this is a header paragraph", style: .regular)])),
            .h3(.p(components: [.text("This one as well", style: .regular)])),
            .p(components: [.text("Paragraph after header.", style: .regular)]),
        ]
        #expect(result == expected) 
    }
}
