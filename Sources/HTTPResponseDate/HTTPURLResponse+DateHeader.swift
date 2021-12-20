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

  // Necessary for Sendable conformance without breaking compatibility
  #if swift(>=5.5) && canImport(_Concurrency)
  /// Returns a date corresponding to the given HTTP date string.
  /// - Parameter value: An HTTP-date as defined by
  /// [RFC 2616](https://tools.ietf.org/html/rfc2616#section-3.3.1).
  /// - Returns: A date parsed from the provided value, or `nil` if it is not a valid HTTP-date.
  @Sendable
  public static func date(forDateValue value: String) -> Date? {
    HTTPDate.allCases.lazy.compactMap { $0.formatter.date(from: value) }.first
  }
  #else
  /// Returns a date corresponding to the given HTTP date string.
  /// - Parameter value: An HTTP-date as defined by
  /// [RFC 2616](https://tools.ietf.org/html/rfc2616#section-3.3.1).
  /// - Returns: A date parsed from the provided value, or `nil` if it is not a valid HTTP-date.
  public static func date(forDateValue value: String) -> Date? {
    HTTPDate.allCases.lazy.compactMap { $0.formatter.date(from: value) }.first
  }
  #endif

	/// The date that the response was sent.
	/// - Note: This is parsed from the `date` header of the response according to [RFC 2616](https://tools.ietf.org/html/rfc2616#section-3.3.1).
  public var date: Date? {
    // Extract header value
    { () -> String? in
      #if canImport(FoundationNetworking) && swift(<5.3) // See https://bugs.swift.org/browse/SR-12300
      return allHeaderFields["date"] as? String
      #else
      if #available(iOS 13, macCatalyst 13, OSX 10.15, tvOS 13, watchOS 6, *) {
        return value(forHTTPHeaderField: "Date")
      } else {
        return allHeaderFields["Date"] as? String
      }
      #endif
    }()
    .flatMap(Self.date(forDateValue:))
	}
}
