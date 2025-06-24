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

/// Class representing all localizable strings for ChatView package.
final class ChatViewLocale {
  const ChatViewLocale({
    required this.today,
    required this.yesterday,
    required this.repliedToYou,
    required this.repliedBy,
    required this.more,
    required this.unsend,
    required this.reply,
    required this.replyTo,
    required this.message,
    required this.reactionPopupTitle,
    required this.photo,
    required this.send,
    required this.you,
    required this.report,
    required this.noMessage,
    required this.somethingWentWrong,
    required this.reload,
  });

  /// Create from Map
  factory ChatViewLocale.fromMap(Map<String, String> map) {
    return ChatViewLocale(
      today: map['today']?.toString() ?? '',
      yesterday: map['yesterday']?.toString() ?? '',
      repliedToYou: map['repliedToYou']?.toString() ?? '',
      repliedBy: map['repliedBy']?.toString() ?? '',
      more: map['more']?.toString() ?? '',
      unsend: map['unsend']?.toString() ?? '',
      reply: map['reply']?.toString() ?? '',
      replyTo: map['replyTo']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      reactionPopupTitle: map['reactionPopupTitle']?.toString() ?? '',
      photo: map['photo']?.toString() ?? '',
      send: map['send']?.toString() ?? '',
      you: map['you']?.toString() ?? '',
      report: map['report']?.toString() ?? '',
      noMessage: map['noMessage']?.toString() ?? '',
      somethingWentWrong: map['somethingWentWrong']?.toString() ?? '',
      reload: map['reload']?.toString() ?? '',
    );
  }

  final String today;
  final String yesterday;
  final String repliedToYou;
  final String repliedBy;
  final String more;
  final String unsend;
  final String reply;
  final String replyTo;
  final String message;
  final String reactionPopupTitle;
  final String photo;
  final String send;
  final String you;
  final String report;
  final String noMessage;
  final String somethingWentWrong;
  final String reload;

  /// English defaults
  static const en = ChatViewLocale(
    today: 'Today',
    yesterday: 'Yesterday',
    repliedToYou: 'Replied to you',
    repliedBy: 'Replied by',
    more: 'More',
    unsend: 'Unsend',
    reply: 'Reply',
    replyTo: 'Replying to',
    message: 'Message',
    reactionPopupTitle: 'Tap and hold to multiply your reaction',
    photo: 'Photo',
    send: 'Send',
    you: 'You',
    report: 'Report',
    noMessage: 'No message',
    somethingWentWrong: 'Something went wrong !!',
    reload: 'Reload',
  );
}
