import Foundation

#if canImport(FoundationNetworking)
import class FoundationNetworking.HTTPURLResponse
#endif

public extension HTTPURLResponse {
	private static let dateFormatters = [
		// GMT is required in all timestamps, but section 19.3 of RFC 2616 requires clients to convert timestamps incorrectly given with a different time zone into GMT.

		// RFC 1123
		"EEE, dd MMM yyyy HH:mm:ss z",

		// RFC 850
		"EEEE, dd-MMM-yy HH:mm:ss z",

		// ANSI C's asctime() format
		"EEE MMM d HH:mm:ss yyyy",
		]
		.lazy // It's very unlikely that any DateFormatter beyond the first will be necessary.
		.map { formatString -> DateFormatter in
			let formatter = DateFormatter()
			formatter.locale = Locale(identifier: "en_US_POSIX")
			formatter.timeZone = TimeZone(identifier: "GMT")
			formatter.dateFormat = formatString
			return formatter
	}

	/// The date that the response was sent.
	/// - Note: This is parsed from the `date` header of the response according to [RFC 2616](https://tools.ietf.org/html/rfc2616#section-3.3.1).
	var date: Date? {
		// Servers are required to send a date header whenever possible. It isn't always possible.
		let dateValue: String?

		#if canImport(FoundationNetworking) && swift(<5.3) // See https://bugs.swift.org/browse/SR-12300
		dateValue = allHeaderFields["date"] as? String
		#else
		if #available(iOS 13, macCatalyst 13, OSX 10.15, tvOS 13, watchOS 6, *) {
			dateValue = value(forHTTPHeaderField: "date")
		} else {
			dateValue = allHeaderFields["Date"] as? String
		}
		#endif

		guard let dateString = dateValue else {
			return nil
		}

		for dateFormatter in Self.dateFormatters {
			if let date = dateFormatter.date(from: dateString) {
				return date
			}
		}

		return nil
	}
}
