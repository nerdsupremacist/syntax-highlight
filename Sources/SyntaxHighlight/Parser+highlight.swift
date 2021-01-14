
import Foundation
import Syntax

extension Parser {

    func highlight<F : Format>(_ text: String, using format: F) throws -> F.Output {
        let tree = try syntaxTree(text)
        var lastIndex = text.startIndex
        tree.visit(text, using: format) { range in
            format.add(text[lastIndex..<range.lowerBound])
            lastIndex = range.upperBound
        }

        let postfix = lastIndex..<text.endIndex
        if !postfix.isEmpty {
            format.add(text[postfix])
        }

        return format.build()
    }

}

extension SyntaxTree {

    func startIndex(in text: String) -> String.Index {
        return text.index(text.startIndex, offsetBy: range.lowerBound)
    }

    func endIndex(in text: String) -> String.Index {
        return text.index(text.startIndex, offsetBy: range.upperBound)
    }

    func range(in text: String) -> Range<String.Index> {
        return startIndex(in: text)..<endIndex(in: text)
    }

    fileprivate func visit<F : Format>(_ text: String, using format: F, whenStyleChange: (Range<String.Index>) -> Void) {
        let hasStyling = format.hasStyling(kind: kind, annotations: annotations)
        if hasStyling {
            whenStyleChange(range(in: text))
        }

        guard !children.isEmpty else {
            if hasStyling {
                format.add(text[range(in: text)], kind: kind, annotations: annotations)
            }
            return
        }

        var lastIndex = startIndex(in: text)
        let whenStyleChange = hasStyling ? { range in
            guard lastIndex < range.lowerBound else { return }
            format.add(text[lastIndex..<range.lowerBound], kind: kind, annotations: annotations)
            lastIndex = range.upperBound
        } : whenStyleChange

        for child in children {
            child.visit(text, using: format, whenStyleChange: whenStyleChange)        }

        if hasStyling {
            let postfix = lastIndex..<endIndex(in: text)
            format.add(text[postfix], kind: kind, annotations: annotations)
        }
    }

}
