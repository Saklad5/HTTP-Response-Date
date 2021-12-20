import Foundation

#if canImport(FoundationNetworking)
import class FoundationNetworking.HTTPURLResponse
#endif

extension HTTPURLResponse {
  private enum HTTPDate: NSString, CaseIterable {
    /// RFC 1123
    case rfc1123 = "EEE, dd MMM yyyy HH:mm:ss z"

    /// RFC 850
    case rfc850 = "EEEE, dd-MMM-yy HH:mm:ss z"

    /// ANSI C's asctime() format
    case asctime = "EEE MMM d HH:mm:ss yyyy"

    private static let cache = NSCache<NSString, DateFormatter>()
    var formatter: DateFormatter {
      if let result = Self.cache.object(forKey: rawValue) {
        return result
      } else {
        let result = DateFormatter()
        result.locale = Locale(identifier: "en_US_POSIX")
        result.timeZone = TimeZone(identifier: "GMT")
        result.dateFormat = rawValue as String
        Self.cache.setObject(result, forKey: rawValue)
        return result
      }
    }
  }

	/// The date that the response was sent.
	/// - Note: This is parsed from the `date` header of the response according to [RFC 2616](https://tools.ietf.org/html/rfc2616#section-3.3.1).
	public var date: Date? {
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

    return HTTPDate.allCases.lazy.compactMap { $0.formatter.date(from: dateString) }.first
	}
}
