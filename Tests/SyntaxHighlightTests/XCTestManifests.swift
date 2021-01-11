import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(syntax_highlightTests.allTests),
    ]
}
#endif
