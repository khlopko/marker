// Marker CLI entry point.
// (c) Kyrylo Khlopko

#if canImport(Darwin)
    import Darwin
#else
    import Glibc
#endif

import ArgumentParser

import DotMd

@main
struct Cli: ParsableCommand {
    enum InputFormat: String, ExpressibleByArgument {
        case file
        case text
    }

    @Option(name: .shortAndLong)
    var inputFormat: InputFormat = .file

    @Argument
    var inputFilePath: String

    enum OutputFormat: String, ExpressibleByArgument {
        case html
        case raw
    }

    @Option(name: .shortAndLong)
    var outputFormat: OutputFormat = .raw

    @Flag
    var debug: Bool = false

    mutating func run() throws {
        let md: Markdown
        switch inputFormat {
        case .file:
            let file = fopen(inputFilePath, "r")
            defer { fclose(file) }
            var contents = ""
            var buf = Array(repeating: CChar(0), count: 1024)
            while fgets(&buf, Int32(1024), file) != nil {
                if let chunk = String(validatingUTF8: buf) {
                    contents += chunk
                }
            }
            let pathComponents = inputFilePath.split(separator: "/")
            let title = String(pathComponents.last!)
            md = try Markdown(title: title, contents: contents)
        case .text:
            md = try Markdown(title: "Markdown", contents: inputFilePath)
        }
        if debug {
            print(md.debugDescription)
        } else {
            switch outputFormat {
            case .html:
                let renderer = HTMLRenderer(markdown: md)
                print(renderer.render(parameters: [/*.fullHTML, .withStyles*/]))
            case .raw:
                print(md.description)
            }
        }
    }
}

