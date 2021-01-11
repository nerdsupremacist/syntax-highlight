
import Foundation

protocol Format {
    associatedtype Output

    func hasStyling(kind: String?, annotations: [String : String]) -> Bool

    func add(_ text: Substring)
    func add(_ text: Substring, kind: String?, annotations: [String : String])
    func build() -> Output
}
