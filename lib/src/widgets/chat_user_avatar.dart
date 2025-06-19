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

import '../extensions/extensions.dart';
import '../models/chat_view_list_tile.dart';
import '../models/config_models/chat_view_list_user_config.dart';

class ChatUserAvatar extends StatelessWidget {
  const ChatUserAvatar({
    super.key,
    this.chatViewListTileConfig,
    required this.user,
  });

  /// Configuration for the profile widget.
  final ChatViewListTileConfig? chatViewListTileConfig;

  /// User data for the chat list tile.
  final ChatViewListModel user;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: chatViewListTileConfig?.circleAvatarRadius,
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
          backgroundColor: chatViewListTileConfig?.backgroundColor,
          onBackgroundImageError:
              chatViewListTileConfig?.onBackgroundImageError,
        ),
        if ((chatViewListTileConfig?.showOnlineStatus ?? false) &&
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
