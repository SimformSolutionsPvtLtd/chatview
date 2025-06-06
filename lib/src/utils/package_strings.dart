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
class ChatViewLocale {
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
  });

  /// Create from Map<String, String>
  factory ChatViewLocale.fromMap(Map<String, String> map) {
    return ChatViewLocale(
      today: map['today'] ?? '',
      yesterday: map['yesterday'] ?? '',
      repliedToYou: map['repliedToYou'] ?? '',
      repliedBy: map['repliedBy'] ?? '',
      more: map['more'] ?? '',
      unsend: map['unsend'] ?? '',
      reply: map['reply'] ?? '',
      replyTo: map['replyTo'] ?? '',
      message: map['message'] ?? '',
      reactionPopupTitle: map['reactionPopupTitle'] ?? '',
      photo: map['photo'] ?? '',
      send: map['send'] ?? '',
      you: map['you'] ?? '',
      report: map['report'] ?? '',
    );
  }

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
  );
}

class PackageStrings {
  static final Map<String, ChatViewLocale> _localeObjects = {
    'en': ChatViewLocale.en,
  };

  static String _currentLocale = 'en';

  /// Set the current locale for the package strings (e.g., 'en', 'es').
  static void setLocale(String locale) {
    assert(_localeObjects.containsKey(locale),
        'Locale "$locale" not found. Please add it using PackageStrings.addLocaleObject("$locale", ChatViewLocale(...)) before setting.');
    if (_localeObjects.containsKey(locale)) {
      _currentLocale = locale;
    }
  }

  /// Allow developers to add or override locales at runtime using a class
  static void addLocaleObject(String locale, ChatViewLocale localeObj) {
    _localeObjects[locale] = localeObj;
  }

  static ChatViewLocale get _activeLocale =>
      _localeObjects[_currentLocale] ?? ChatViewLocale.en;

  static String get today => _activeLocale.today;

  static String get yesterday => _activeLocale.yesterday;

  static String get repliedToYou => _activeLocale.repliedToYou;

  static String get repliedBy => _activeLocale.repliedBy;

  static String get more => _activeLocale.more;

  static String get unsend => _activeLocale.unsend;

  static String get reply => _activeLocale.reply;

  static String get replyTo => _activeLocale.replyTo;

  static String get message => _activeLocale.message;

  static String get reactionPopupTitle => _activeLocale.reactionPopupTitle;

  static String get photo => _activeLocale.photo;

  static String get send => _activeLocale.send;

  static String get you => _activeLocale.you;

  static String get report => _activeLocale.report;
}
