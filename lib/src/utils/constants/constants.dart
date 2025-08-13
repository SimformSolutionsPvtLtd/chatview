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
import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../widgets/chat_message_sending_to_sent_animation.dart';
import '../timeago/timeago.dart' as timeago;

const String imageUrlRegExpression =
    r'(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png|jpeg)';
const String dateFormat = "yyyy-MM-dd";
const String couldNotLaunch = "Could not launch";
const String heart = "\u{2764}";
const String faceWithTears = "\u{1F602}";
const String disappointedFace = "\u{1F625}";
const String angryFace = "\u{1F621}";
const String astonishedFace = "\u{1F632}";
const String thumbsUp = "\u{1F44D}";
const double bottomPadding1 = 10;
const double bottomPadding2 = 22;
const double bottomPadding3 = 12;
const double bottomPadding4 = 6;
const double leftPadding = 9;
const double maxWidth = 350;
const int opacity = 18;
const double verticalPadding = 4.0;
const double leftPadding2 = 5;
const double horizontalPadding = 6;
const double replyBorderRadius1 = 30;
const double replyBorderRadius2 = 18;
const double leftPadding3 = 12;
const double textFieldBorderRadius = 27;
const String defaultChatSeparatorDatePattern = 'MMM dd, yyyy';
const double defaultChatTextFieldHeight = 10.0;
const Color primaryColor = Color(0xffEE5366);
const String defaultDateFormat = 'dd/MM/yyyy';
const double userAvatarRadius = 24;
const double loadMoreCircularProgressIndicatorSize = 36;

applicationDateFormatter(DateTime inputTime) {
  if (DateTime.now().difference(inputTime).inDays <= 3) {
    return timeago.format(inputTime);
  } else {
    return DateFormat('dd MMM yyyy').format(inputTime);
  }
}

/// Default widget that appears on receipts at [MessageStatus.pending] when a message
/// is not sent or at the pending state. A custom implementation can have different
/// widgets for different states.
/// Right now it is implemented to appear right next to the outgoing bubble.
Widget sendMessageAnimationBuilder(MessageStatus status) {
  return SendingMessageAnimatingWidget(status);
}

/// Default builder when the message has got seen as of now
/// is visible at the bottom of the chat bubble
Widget lastSeenAgoBuilder(Message message, String formattedDate) {
  return Padding(
    padding: const EdgeInsets.all(2),
    child: Text(
      'Seen ${applicationDateFormatter(message.createdAt)}    ',
      style: const TextStyle(color: Colors.grey, fontSize: 12),
    ),
  );
}

const suggestionListAnimationDuration = Duration(milliseconds: 200);
