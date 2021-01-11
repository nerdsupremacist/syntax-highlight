import XCTest

import syntax_highlightTests

var tests = [XCTestCaseEntry]()
tests += syntax_highlightTests.allTests()
XCTMain(tests)
