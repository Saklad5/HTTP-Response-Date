import Foundation
import HTTPResponseDate
import XCTest

#if canImport(FoundationNetworking)
import class FoundationNetworking.HTTPURLResponse
#endif

final class HTTPResponseDateTests: XCTestCase {
	/// A set of dates along with an `HTTPURLResponse` for each supported `date` header representation of them.
	///
	/// These dates were taken from `DateFormatter`'s test cases.
	static private let testResponses: [
		Date: (rfc1123: HTTPURLResponse, rfc850: HTTPURLResponse, asctime: HTTPURLResponse)
		] = [
			504334638.0: (
				rfc1123: "Sun, 25 Dec 2016 04:57:18 GMT",
				rfc850: "Sunday, 25-Dec-16 04:57:18 GMT",
				asctime: "Sun Dec 25 04:57:18 2016"
			),
			-946771200: (
				rfc1123: "Fri, 01 Jan 1971 00:00:00 GMT",
				rfc850: "Friday, 01-Jan-71 00:00:00 GMT",
				asctime: "Fri Jan  1 00:00:00 1971"
			),
			499755438: (
				rfc1123: "Wed, 02 Nov 2016 04:57:18 GMT",
				rfc850: "Wednesday, 02-Nov-16 04:57:18 GMT",
				asctime: "Wed Nov  2 04:57:18 2016"
			),
			492411438: (
				rfc1123: "Tue, 09 Aug 2016 04:57:18 GMT",
				rfc850: "Tuesday, 09-Aug-16 04:57:18 GMT",
				asctime: "Tue Aug  9 04:57:18 2016"
			),
			487227438: (
				rfc1123: "Fri, 10 Jun 2016 04:57:18 GMT",
				rfc850: "Friday, 10-Jun-16 04:57:18 GMT",
				asctime: "Fri Jun 10 04:57:18 2016"
			),
			498977838: (
				rfc1123: "Mon, 24 Oct 2016 04:57:18 GMT",
				rfc850: "Monday, 24-Oct-16 04:57:18 GMT",
				asctime: "Mon Oct 24 04:57:18 2016"
			),
			1167609600: (
				rfc1123: "Fri, 01 Jan 2038 00:00:00 GMT",
				rfc850: "Friday, 01-Jan-38 00:00:00 GMT",
				asctime: "Fri Jan  1 00:00:00 2038"
			),
			480315438: (
				rfc1123: "Tue, 22 Mar 2016 04:57:18 GMT",
				rfc850: "Tuesday, 22-Mar-16 04:57:18 GMT",
				asctime: "Tue Mar 22 04:57:18 2016"
			),
			474267438: (
				rfc1123: "Tue, 12 Jan 2016 04:57:18 GMT",
				rfc850: "Tuesday, 12-Jan-16 04:57:18 GMT",
				asctime: "Tue Jan 12 04:57:18 2016"
			),
			-978307200: (
				rfc1123: "Thu, 01 Jan 1970 00:00:00 GMT",
				rfc850: "Thursday, 01-Jan-70 00:00:00 GMT",
				asctime: "Thu Jan  1 00:00:00 1970"
			),
			495608238: (
				rfc1123: "Thu, 15 Sep 2016 04:57:18 GMT",
				rfc850: "Thursday, 15-Sep-16 04:57:18 GMT",
				asctime: "Thu Sep 15 04:57:18 2016"
			),
			-1009843200: (
				rfc1123: "Wed, 01 Jan 1969 00:00:00 GMT",
				rfc850: "Wednesday, 01-Jan-69 00:00:00 GMT",
				asctime: "Wed Jan  1 00:00:00 1969"
			),
			477377838: (
				rfc1123: "Wed, 17 Feb 2016 04:57:18 GMT",
				rfc850: "Wednesday, 17-Feb-16 04:57:18 GMT",
				asctime: "Wed Feb 17 04:57:18 2016"
			),
			484289838: (
				rfc1123: "Sat, 07 May 2016 04:57:18 GMT",
				rfc850: "Saturday, 07-May-16 04:57:18 GMT",
				asctime: "Sat May  7 04:57:18 2016"
			),
			491547438: (
				rfc1123: "Sat, 30 Jul 2016 04:57:18 GMT",
				rfc850: "Saturday, 30-Jul-16 04:57:18 GMT",
				asctime: "Sat Jul 30 04:57:18 2016"
			),
			477964800: (
				rfc1123: "Wed, 24 Feb 2016 00:00:00 GMT",
				rfc850: "Wednesday, 24-Feb-16 00:00:00 GMT",
				asctime: "Wed Feb 24 00:00:00 2016"
			),
			481438638: (
				rfc1123: "Mon, 04 Apr 2016 04:57:18 GMT",
				rfc850: "Monday, 04-Apr-16 04:57:18 GMT",
				asctime: "Mon Apr  4 04:57:18 2016"
			),
			478051199: (
				rfc1123: "Wed, 24 Feb 2016 23:59:59 GMT",
				rfc850: "Wednesday, 24-Feb-16 23:59:59 GMT",
				asctime: "Wed Feb 24 23:59:59 2016"
			),
			]
			.reduce(into: [:]) { testResponses, entry in
				let mockResponse = { (timestamp: String) in
					HTTPURLResponse(
						url: URL(string: "example.com")!,
						statusCode: 200,
						httpVersion: "HTTP/2",
						headerFields: ["date": timestamp]
						)!
				}
				testResponses[Date(timeIntervalSinceReferenceDate: entry.key)] = (
					mockResponse(entry.value.rfc1123),
					mockResponse(entry.value.rfc850),
					mockResponse(entry.value.asctime)
				)
	}

	func testRFC1123TimestampParsing() {
		Self.testResponses.forEach { XCTAssertEqual($0.key, $0.value.rfc1123.date) }
	}

	// Since the year is truncated to two-digits, it is impossible to consistently parse the entire date from this format.
	func testRFC850TimestampParsing() throws {
		try Self.testResponses.forEach {
			let parsedDate = try XCTUnwrap($0.value.rfc850.date)

			guard $0.key != parsedDate else { return XCTAssert(true) }

			let actualDateComponents
				= Calendar.current.dateComponents(in: TimeZone(abbreviation: "GMT")!, from: $0.key)
			let parsedDateComponents = Calendar.current.dateComponents(
				in: TimeZone(abbreviation: "GMT")!,
				from: try XCTUnwrap($0.value.rfc850.date)
			)

			XCTAssertEqual(
				try XCTUnwrap(actualDateComponents.year) % 100,
				try XCTUnwrap(parsedDateComponents.year) % 100
			)
			for component in
				[Calendar.Component.weekday, .day, .month, .hour, .minute, .second, .timeZone] {
					XCTAssertEqual(
						try XCTUnwrap(actualDateComponents.value(for: component)),
						try XCTUnwrap(parsedDateComponents.value(for: component))
					)
			}
		}
	}

	func testAsctimeTimestampParsing() {
		Self.testResponses.forEach { XCTAssertEqual($0.key, $0.value.asctime.date) }
	}

	func testMalformedTimestampParsing() {
		#if canImport(FoundationNetworking) // HTTPURLResponse.init isn't present in FoundationNetworking
		XCTAssertNil(
			HTTPURLResponse(
				url: URL(string: "example.com")!,
				statusCode: 0,
				httpVersion: nil,
				headerFields: nil
				)!
				.date
		)
		#else
		XCTAssertNil(HTTPURLResponse().date)
		#endif

		XCTAssertNil(
			HTTPURLResponse(
				url: URL(string: "example.com")!,
				statusCode: 200,
				httpVersion: "HTTP/2",
				headerFields: ["date": "2047-03-23T04:57:18Z"] // ISO 8601
				)!
				.date
		)
	}
}
