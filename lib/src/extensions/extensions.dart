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

import '../inherited_widgets/configurations_inherited_widgets.dart';
import '../models/config_models/chat_bubble_configuration.dart';
import '../models/config_models/chat_view_list/list_type_indicator_config.dart';
import '../models/config_models/message_list_configuration.dart';
import '../models/config_models/reply_suggestions_config.dart';
import '../utils/constants/constants.dart';
import '../utils/emoji_parser.dart';
import '../utils/package_strings.dart';
import '../widgets/chat_view_inherited_widget.dart';
import '../widgets/profile_image_widget.dart';
import '../widgets/suggestions/suggestions_config_inherited_widget.dart';

/// Extension for DateTime to get specific formats of dates and time.
extension TimeDifference on DateTime {
  String getDay(String chatSeparatorDatePattern) {
    final now = DateTime.now();

    /// Compares only the year, month, and day of the dates, ignoring the time.
    /// For example, `2024-12-09 22:00` and `2024-12-10 00:05` are on different
    /// calendar days but less than 24 hours apart. This ensures the difference
    /// is based on the date, not the total hours between the timestamps.
    final targetDate = DateTime(year, month, day);
    final currentDate = DateTime(now.year, now.month, now.day);

    final differenceInDays = currentDate.difference(targetDate).inDays;

    if (differenceInDays == 0) {
      return PackageStrings.currentLocale.today;
    } else if (differenceInDays <= 1 && differenceInDays >= -1) {
      return PackageStrings.currentLocale.yesterday;
    } else {
      final DateFormat formatter = DateFormat(chatSeparatorDatePattern);
      return formatter.format(this);
    }
  }

  String get getDateFromDateTime {
    final DateFormat formatter = DateFormat(dateFormat);
    return formatter.format(this);
  }

  String get getTimeFromDateTime => DateFormat.Hm().format(this);

  /// Returns `true` if [other] occurs on the same calendar day as
  /// this [DateTime].
  ///
  /// This comparison checks only the year, month, and day components,
  /// and **ignores the time** (hour, minute, second, etc.).
  bool isSameCalendarDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}

/// Extension on String which implements different types string validations.
extension ValidateString on String {
  bool get isImageUrl {
    final imageUrlRegExp = RegExp(imageUrlRegExpression);
    return imageUrlRegExp.hasMatch(this) || startsWith('data:image');
  }

  bool get fromMemory => startsWith('data:image');

  bool get isAllEmoji {
    for (String s in EmojiParser().unemojify(this).split(" ")) {
      if (!s.startsWith(":") || !s.endsWith(":")) {
        return false;
      }
    }
    return true;
  }

  bool get isUrl => Uri.tryParse(this)?.isAbsolute ?? false;

  Widget getUserProfilePicture({
    required ChatUser? Function(String) getChatUser,
    double? profileCircleRadius,
    EdgeInsets? profileCirclePadding,
  }) {
    final user = getChatUser(this);
    return Padding(
      padding: profileCirclePadding ?? const EdgeInsets.only(left: 4),
      child: ProfileImageWidget(
        imageUrl: user?.profilePhoto,
        imageType: user?.imageType,
        defaultAvatarImage: user?.defaultAvatarImage ?? Constants.profileImage,
        circleRadius: profileCircleRadius ?? 8,
        assetImageErrorBuilder: user?.assetImageErrorBuilder,
        networkImageErrorBuilder: user?.networkImageErrorBuilder,
        networkImageProgressIndicatorBuilder:
            user?.networkImageProgressIndicatorBuilder,
      ),
    );
  }
}

/// Extension on MessageType for checking specific message type
extension MessageTypes on MessageType {
  bool get isImage => this == MessageType.image;

  bool get isText => this == MessageType.text;

  bool get isVoice => this == MessageType.voice;

  bool get isCustom => this == MessageType.custom;
}

/// Extension on ConnectionState for checking specific connection.
extension ConnectionStates on ConnectionState {
  bool get isWaiting => this == ConnectionState.waiting;

  bool get isActive => this == ConnectionState.active;
}

/// Extension on nullable sting to return specific state string.
extension ChatViewStateTitleExtension on String? {
  String getChatViewStateTitle(ChatViewState state) {
    switch (state) {
      case ChatViewState.hasMessages:
        return this ?? '';
      case ChatViewState.noData:
        return this ?? PackageStrings.currentLocale.noMessage;
      case ChatViewState.loading:
        return this ?? '';
      case ChatViewState.error:
        return this ?? PackageStrings.currentLocale.somethingWentWrong;
    }
  }
}

extension type const TypingStatusConfigExtension(TypingStatusConfig config) {
  String toTypingStatus(List<String> users) {
    final prefix = config.prefix ?? '';
    final suffix = config.suffix ?? '';
    final showUserNames = config.showUserNames;
    final locale = PackageStrings.currentLocale;
    final text = '$prefix${locale.typing}$suffix';
    if (users.isEmpty) return text;

    final count = users.length;

    final firstName = users[0];

    if (count == 1) {
      return '$firstName ${locale.isVerb} $text';
    } else if (count == 2) {
      final newText = showUserNames
          ? '$firstName & ${users[1]} ${locale.areVerb}'
          : '$firstName & 1 ${locale.other} ${locale.isVerb}';
      return '$newText $text';
    } else if (showUserNames && count == 3) {
      return '${users[0]}, ${users[1]} & ${users[2]} ${locale.areVerb} $text';
    } else {
      final newText = showUserNames
          ? '$firstName, ${users[1]} & ${count - 2}'
          : '$firstName & ${count - 1}';
      return '$newText ${locale.others} ${locale.areVerb} $text';
    }
  }
}

/// Extension on State for accessing inherited widget.
extension StatefulWidgetExtension on State {
  ChatViewInheritedWidget? get chatViewIW =>
      context.mounted ? ChatViewInheritedWidget.of(context) : null;

  ReplySuggestionsConfig? get suggestionsConfig => context.mounted
      ? SuggestionsConfigIW.of(context)?.suggestionsConfig
      : null;

  ConfigurationsInheritedWidget get chatListConfig =>
      context.mounted && ConfigurationsInheritedWidget.of(context) != null
          ? ConfigurationsInheritedWidget.of(context)!
          : const ConfigurationsInheritedWidget(
              chatBackgroundConfig: ChatBackgroundConfiguration(),
              child: SizedBox.shrink(),
            );
}

/// Extension on State for accessing inherited widget.
extension BuildContextExtension on BuildContext {
  ChatViewInheritedWidget? get chatViewIW =>
      mounted ? ChatViewInheritedWidget.of(this) : null;

  ReplySuggestionsConfig? get suggestionsConfig =>
      mounted ? SuggestionsConfigIW.of(this)?.suggestionsConfig : null;

  ConfigurationsInheritedWidget get chatListConfig =>
      mounted && ConfigurationsInheritedWidget.of(this) != null
          ? ConfigurationsInheritedWidget.of(this)!
          : const ConfigurationsInheritedWidget(
              chatBackgroundConfig: ChatBackgroundConfiguration(),
              child: SizedBox.shrink(),
            );

  ChatBubbleConfiguration? get chatBubbleConfig =>
      chatListConfig.chatBubbleConfig;
}
