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
import 'package:image_picker/image_picker.dart';

import '../extensions/extensions.dart';
import '../models/config_models/chat_view/message_input/image_picker_configuration.dart';

Future<String?> onMediaActionButtonPressed(
  ImageSource source, {
  ImagePickerConfiguration? config,
}) async {
  try {
    final image = await ImagePicker().pickImage(
      source: source,
      maxHeight: config?.maxHeight,
      maxWidth: config?.maxWidth,
      imageQuality: config?.imageQuality,
      preferredCameraDevice: config?.preferredCameraDevice ?? CameraDevice.rear,
    );
    final imagePath = await config?.onImagePicked?.call(image?.path);
    return imagePath ?? image?.path;
  } catch (e) {
    return null;
  }
}

/// Formats the time of the last message: the time today, the weekday for the
/// previous 6 days (yesterday included), otherwise [dateFormatPattern].
///
/// [createAtDate] can be UTC or local, the day is compared in local time.
///
/// Example, on Thursday 19 Nov 2026 with the pattern 'dd/MM/yyyy':
/// - today at 9:15 gives '09:15 AM'
/// - Monday 16 Nov gives 'Monday'
/// - 5 Nov gives '05/11/2026'
String formatLastMessageTime(
  DateTime createAtDate,
  String dateFormatPattern,
) {
  final messageDate = createAtDate.toLocal(); // Convert from UTC to local
  final now = DateTime.now();
  final isLast7Days = now
          .difference(
            DateTime(messageDate.year, messageDate.month, messageDate.day),
          )
          .inDays <
      7;

  if (now.isSameCalendarDay(messageDate)) {
    return messageDate.formatWith('hh:mm a'); // Today
  } else if (isLast7Days) {
    return messageDate.formatWith('EEEE');
  } else {
    return messageDate.formatWith(dateFormatPattern);
  }
}
