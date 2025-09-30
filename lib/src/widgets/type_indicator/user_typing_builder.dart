import 'package:chatview_utils/chatview_utils.dart' show Constants;
import 'package:flutter/material.dart';

import '../../models/config_models/profile_circle_configuration.dart';
import '../profile_circle.dart';

class UserTypingBuilder extends StatelessWidget {
  const UserTypingBuilder({
    required this.animation,
    required this.bubble,
    this.showProfileCircle = true,
    this.profileConfig,
    super.key,
  });

  final Widget bubble;
  final Animation<double> animation;
  final ProfileCircleConfiguration? profileConfig;
  final bool showProfileCircle;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) => Transform.scale(
        scale: animation.value,
        alignment: Alignment.centerLeft,
        child: child,
      ),
      child: !showProfileCircle
          ? bubble
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProfileCircle(
                  bottomPadding: 0,
                  profileCirclePadding: EdgeInsets.zero,
                  imageUrl: profileConfig?.profileImageUrl,
                  imageType: profileConfig?.imageType,
                  assetImageErrorBuilder: profileConfig?.assetImageErrorBuilder,
                  networkImageErrorBuilder:
                      profileConfig?.networkImageErrorBuilder,
                  defaultAvatarImage: profileConfig?.defaultAvatarImage ??
                      Constants.profileImage,
                  networkImageProgressIndicatorBuilder:
                      profileConfig?.networkImageProgressIndicatorBuilder,
                ),
                bubble,
              ],
            ),
    );
  }
}
