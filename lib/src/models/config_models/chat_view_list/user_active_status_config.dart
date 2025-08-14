import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../../../values/enumeration.dart';
import '../../../values/typedefs.dart';

class UserActiveStatusConfig {
  const UserActiveStatusConfig({
    this.size = 14,
    this.shape = BoxShape.circle,
    this.alignment = UserActiveStatusAlignment.bottomRight,
    this.border = const Border.fromBorderSide(
      BorderSide(width: 2, color: Colors.white),
    ),
    this.color,
    this.statusBuilder,
    this.showIndicatorFor,
  });

  /// A callback that determines whether to display the indicator
  /// for a user in the chat list based on their [UserActiveStatus].
  ///
  /// By default, it will show indicator when user is online or offline.
  ///
  /// Note: This is only applicable for one-to-one chats.
  /// Group chats will not show online status.
  final ShowUserActiveIndicatorCallback? showIndicatorFor;

  /// Alignment of the online/offline status indicator
  /// relative to the user avatar.
  ///
  /// Defaults to `UserActiveStatusAlignment.bottomRight`.
  final UserActiveStatusAlignment alignment;

  /// Color of the online/offline status indicator.
  ///
  /// Defaults to:
  /// `Colors.green` for `UserActiveStatus.online`,
  /// `Colors.grey` for `UserActiveStatus.offline`,
  final ActiveStatusIndicatorColorResolver? color;

  /// Size of the active status indicator.
  ///
  /// Defaults to `14`.
  final double size;

  /// Shape of the active status indicator.
  ///
  /// Defaults to `BoxShape.circle`.
  final BoxShape shape;

  /// Border of the active status indicator.
  ///
  /// Defaults to a white border with a width of `2`.
  final BoxBorder? border;

  /// Custom widget builder for the active status indicator.
  final Widget? statusBuilder;
}
