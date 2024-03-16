
@main
struct App {
    static func main() throws {
        let md = try Markdown(path: "README.md")
        print(md)
    }
}

