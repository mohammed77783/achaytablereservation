import 'package:intl/intl.dart';

/// Utility class for formatting data
class Formatters {
  Formatters._();

  /// Formats a DateTime to a readable date string
  /// Default format: 'MMM dd, yyyy' (e.g., 'Jan 15, 2024')
  static String formatDate(DateTime date, {String? format}) {
    final formatter = DateFormat(format ?? 'MMM dd, yyyy');
    return formatter.format(date);
  }

  /// Formats a DateTime to a readable time string
  /// Default format: 'hh:mm a' (e.g., '02:30 PM')
  static String formatTime(DateTime date, {String? format}) {
    final formatter = DateFormat(format ?? 'hh:mm a');
    return formatter.format(date);
  }

  /// Formats a DateTime to a readable date and time string
  /// Default format: 'MMM dd, yyyy hh:mm a' (e.g., 'Jan 15, 2024 02:30 PM')
  static String formatDateTime(DateTime date, {String? format}) {
    final formatter = DateFormat(format ?? 'MMM dd, yyyy hh:mm a');
    return formatter.format(date);
  }

  /// Formats a DateTime to a relative time string
  /// Examples: 'Just now', '5 minutes ago', '2 hours ago', 'Yesterday', '3 days ago'
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Formats a number with thousand separators
  /// Example: 1234567 -> '1,234,567'
  static String formatNumber(num number, {int? decimalDigits}) {
    final formatter = NumberFormat(
      '#,##0${decimalDigits != null ? '.${'0' * decimalDigits}' : ''}',
    );
    return formatter.format(number);
  }

  /// Formats a number as a percentage
  /// Example: 0.75 -> '75%'
  static String formatPercentage(double value, {int decimalDigits = 0}) {
    final percentage = value * 100;
    return '${formatNumber(percentage, decimalDigits: decimalDigits)}%';
  }

  /// Formats a number as currency
  /// Default currency: USD
  static String formatCurrency(
    num amount, {
    String symbol = '\$',
    int decimalDigits = 2,
    String locale = 'en_US',
  }) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
      locale: locale,
    );
    return formatter.format(amount);
  }

  /// Formats a number in compact form
  /// Examples: 1000 -> '1K', 1500000 -> '1.5M', 2300000000 -> '2.3B'
  static String formatCompactNumber(num number) {
    final formatter = NumberFormat.compact();
    return formatter.format(number);
  }

  /// Formats file size in human-readable format
  /// Examples: 1024 -> '1 KB', 1048576 -> '1 MB'
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Formats a phone number with standard formatting
  /// Example: '1234567890' -> '(123) 456-7890'
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    } else if (cleaned.length == 11 && cleaned.startsWith('1')) {
      return '+1 (${cleaned.substring(1, 4)}) ${cleaned.substring(4, 7)}-${cleaned.substring(7)}';
    }

    // Return original if format is not recognized
    return phoneNumber;
  }

  /// Formats a duration in human-readable format
  /// Examples: Duration(hours: 2, minutes: 30) -> '2h 30m'
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    } else if (minutes > 0) {
      return seconds > 0 ? '${minutes}m ${seconds}s' : '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

  /// Capitalizes the first letter of a string
  /// Example: 'hello world' -> 'Hello world'
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Capitalizes the first letter of each word
  /// Example: 'hello world' -> 'Hello World'
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }
}
