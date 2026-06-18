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

import '../../values/enumeration.dart';
import '../../widgets/chat_message_sending_to_sent_animation.dart';
import '../timeago/timeago.dart' as timeago;

const String imageUrlRegExpression =
    r'(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png|jpeg)';
const String dateFormat = "yyyy-MM-dd";
const String couldNotLaunch = "Could not launch";
const String couldNotLoadImage = "Couldn't load image";
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
const double imageBubbleBorderRadius = 14.0;
const double messageGroupCornerRadiusFactor = 0.3;
const double messageGroupDefaultSpacing = 2.0;
const double avatarDefaultPaddingLeft = 6.0;
const double avatarDefaultPaddingRight = 4.0;
const double leftPadding3 = 12;
const double textFieldBorderRadius = 27;
const String defaultChatSeparatorDatePattern = 'MMM dd, yyyy';
const double defaultChatTextFieldHeight = 10.0;
const Color primaryColor = Color(0xffEE5366);
const String defaultDateFormat = 'dd/MM/yyyy';
const double userAvatarRadius = 24;
const double loadMoreCircularProgressIndicatorSize = 36;

const String httpScheme = 'http';
const String httpsScheme = 'https';

/// Diameter of the sending-status indicator circle.
const double sendingIndicatorSize = 6;

/// Default color of the sending-status indicator (dot / text / clock-tick)
/// when no explicit color is provided.
const Color sendingIndicatorDefaultColor = Color(0xFF666f79);

/// Duration of the sending-to-sent indicator slide animation.
const Duration sendingAnimationDuration = Duration(milliseconds: 400);

/// Curve of the sending-to-sent indicator slide animation.
const Curve sendingAnimationCurve = Curves.easeOut;

/// Size of the clock/tick icon for the WhatsApp-style sending indicator.
const double sendingTickIconSize = 14;

/// Vertical space reserved at the bottom of a text bubble for the inline
/// WhatsApp-style clock/tick (and timestamp) so it never overlaps the message.
const double sendingReceiptInBubbleReservedHeight = 18;

/// Text shown by the [SendingMessageAnimationType.textLabel] indicator while a
/// message is pending.
const String sendingLabelText = 'Sending...';

/// Duration of the "Seen" receipt reveal (fade + slide + expand) shown below
/// the last outgoing bubble once it is read.
const Duration seenAppearanceAnimationDuration = Duration(milliseconds: 300);

/// Curve of the "Seen" receipt reveal animation.
const Curve seenAppearanceAnimationCurve = Curves.easeOutCubic;

String applicationDateFormatter(DateTime inputTime) {
  if (DateTime.now().difference(inputTime).inDays <= 3) {
    return timeago.format(inputTime);
  } else {
    return DateFormat('dd MMM yyyy').format(inputTime);
  }
}

/// Regular expression to identify URLs in a text.
const String urlRegex =
    r'((https?://)?(www\.)?[a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b'
    r'([-a-zA-Z0-9@:%_\+.~#?&//=]*))';

/// Default widget that appears on receipts at [MessageStatus.pending] when a message
/// is not sent or at the pending state. A custom implementation can have different
/// widgets for different states.
/// Right now it is implemented to appear right next to the outgoing bubble.
Widget sendMessageAnimationBuilder(
  MessageStatus status, {
  SendingMessageAnimationType type = SendingMessageAnimationType.slideOut,
  Color? color,
}) {
  return SendingMessageAnimatingWidget(status, type: type, color: color);
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

/// Duration for the text field send/action button and leading icon
/// switch animations.
const textFieldActionAnimationDuration = Duration(milliseconds: 200);
