import 'dart:math';
import 'package:flutter/material.dart';

/// Utility class for common helper functions
class Helpers {
  Helpers._();

  // ==================== String Manipulation ====================

  /// Checks if a string is null or empty
  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Checks if a string is not null and not empty
  static bool isNotNullOrEmpty(String? value) {
    return !isNullOrEmpty(value);
  }

  /// Truncates a string to a specified length and adds ellipsis
  /// Example: truncate('Hello World', 8) -> 'Hello...'
  static String truncate(
    String text,
    int maxLength, {
    String ellipsis = '...',
  }) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}$ellipsis';
  }

  /// Removes all whitespace from a string
  static String removeWhitespace(String text) {
    return text.replaceAll(RegExp(r'\s+'), '');
  }

  /// Converts a string to camelCase
  /// Example: 'hello world' -> 'helloWorld'
  static String toCamelCase(String text) {
    final words = text.split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return text;

    final first = words.first.toLowerCase();
    final rest = words.skip(1).map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    });

    return first + rest.join('');
  }

  /// Converts a string to snake_case
  /// Example: 'helloWorld' -> 'hello_world'
  static String toSnakeCase(String text) {
    return text
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        )
        .replaceAll(RegExp(r'[\s-]+'), '_')
        .replaceAll(RegExp(r'^_'), '');
  }

  /// Generates a random string of specified length
  static String generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Masks a string, showing only the last few characters
  /// Example: maskString('1234567890', 4) -> '******7890'
  static String maskString(
    String text,
    int visibleChars, {
    String maskChar = '*',
  }) {
    if (text.length <= visibleChars) return text;
    final masked = maskChar * (text.length - visibleChars);
    return masked + text.substring(text.length - visibleChars);
  }

  // ==================== Collection Helpers ====================

  /// Checks if a list is null or empty
  static bool isListNullOrEmpty(List? list) {
    return list == null || list.isEmpty;
  }

  /// Checks if a list is not null and not empty
  static bool isListNotNullOrEmpty(List? list) {
    return !isListNullOrEmpty(list);
  }

  /// Chunks a list into smaller lists of specified size
  /// Example: chunk([1,2,3,4,5], 2) -> [[1,2], [3,4], [5]]
  static List<List<T>> chunk<T>(List<T> list, int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += size) {
      final end = (i + size < list.length) ? i + size : list.length;
      chunks.add(list.sublist(i, end));
    }
    return chunks;
  }

  /// Removes duplicates from a list
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  /// Groups a list by a key function
  static Map<K, List<T>> groupBy<T, K>(
    List<T> list,
    K Function(T) keyFunction,
  ) {
    final map = <K, List<T>>{};
    for (final item in list) {
      final key = keyFunction(item);
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  /// Finds the first element that matches a condition, or returns null
  static T? firstWhereOrNull<T>(List<T> list, bool Function(T) test) {
    try {
      return list.firstWhere(test);
    } catch (e) {
      return null;
    }
  }

  // ==================== Number Helpers ====================

  /// Clamps a number between min and max values
  static num clamp(num value, num min, num max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  /// Generates a random integer between min (inclusive) and max (exclusive)
  static int randomInt(int min, int max) {
    final random = Random();
    return min + random.nextInt(max - min);
  }

  /// Generates a random double between min and max
  static double randomDouble(double min, double max) {
    final random = Random();
    return min + random.nextDouble() * (max - min);
  }

  /// Rounds a number to specified decimal places
  static double roundToDecimal(double value, int decimalPlaces) {
    final mod = pow(10, decimalPlaces);
    return (value * mod).round() / mod;
  }

  // ==================== Date/Time Helpers ====================

  /// Checks if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Checks if a date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Checks if a date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Checks if a date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  /// Gets the start of day (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Gets the end of day (23:59:59)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  // ==================== UI Helpers ====================

  /// Shows a snackbar with a message
  static void showSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        duration: duration,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Shows an error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  /// Shows a success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  /// Hides the keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Delays execution for a specified duration
  static Future<void> delay(Duration duration) {
    return Future.delayed(duration);
  }

  // ==================== Miscellaneous ====================

  /// Safely parses an integer from a string
  static int? parseInt(String? value, {int? defaultValue}) {
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// Safely parses a double from a string
  static double? parseDouble(String? value, {double? defaultValue}) {
    if (value == null) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }

  /// Safely parses a boolean from a string
  static bool parseBool(String? value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true' || value == '1';
  }

  /// Generates a UUID-like string (not cryptographically secure)
  static String generateUuid() {
    final random = Random();
    final values = List<int>.generate(16, (i) => random.nextInt(256));

    values[6] = (values[6] & 0x0f) | 0x40;
    values[8] = (values[8] & 0x3f) | 0x80;

    final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  /// Debounces a function call
  static void Function() debounce(
    void Function() function, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(delay, function);
    };
  }
}

/// Timer class for debounce functionality
class Timer {
  final Duration duration;
  final void Function() callback;
  bool _isActive = true;

  Timer(this.duration, this.callback) {
    Future.delayed(duration).then((_) {
      if (_isActive) callback();
    });
  }

  void cancel() {
    _isActive = false;
  }
}
