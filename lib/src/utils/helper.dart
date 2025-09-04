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

/// Returns a formatted string representing the time of the last message.
/// - If the message was sent less than a minute ago, returns 'Now'.
/// - If the message was sent less than an hour ago, returns 'X min ago'.
/// - If the message was sent today, returns the time in 'hh:mm a' format.
/// - If the message was sent yesterday, returns 'Yesterday'.
/// - Otherwise, formats the date using the provided pattern.
///
/// [messageDateStr] is the date string of the message in UTC.
/// [dateFormatPattern] is the pattern to format dates older than yesterday.
String formatLastMessageTime(
  String messageDateStr,
  String dateFormatPattern,
) {
  final messageDate =
      DateTime.tryParse(messageDateStr)?.toLocal(); // Convert from UTC to local
  if (messageDate == null) return '';
  final now = DateTime.now();
  final isLast7Days = now
          .difference(
              DateTime(messageDate.year, messageDate.month, messageDate.day))
          .inDays <
      7;

  if (now.isSameCalendarDay(messageDate)) {
    return DateFormat('hh:mm a').format(messageDate); // Today
  } else if (isLast7Days) {
    return DateFormat('EEEE').format(messageDate);
  } else {
    return DateFormat(dateFormatPattern).format(messageDate);
  }
}
