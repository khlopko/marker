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
    @Argument
    var inputFilePath: String
    
    mutating func run() throws {
        let file = fopen(inputFilePath, "r")
        defer { fclose(file) }
        var contents = ""
        var buf = Array(repeating: CChar(0), count: 1024)
        while fgets(&buf, Int32(1024), file) != nil {
            if let chunk = String(validatingUTF8: buf) {
                contents += chunk
            }
        }
        let md = try Markdown(contents: contents)
        print(md)
    }
}

