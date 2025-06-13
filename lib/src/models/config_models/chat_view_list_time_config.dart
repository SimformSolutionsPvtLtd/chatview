import 'package:intl/intl.dart';

class ChatViewListTimeConfig {
  const ChatViewListTimeConfig({
    required this.dateFormatPattern,
    this.spaceBetweenTimeAndUnreadCount,
  });

  /// Time format pattern for displaying time in the chat list.
  final String dateFormatPattern;

  /// Space between the time and unread count in the user widget.
  final double? spaceBetweenTimeAndUnreadCount;

  /// Formats the last message time based on the provided date string.
  /// If the date is today, it shows the time in 'hh:mm a' format.
  /// If the date is yesterday, it shows 'Yesterday'.
  /// If the date is older, it formats the date using the provided pattern.
  /// If the date is less than a minute ago, it shows 'Now'.
  /// If the date is less than an hour ago, it shows 'X min ago'.
  String formatLastMessageTime(String dateStr) {
    final inputDate =
        DateTime.parse(dateStr).toLocal(); // Convert from UTC to local
    final now = DateTime.now();
    final diff = now.difference(inputDate);

    if (diff.inMinutes < 1) {
      return 'Now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else if (_isSameDay(now, inputDate)) {
      return DateFormat('hh:mm a').format(inputDate); // Today
    } else if (_isYesterday(inputDate, now)) {
      return 'Yesterday';
    } else {
      return DateFormat(dateFormatPattern).format(inputDate);
    }
  }

  /// Checks if two DateTime objects represent the same day.
  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  /// Checks if the given date is yesterday relative to the reference date.
  bool _isYesterday(DateTime date, DateTime reference) {
    final yesterday = reference.subtract(const Duration(days: 1));
    return _isSameDay(date, yesterday);
  }
}
