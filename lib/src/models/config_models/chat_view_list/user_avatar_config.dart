import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../../utils/constants/constants.dart';
import '../../../values/typedefs.dart';
import '../../chat_view_list_item.dart';

class UserAvatarConfig {
  const UserAvatarConfig({
    this.radius = userAvatarRadius,
    this.backgroundColor,
    this.onBackgroundImageError,
    this.onProfileTap,
  });

  /// Radius for the circle avatar in the profile widget.
  ///
  /// Defaults to `24`.
  final double radius;

  /// Background color for the profile widget .
  final Color? backgroundColor;

  /// Callback function that is called when there is an error loading the background image.
  final BackgroundImageLoadError onBackgroundImageError;

  /// Callback function that is called when the profile widget is tapped.
  final ValueSetter<ChatViewListItem>? onProfileTap;
}
