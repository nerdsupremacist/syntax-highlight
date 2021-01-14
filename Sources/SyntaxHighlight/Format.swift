
import Foundation
import Syntax

protocol Format {
    associatedtype Output

    func hasStyling(kind: Kind?, annotations: [String : Any]) -> Bool

    func add(_ text: Substring)
    func add(_ text: Substring, kind: Kind?, annotations: [String : Any])
    func build() -> Output
}
