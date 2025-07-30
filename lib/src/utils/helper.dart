/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import 'package:intl/intl.dart';

import '../extensions/extensions.dart';
import 'package_strings.dart';

/// Formats the last message time based on the provided date string.
/// If the date is today, it shows the time in 'hh:mm a' format.
/// If the date is yesterday, it shows 'Yesterday'.
/// If the date is older, it formats the date using the provided pattern.
/// If the date is less than a minute ago, it shows 'Now'.
/// If the date is less than an hour ago, it shows 'X min ago'.
String formatLastMessageTime(String dateStr, String dateFormatPattern) {
  final inputDate =
      DateTime.parse(dateStr).toLocal(); // Convert from UTC to local
  final now = DateTime.now();
  final diff = now.difference(inputDate);

  if (diff.inMinutes < 1) {
    return PackageStrings.currentLocale.now;
  } else if (diff.inMinutes < 60) {
    return '${diff.inMinutes} ${PackageStrings.currentLocale.minAgo}';
  } else if (now.isSameCalendarDay(inputDate)) {
    return DateFormat('hh:mm a').format(inputDate); // Today
  } else if (_isYesterday(inputDate, now)) {
    return PackageStrings.currentLocale.yesterday;
  } else {
    return DateFormat(dateFormatPattern).format(inputDate);
  }
}

/// Checks if the given date is yesterday relative to the reference date.
bool _isYesterday(DateTime date, DateTime reference) {
  final yesterday = reference.subtract(const Duration(days: 1));
  return date.isSameCalendarDay(yesterday);
}
