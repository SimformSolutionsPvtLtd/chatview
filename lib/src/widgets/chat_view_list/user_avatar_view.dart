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
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../extensions/extensions.dart';
import '../../models/config_models/chat_view_list/user_active_status_config.dart';
import '../../models/config_models/chat_view_list/user_avatar_config.dart';

class UserAvatarView extends StatelessWidget {
  const UserAvatarView({
    required this.imageUrl,
    required this.config,
    required this.userActiveStatusConfig,
    this.showOnlineStatus = false,
    this.onTap,
    super.key,
  });

  /// Whether to show the online status of the user in the chat list.
  final bool showOnlineStatus;

  /// Configuration for the profile widget.
  final UserAvatarConfig config;

  /// Configuration for the online status of the user.
  final UserActiveStatusConfig userActiveStatusConfig;

  /// Image URL of the user.
  final String imageUrl;

  /// Callback function to handle profile tap.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: config.radius,
            backgroundColor: config.backgroundColor,
            onBackgroundImageError: config.onBackgroundImageError,
            backgroundImage: imageUrl.isEmpty
                ? null
                : imageUrl.isUrl
                    ? CachedNetworkImageProvider(imageUrl)
                    : imageUrl.fromMemory
                        ? MemoryImage(
                            base64Decode(
                              imageUrl.substring(
                                imageUrl.indexOf('base64') + 7,
                              ),
                            ),
                          )
                        : FileImage(File(imageUrl)),
          ),
          if (showOnlineStatus)
            Positioned(
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: userActiveStatusConfig.shape,
                  color: userActiveStatusConfig.color,
                  border: userActiveStatusConfig.border,
                ),
                child: SizedBox.square(dimension: userActiveStatusConfig.size),
              ),
            ),
        ],
      ),
    );
  }
}
