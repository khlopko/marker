// Tests for parser of markdown language.

import Testing

@testable import DotMd

@Suite("Markdown > Parser Tests")
struct MarkdownParserTests {
    @Test
    func empty() {
        var parser = Parser(contents: "")

        let result = parser.parse()
        
        #expect(result == []) 
    }

    @Test
    func simpleParagraph() {
        var parser = Parser(contents: "This is simple paragraph of text.")

        let result = parser.parse()
        
        let expected: [Block] = [
            .p([.text("This is simple paragraph of text.", .regular)])
        ]
        #expect(result == expected) 
    }

    @Test
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
            .h(.h1, .p([.text("And this is a header paragraph", .regular)])),
            .h(.h3, .p([.text("This one as well", .regular)])),
            .p([.text("Paragraph after header.", .regular)]),
        ]
        #expect(result == expected) 
    }
}
