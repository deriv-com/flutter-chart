/// Log level enum for the design token logger.
///
/// Defines the severity levels for logging messages:
/// - [none]: Disables all logging
/// - [error]: Only critical errors that prevent functionality
/// - [warning]: Potential issues that don't prevent functionality
/// - [info]: General information about operations
/// - [debug]: Detailed information for debugging purposes
///
/// Each level includes all levels below it (e.g., [warning] includes [error]).
enum LogLevel {
  /// Disables all logging output
  none(0),

  /// Critical errors that prevent functionality
  error(1),

  /// Potential issues that don't prevent functionality but might indicate problems
  warning(2),

  /// General information about normal operations
  info(3),

  /// Detailed information useful for debugging
  debug(4);

  /// Creates a log level with the specified numeric value
  const LogLevel(this.value);

  /// The numeric value of this log level, used for comparison
  final int value;
}

/// A utility class for logging design token operations.
///
/// This logger provides methods for logging messages at different severity levels
/// and controls which messages are displayed based on the current log level setting.
/// It is designed to work in both Flutter and Dart-only environments, making it
/// suitable for use in scripts and command-line tools.
///
/// Features:
/// - Type-safe enum for log levels
/// - Configurable verbosity
/// - Categorized messages (error, warning, info, debug)
/// - Platform-agnostic (works in both Flutter and Dart-only environments)
///
/// Example usage:
/// ```dart
/// // Set the log level
/// DesignTokenLogger.logLevel = LogLevel.debug;
///
/// // Log messages at different levels
/// DesignTokenLogger.error('Failed to parse token file');
/// DesignTokenLogger.warning('Duplicate token name detected');
/// DesignTokenLogger.info('Processing core tokens...');
/// DesignTokenLogger.debug('Token value: $tokenValue');
/// ```
class DesignTokenLogger {
  /// Private constructor to prevent instantiation
  DesignTokenLogger._();

  /// The current log level that determines which messages are displayed.
  ///
  /// Default is [LogLevel.info], which shows errors, warnings, and info messages.
  ///
  /// Messages with a severity level lower than or equal to this level will be displayed.
  /// For example, setting this to [LogLevel.warning] will display error and warning
  /// messages, but not info or debug messages.
  ///
  /// Example:
  /// ```dart
  /// // Show only errors
  /// DesignTokenLogger.logLevel = LogLevel.error;
  ///
  /// // Show everything including debug messages
  /// DesignTokenLogger.logLevel = LogLevel.debug;
  ///
  /// // Disable all logging
  /// DesignTokenLogger.logLevel = LogLevel.none;
  /// ```
  static LogLevel logLevel = LogLevel.info;

  /// Logs an error message.
  ///
  /// Use this for critical errors that prevent functionality.
  /// Error messages are displayed if the current log level is [LogLevel.error] or higher.
  ///
  /// Example:
  /// ```dart
  /// DesignTokenLogger.error('Failed to parse token file: $e');
  /// ```
  ///
  /// @param message The error message to log
  static void error(String message) {
    if (logLevel.value >= LogLevel.error.value) {
      _printMessage('ERROR: $message');
    }
  }

  /// Logs a warning message.
  ///
  /// Use this for potential issues that don't prevent functionality
  /// but might indicate problems.
  /// Warning messages are displayed if the current log level is [LogLevel.warning] or higher.
  ///
  /// Example:
  /// ```dart
  /// DesignTokenLogger.warning('Duplicate token name detected: $tokenName');
  /// ```
  ///
  /// @param message The warning message to log
  static void warning(String message) {
    if (logLevel.value >= LogLevel.warning.value) {
      _printMessage('WARNING: $message');
    }
  }

  /// Logs an informational message.
  ///
  /// Use this for general information about normal operations.
  /// Info messages are displayed if the current log level is [LogLevel.info] or higher.
  ///
  /// Example:
  /// ```dart
  /// DesignTokenLogger.info('Processing core tokens...');
  /// ```
  ///
  /// @param message The informational message to log
  static void info(String message) {
    if (logLevel.value >= LogLevel.info.value) {
      _printMessage('INFO: $message');
    }
  }

  /// Logs a debug message.
  ///
  /// Use this for detailed information that is useful for debugging.
  /// Debug messages are displayed only if the current log level is [LogLevel.debug].
  ///
  /// Example:
  /// ```dart
  /// DesignTokenLogger.debug('Token value: $tokenValue');
  /// ```
  ///
  /// @param message The debug message to log
  static void debug(String message) {
    if (logLevel.value >= LogLevel.debug.value) {
      _printMessage('DEBUG: $message');
    }
  }

  /// Internal method to print messages.
  ///
  /// Prints messages unconditionally to ensure compatibility with both Flutter
  /// and Dart-only environments (like when running scripts). The ignore comment
  /// suppresses the lint warning about using print statements in production code.
  ///
  /// @param message The message to print
  static void _printMessage(String message) {
    // ignore: avoid_print
    print(message);
  }
}
