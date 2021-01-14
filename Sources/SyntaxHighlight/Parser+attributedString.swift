
import Foundation
import Syntax

extension Parser {

    public func attributedString(_ text: String, attributes: @escaping (Kind?, [String : Any]) -> [NSAttributedString.Key : Any]?) throws -> NSAttributedString {
        let format = AttributedStringFormat(attributes: attributes)
        return try highlight(text, using: format)
    }

    public func attributedString(_ text: String, attributes: @escaping (Kind?) -> [NSAttributedString.Key : Any]?) throws -> NSAttributedString {
        let format = AttributedStringFormat { kind, _ in attributes(kind) }
        return try highlight(text, using: format)
    }

}

private class AttributedStringFormat: Format {
    private let attributes: (Kind?, [String : Any]) -> [NSAttributedString.Key : Any]?
    private var string: NSMutableAttributedString

    internal init(attributes: @escaping (Kind?, [String : Any]) -> [NSAttributedString.Key : Any]?) {
        self.attributes = attributes
        self.string = NSMutableAttributedString()
    }

    func hasStyling(kind: Kind?, annotations: [String : Any]) -> Bool {
        return attributes(kind, annotations) != nil
    }

    func add(_ text: Substring) {
        string.append(NSAttributedString(string: String(text)))
    }

    func add(_ text: Substring, kind: Kind?, annotations: [String : Any]) {
        guard let attributes = attributes(kind, annotations) else {
            return add(text)
        }
        string.append(NSAttributedString(string: String(text), attributes: attributes))
    }

    func build() -> NSAttributedString {
        return NSAttributedString(attributedString: string)
    }
}
