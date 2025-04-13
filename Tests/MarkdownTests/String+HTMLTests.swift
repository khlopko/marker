import Testing

@testable import DotMd

@Suite("Markdown > String+HTML")
struct StringHTMLExtTests {
    @Test
    func escapeContent() {
        let input = "<h1>Foo</h1>"

        let output = input.escapedForHTML()

        #expect(output == "&lt;h1&gt;Foo&lt;/h1&gt;")
    }
}
