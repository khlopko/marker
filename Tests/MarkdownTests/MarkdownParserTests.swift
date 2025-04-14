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

    @Test("Example 1")
    func example1() {
        var parser = Parser(contents: "\tfoo\tbaz\t\tbim")

        let result = parser.parse()

        let expected: [Block] = [
            .code("foo\tbaz\t\tbim", .empty)
        ]
        #expect(result == expected)
    }

    @Test("Example 2")
    func example2() {
        var parser = Parser(contents: "  \tfoo\tbaz\t\tbim")

        let result = parser.parse()

        let expected: [Block] = [
            .code("foo\tbaz\t\tbim", .empty)
        ]
        #expect(result == expected)
    }

    @Test("Example 3")
    func example3() {
        var parser = Parser(contents: "    a\ta\n    ὐ\ta")

        let result = parser.parse()

        let expected: [Block] = [
            .code("a\ta\nὐ\ta", .empty)
        ]
        #expect(result == expected)
    }

    @Test("Example 4")
    func example4() {
        var parser = Parser(contents: "  - foo\n\n\tbar")

        let result = parser.parse()

        let expected: [Block] = [
            .list([
                ListElement(blocks: [
                    .p([.text("foo", .regular)]),
                    .p([.text("bar", .regular)]),
                ])
            ]),
        ]
        #expect(result == expected)
    }

    @Test("Example 5")
    func example5() {
        var parser = Parser(contents: "- foo\n\n\t\tbar\n")

        let result = parser.parse()

        let expected: [Block] = [
            .list([
                ListElement(blocks: [
                    .p([.text("foo", .regular)]),
                    .code("  bar\n", .empty),
                ])
            ]),
        ]
        #expect(result == expected)
    }

    @Test("Example 6")
    func example6() {
        var parser = Parser(contents: ">\t\tfoo\n")

        let result = parser.parse()

        let expected: [Block] = [
            .quote([.code("  foo\n", .empty)]),
        ]
        #expect(result == expected)
    }

    @Test("Example 8")
    func example8() {
        var parser = Parser(contents: "    foo\n\tbar\n")

        let result = parser.parse()

        let expected: [Block] = [
            .code("foo\nbar\n", .empty),
        ]
        #expect(result == expected)
    }

    @Test("Example 9")
    func example9() {
        var parser = Parser(contents: " - foo\n   - bar\n\t - baz")

        let result = parser.parse()

        let expected: [Block] = [
            .list([
                ListElement(blocks: [
                    .text("foo", .regular),
                    .list([
                        ListElement(blocks:  [
                            .text("bar", .regular),
                            .list([
                                ListElement(blocks: [
                                    .text("baz", .regular)
                                ])
                            ])
                        ])
                    ])
                ]),
            ])
        ]

/*
        print("ACTUAL:")
        
        let md1 = try! Markdown(title: "Example 9 -> Result", contents: " - foo\n   - bar\n\t - baz")
        let renderer = HTMLRenderer(markdown: md1)
        print(renderer.render(parameters: []))

        print("EXPECTED:")

        let md2 = Markdown(title: "Example 9 -> Expectation", blocks: expected)
        let renderer2 = HTMLRenderer(markdown: md2)
        print(renderer2.render(parameters: []))
*/

        #expect(result == expected)
    }

    @Test("Example 10")
    func example10() {
        var parser = Parser(contents: "#\tFoo")

        let result = parser.parse()

        let expected: [Block] = [
            .h(.h1, [.text("Foo", .regular)])
        ]
        #expect(result == expected)
    }
}
