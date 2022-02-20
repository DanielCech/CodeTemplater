import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        return [
            testCase(Scene_ViewController_RxSwift_TableViewTests.allTests)
        ]
    }
#endif
