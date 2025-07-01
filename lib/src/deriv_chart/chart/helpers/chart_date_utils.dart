import 'package:intl/intl.dart';

/// A utility class that provides methods for formatting dates and times in chart components.
///
/// This class contains static methods for converting timestamps (milliseconds since epoch)
/// into human-readable date and time formats. It's primarily used throughout the chart
/// components to ensure consistent date and time formatting, especially for:
/// - Crosshair time displays
/// - X-axis time labels
/// - Tooltip date information
/// - Time-based annotations
///
/// All methods in this class accept timestamps in milliseconds since epoch and
/// provide formatted strings according to specific patterns.
class ChartDateUtils {
  /// Formats a timestamp to a complete date and time string including seconds.
  ///
  /// This method converts a Unix timestamp (milliseconds since epoch) to a formatted
  /// date and time string in the format 'dd MMM yyyy HH:mm:ss'. It's commonly used
  /// in crosshair displays and tooltips where precise time information is needed.
  ///
  /// Parameters:
  /// - [timestamp]: The Unix timestamp in milliseconds since epoch to format
  /// - [isUtc]: Whether to interpret the timestamp as UTC (true) or local time (false).
  ///   Defaults to true as chart data is typically stored in UTC.
  ///
  /// Returns:
  /// A formatted string in the pattern 'dd MMM yyyy HH:mm:ss' (e.g., '01 Oct 2021 14:30:45')
  ///
  /// Example:
  /// ```dart
  /// final timestamp = 1633072800000; // 2021-10-01 00:00:00 UTC
  /// final formatted = ChartDateUtils.formatDateTimeWithSeconds(timestamp);
  /// print(formatted); // Outputs: '01 Oct 2021 00:00:00'
  /// ```
  ///
  /// Note: This method uses the 24-hour time format (HH) rather than 12-hour (hh)
  /// to avoid ambiguity in chart displays.
  static String formatDateTimeWithSeconds(int timestamp, {bool isUtc = true}) {
    final DateTime time =
        DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: isUtc);
    return DateFormat('dd MMM yyyy HH:mm:ss').format(time);
  }

  /// Formats a timestamp to a date-only string without time information.
  ///
  /// This method converts a Unix timestamp (milliseconds since epoch) to a formatted
  /// date string in the format 'dd MMM yyyy'. It's typically used for x-axis labels
  /// on daily charts or when only the date component is relevant.
  ///
  /// Parameters:
  /// - [timestamp]: The Unix timestamp in milliseconds since epoch to format
  /// - [isUtc]: Whether to interpret the timestamp as UTC (true) or local time (false).
  ///   Defaults to true as chart data is typically stored in UTC.
  ///
  /// Returns:
  /// A formatted string in the pattern 'dd MMM yyyy' (e.g., '01 Oct 2021')
  ///
  /// Example:
  /// ```dart
  /// final timestamp = 1633072800000; // 2021-10-01 00:00:00 UTC
  /// final formatted = ChartDateUtils.formatDate(timestamp);
  /// print(formatted); // Outputs: '01 Oct 2021'
  /// ```
  ///
  /// Note: This method is useful for daily charts or when displaying date ranges
  /// where the time component is not relevant.
  static String formatDate(int timestamp, {bool isUtc = true}) {
    final DateTime time =
        DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: isUtc);
    return DateFormat('dd MMM yyyy').format(time);
  }

  /// Formats a timestamp to a time-only string with seconds.
  ///
  /// This method converts a Unix timestamp (milliseconds since epoch) to a formatted
  /// time string in the format 'HH:mm:ss'. It's commonly used for intraday charts
  /// where only the time component is relevant, such as tick charts or minute charts.
  ///
  /// Parameters:
  /// - [timestamp]: The Unix timestamp in milliseconds since epoch to format
  /// - [isUtc]: Whether to interpret the timestamp as UTC (true) or local time (false).
  ///   Defaults to true as chart data is typically stored in UTC.
  ///
  /// Returns:
  /// A formatted string in the pattern 'HH:mm:ss' (e.g., '14:30:45')
  ///
  /// Example:
  /// ```dart
  /// final timestamp = 1633072800000; // 2021-10-01 00:00:00 UTC
  /// final formatted = ChartDateUtils.formatTimeWithSeconds(timestamp);
  /// print(formatted); // Outputs: '00:00:00'
  ///
  /// final anotherTimestamp = 1633083600000; // 2021-10-01 03:00:00 UTC
  /// final anotherFormatted = ChartDateUtils.formatTimeWithSeconds(anotherTimestamp);
  /// print(anotherFormatted); // Outputs: '03:00:00'
  /// ```
  ///
  /// Note: This method uses the 24-hour time format (HH) rather than 12-hour (hh)
  /// to avoid ambiguity in chart displays. It's particularly useful for intraday
  /// trading charts where precise time information is important.
  static String formatTimeWithSeconds(int timestamp, {bool isUtc = true}) {
    final DateTime time =
        DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: isUtc);
    return DateFormat('HH:mm:ss').format(time);
  }
}
