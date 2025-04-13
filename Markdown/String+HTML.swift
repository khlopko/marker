//  (c) Kyrylo Khlopko

private let htmlEspaceMap: [Character: String] = [
    "<": "&lt;",
    ">": "&gt;",
]

extension String {
    func escapedForHTML() -> String {
        var escapedHTML = ""
        for char in self {
            if let replacementSeq = htmlEspaceMap[char] {
                escapedHTML.append(replacementSeq)
            } else {
                escapedHTML.append(char)
            }
        }
        return escapedHTML
    }
}
