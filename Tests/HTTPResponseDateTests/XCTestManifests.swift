import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
	return [
		testCase(HTTPResponseDateTests.allTests),
	]
}
#endif
