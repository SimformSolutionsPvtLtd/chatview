import 'package:flutter/material.dart';

import '../../values/typedefs.dart';

/// Configuration class for the profile widget in the chat list UI.
class ProfileWidgetConfig {
  /// Creates a configuration object for the profile widget in the chat list UI.
  const ProfileWidgetConfig({
    this.circleAvatarRadius = 24.0,
    this.backgroundColor,
    this.onBackgroundImageError,
    this.onTap,
    this.showOnlineStatus = true,
  });

  /// Radius for the circle avatar in the profile widget.
  final double circleAvatarRadius;

  /// Background color for the profile widget .
  final Color? backgroundColor;

  /// Callback function that is called when there is an error loading the background image.
  final BackgroundImageLoadError onBackgroundImageError;

  /// Callback function that is called when the profile widget is tapped.
  final NullableChatViewListUserCallback? onTap;

  /// Whether to show the online status of the user in the chat list.
  final bool showOnlineStatus;
}
