import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatview/src/extensions/extensions.dart';
import 'package:flutter/material.dart';

import '../models/chat_list_user.dart';
import '../models/config_models/profile_widget_config.dart';

class ChatUserAvatar extends StatelessWidget {
  const ChatUserAvatar({
    super.key,
    this.profileWidgetConfig,
    required this.user,
  });

  final ProfileWidgetConfig? profileWidgetConfig;
  final ChatViewListUser user;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: profileWidgetConfig?.circleAvatarRadius,
          backgroundImage: user.imageUrl == null || user.imageUrl!.isEmpty
              ? null
              : user.imageUrl!.isUrl
                  ? CachedNetworkImageProvider(user.imageUrl!)
                  : user.imageUrl!.fromMemory
                      ? MemoryImage(
                          base64Decode(
                            user.imageUrl!.substring(
                              user.imageUrl!.indexOf('base64') + 7,
                            ),
                          ),
                        )
                      : FileImage(File(user.imageUrl!)),
          backgroundColor: profileWidgetConfig?.backgroundColor,
          onBackgroundImageError: profileWidgetConfig?.onBackgroundImageError,
        ),
        if ((profileWidgetConfig?.showOnlineStatus ?? false) &&
            user.userActiveStatus.isOnline)
          const Positioned(
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(width: 2, color: Colors.white),
                ),
              ),
              child: SizedBox(width: 14, height: 14),
            ),
          ),
      ],
    );
  }
}
