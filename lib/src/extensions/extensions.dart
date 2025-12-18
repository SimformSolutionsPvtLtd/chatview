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

import 'dart:convert';

import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../inherited_widgets/configurations_inherited_widgets.dart';
import '../models/config_models/chat_bubble_configuration.dart';
import '../models/config_models/chat_list/list_type_indicator_config.dart';
import '../models/config_models/message_list_configuration.dart';
import '../models/config_models/reply_suggestions_config.dart';
import '../utils/constants/constants.dart';
import '../utils/emoji_parser.dart';
import '../utils/package_strings.dart';
import '../values/enumeration.dart';
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

  MemoryImage? toMemoryImage() {
    if (!fromMemory) return null;

    Uint8List? bytes;
    try {
      // Extract only the base64 part after `base64,`
      final startIndex = indexOf('base64,');
      if (startIndex == -1) return null;
      final base64String = substring(startIndex + 7);
      bytes = base64Decode(base64String);
    } catch (_) {}

    return bytes == null ? null : MemoryImage(bytes);
  }

  bool get isAllEmoji {
    final unEmojified = EmojiParser().parseEmojis(this);
    return runes.length == unEmojified.length;
  }

  bool get isUrl {
    final uri = Uri.tryParse(this);
    return uri != null &&
        uri.isAbsolute &&
        (uri.scheme == httpScheme || uri.scheme == httpsScheme);
  }

  /// Regular expression pattern to match URLs.
  static final _urlRegex = RegExp(urlRegex, caseSensitive: false);

  /// Extracts all URLs from the string and returns them as a list.
  List<String> get extractedUrls {
    final regex = _urlRegex.allMatches(this);
    final urls = <String>[];
    for (final match in regex) {
      if (match.group(0) case final url? when url.isUrl) {
        urls.add(url);
      }
    }
    return urls;
  }

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

  String getChatListStateTitle(ChatViewState state) {
    return this ??
        switch (state) {
          ChatViewState.noData => PackageStrings.currentLocale.noChats,
          ChatViewState.hasMessages || ChatViewState.loading => '',
          ChatViewState.error =>
            PackageStrings.currentLocale.somethingWentWrong,
        };
  }
}

extension type const TypingStatusConfigExtension(TypingStatusConfig config) {
  String toTypingStatus(List<ChatUser> users) {
    final prefix = config.prefix ?? '';
    final suffix = config.suffix ?? '';
    final showUserNames = config.showUserNames;
    final locale = PackageStrings.currentLocale;
    final text = '$prefix${locale.typing}$suffix';
    if (users.isEmpty) return text;

    final count = users.length;

    final firstName = users[0].name;

    if (count == 1) {
      return '$firstName ${locale.isVerb} $text';
    } else if (count == 2) {
      final newText = showUserNames
          ? '$firstName & ${users[1].name} ${locale.areVerb}'
          : '$firstName & 1 ${locale.other} ${locale.isVerb}';
      return '$newText $text';
    } else if (showUserNames && count == 3) {
      return '$firstName, ${users[1].name} & ${users[2].name} '
          '${locale.areVerb} $text';
    } else {
      final newText = showUserNames
          ? '$firstName, ${users[1].name} & ${count - 2}'
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
  /// This method calculates and updates the height of the chat text field.
  /// It retrieves the height from the current context and updates the
  /// `chatTextFieldHeight` in the `ChatViewInheritedWidget`.
  void calculateAndUpdateTextFieldHeight() {
    if (!mounted) return;
    // Update the chat text field height based on the current context size.
    chatViewIW?.chatTextFieldHeight.value = textFieldHeight;
  }

  /// This getter will provide the height of the text field from the
  /// current context if available, otherwise it will return the
  /// default height of the text field.
  ///
  /// **Note**: Make sure the `chatTextFieldViewKey` is assigned to retrieve
  /// actual height of text field.
  double get textFieldHeight =>
      chatViewIW?.chatTextFieldViewKey.currentContext?.size?.height ??
      defaultChatTextFieldHeight;

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

/// Extension for [MuteStatus] providing utilities
/// for displaying mute status in menus and icons.
extension MuteStatusExtension on MuteStatus {
  /// Toggles the mute status.
  /// If the current status is muted, it returns unmute.
  /// If the current status is unmute, it returns muted.
  MuteStatus get toggle {
    return switch (this) {
      MuteStatus.muted => MuteStatus.unmuted,
      MuteStatus.unmuted => MuteStatus.muted,
    };
  }

  /// {@template chatview.extensions.MuteStatus.menuName}
  /// - `MuteStatus.muted` -> `PackageStrings.currentLocale.mute`
  /// - `MuteStatus.unmuted` -> `PackageStrings.currentLocale.unmute`
  /// {@endtemplate}
  String get menuName => switch (this) {
        MuteStatus.muted => PackageStrings.currentLocale.mute,
        MuteStatus.unmuted => PackageStrings.currentLocale.unmute,
      };

  /// {@template chatview.extensions.MuteStatus.iconData}
  /// - `MuteStatus.muted` -> `Icons.notifications_off_outlined`
  /// - `MuteStatus.unmuted` -> `Icons.notifications_outlined`
  /// {@endtemplate}
  IconData get iconData => switch (this) {
        MuteStatus.muted => Icons.notifications_off_outlined,
        MuteStatus.unmuted => Icons.notifications_outlined,
      };
}

/// Extension for [PinStatus] providing utilities
/// for displaying pin status in menus and icons.
extension PinStatusExtension on PinStatus {
  /// Toggles the pin status.
  /// If the current status is pinned, it returns unpinned.
  /// If the current status is unpinned, it returns pinned.
  PinStatus get toggle {
    return switch (this) {
      PinStatus.pinned => PinStatus.unpinned,
      PinStatus.unpinned => PinStatus.pinned,
    };
  }

  /// {@template chatview.extensions.PinStatus.menuName}
  /// - `PinStatus.pinned` -> `PackageStrings.currentLocale.pin`
  /// - `PinStatus.unpinned` -> `PackageStrings.currentLocale.unpin`
  /// {@endtemplate}
  String get menuName => switch (this) {
        PinStatus.pinned => PackageStrings.currentLocale.pin,
        PinStatus.unpinned => PackageStrings.currentLocale.unpin,
      };

  /// {@template chatview.extensions.PinStatus.iconData}
  /// - `PinStatus.pinned` -> `Icons.push_pin`
  /// - `PinStatus.unpinned` -> `Icons.push_pin_outlined`
  /// {@endtemplate}
  IconData get iconData => switch (this) {
        PinStatus.pinned => Icons.push_pin,
        PinStatus.unpinned => Icons.push_pin_outlined,
      };
}

/// Extension for [UserActiveStatus] providing utilities
/// for displaying user active/inactive status colors.
extension UserActiveStatusExtension on UserActiveStatus {
  /// {@template chatview.extensions.UserActiveStatus.indicatorColor}
  /// - `UserActiveStatus.online` -> `Colors.green`
  /// - `UserActiveStatus.offline` -> `Colors.grey`
  /// {@endtemplate}
  Color get indicatorColor => switch (this) {
        UserActiveStatus.online => Colors.green,
        UserActiveStatus.offline => Colors.grey,
      };
}

extension UserActiveStatusAlignmentExtension on UserActiveStatusAlignment {
  double? get right => switch (this) {
        UserActiveStatusAlignment.bottomRight ||
        UserActiveStatusAlignment.topRight =>
          0,
        _ => null,
      };

  double? get left => switch (this) {
        UserActiveStatusAlignment.bottomLeft ||
        UserActiveStatusAlignment.topLeft =>
          0,
        _ => null,
      };

  double? get top => switch (this) {
        UserActiveStatusAlignment.topLeft ||
        UserActiveStatusAlignment.topRight =>
          0,
        _ => null,
      };

  double? get bottom => switch (this) {
        UserActiveStatusAlignment.bottomLeft ||
        UserActiveStatusAlignment.bottomRight =>
          0,
        _ => null,
      };
}

extension AsyncSnapshotExtension<T> on AsyncSnapshot<List<T>> {
  ChatViewState get chatViewState {
    if (hasError) {
      return ChatViewState.error;
    } else if (data?.isNotEmpty ?? false) {
      return ChatViewState.hasMessages;
    } else if (connectionState.isWaiting) {
      return ChatViewState.loading;
    } else {
      return ChatViewState.noData;
    }
  }
}

extension PlatformExtension on TargetPlatform {
  bool get isMobile =>
      !kIsWeb && (this == TargetPlatform.iOS || this == TargetPlatform.android);
}

extension CupertinoContextMenuActionExtension on CupertinoContextMenuAction {
  PopupMenuItem<T> toPopUpMenuItem<T>({T? value, Color? errorColor}) =>
      PopupMenuItem<T>(
        value: value,
        onTap: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingIcon case final icon?) ...[
              Icon(
                icon,
                size: 18,
                color: isDestructiveAction ? errorColor : null,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: DefaultTextStyle.merge(
                child: child,
                style:
                    isDestructiveAction ? TextStyle(color: errorColor) : null,
              ),
            ),
          ],
        ),
      );
}

extension MessageStatusExtension on MessageStatus {
  /// {@template chatview.extensions.MessageStatus.icon}
  /// - `MessageStatus.read` -> `Icons.done_all`
  /// - `MessageStatus.delivered` -> `Icons.done_all`
  /// - `MessageStatus.pending` -> `Icons.schedule`
  /// - `MessageStatus.undelivered` -> `Icons.error_outline`
  /// {@endtemplate}
  IconData get icon => switch (this) {
        MessageStatus.read => Icons.done_all,
        MessageStatus.delivered => Icons.done_all,
        MessageStatus.pending => Icons.schedule,
        MessageStatus.undelivered => Icons.error_outline,
      };

  /// {@template chatview.extensions.MessageStatus.iconColor}
  /// - `MessageStatus.read` -> `Colors.green`
  /// - `MessageStatus.delivered` -> `Colors.grey`
  /// - `MessageStatus.pending` -> `Colors.grey`
  /// - `MessageStatus.undelivered` -> `Colors.red`
  /// {@endtemplate}
  Color get iconColor => switch (this) {
        MessageStatus.read => Colors.green,
        MessageStatus.undelivered => Colors.red,
        MessageStatus.delivered || MessageStatus.pending => Colors.grey,
      };
}
