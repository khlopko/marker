
@main
struct App {
    static func main() throws {
        //let path = "Examples/markdown/bench.md"
        let path = "README.md"
        let md = try Markdown(path: path)
        print(md)
    }
}

