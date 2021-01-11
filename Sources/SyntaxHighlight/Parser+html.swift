
import Foundation
import Syntax

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

extension Parser {

    public func html(_ text: String, type: @escaping (String?, [String : String]) -> TokenType?) throws -> String {
        let html = HTMLFormat(type: type)
        return try highlight(text, using: html)
    }

    public func html(_ text: String, type: @escaping (String?) -> TokenType?) throws -> String {
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
    private let type: (String?, [String : String]) -> TokenType?
    private var html = ""

    internal init(type: @escaping (String?, [String : String]) -> TokenType?) {
        self.type = type
    }

    func hasStyling(kind: String?, annotations: [String : String]) -> Bool {
        return type(kind, annotations) != nil
    }

    func add(_ text: Substring) {
        html.append(String(text).escapingHTMLEntities())
    }

    func add(_ text: Substring, kind: String?, annotations: [String : String]) {
        guard let type = type(kind, annotations) else {
            return add(text)
        }
        html.append("<span class=\"\(type.string)\">\(text.escapingHTMLEntities())</span>")
    }

    func build() -> String {
        return html
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
