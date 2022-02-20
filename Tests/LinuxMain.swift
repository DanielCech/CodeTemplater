import XCTest

import codeTemplateTests

var tests = [XCTestCaseEntry]()
tests += codeTemplateTests.allTests()
XCTMain(tests)
