
import Foundation
import SyntaxTree

public enum TokenType: Hashable, ExpressibleByStringLiteral {
    /// A keyword, such as `if`, `class`, `let` or attributes such as @available
    case keyword
    /// A token that is part of a string literal
    case string
    /// A reference to a type
    case type
    /// A call to a function or method
    case call
    /// A number, either interger of floating point
    case number
    /// A comment, either single or multi-line
    case comment
    /// A property being accessed, such as `object.property`
    case property
    /// A symbol being accessed through dot notation, such as `.myCase`
    case dotAccess
    /// A preprocessing symbol, such as `#if`
    case preprocessing
    /// A custom token type, containing an arbitrary string
    case custom(String)

    public init(stringLiteral value: String) {
        self = .custom(value)
    }
}

extension SyntaxTreeFactory {

    public func html(_ text: String, type: @escaping (Kind?, [String : Any]) -> TokenType?) throws -> String {
        let html = HTMLFormat(type: type)
        return try highlight(text, using: html)
    }

    public func html(_ text: String, type: @escaping (Kind?) -> TokenType?) throws -> String {
        let html = HTMLFormat { kind, _ in type(kind) }
        return try highlight(text, using: html)
    }

}

extension TokenType {
    var string: String {
        if case .custom(let type) = self {
            return type
        }

        return "\(self)"
    }
}

private class HTMLFormat: Format {
    private let type: (Kind?, [String : Any]) -> TokenType?
    private var html = ""

    internal init(type: @escaping (Kind?, [String : Any]) -> TokenType?) {
        self.type = type
    }

    func hasStyling(kind: Kind?, annotations: [String : Any]) -> Bool {
        return type(kind, annotations) != nil
    }

    func add(_ text: Substring) {
        html.append(String(text).escapingHTMLEntities())
    }

    func add(_ text: Substring, kind: Kind?, annotations: [String : Any]) {
        guard let type = type(kind, annotations) else {
            return add(text)
        }

        let (prefix, withoutPrefix) = text.splitPrefix(of: .whitespacesAndNewlines)
        let (postfix, final) = withoutPrefix.splitPostfix(of: .whitespacesAndNewlines)

        if !prefix.isEmpty {
            add(prefix)
        }

        html.append("<span class=\"\(type.string)\">\(final.escapingHTMLEntities())</span>")

        if !postfix.isEmpty {
            add(prefix)
        }
    }

    func build() -> String {
        return html
    }
}

extension Substring {

    fileprivate func splitPrefix(of characterSet: CharacterSet) -> (prefix: Substring, new: Substring) {
        let index = firstIndex { !$0.unicodeScalars.allSatisfy { characterSet.contains($0) } } ?? startIndex

        return (
            self[startIndex..<index],
            self[index...]
        )
    }

    fileprivate func splitPostfix(of characterSet: CharacterSet) -> (postfix: Substring, new: Substring) {
        let index = lastIndex { !$0.unicodeScalars.allSatisfy { characterSet.contains($0) } } ?? endIndex

        return (
            self[index...],
            self[startIndex..<index]
        )
    }

}

extension StringProtocol {
    fileprivate func escapingHTMLEntities() -> String {
        return String(flatMap { character -> String in
            switch character {
            case "&":
                return "&amp;"
            case "<":
                return "&lt;"
            case ">":
                return "&gt;"
            default:
                return String(character)
            }
        })
    }
}
