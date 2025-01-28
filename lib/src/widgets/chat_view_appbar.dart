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

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../chatview.dart';
import 'profile_image_widget.dart';

class ChatViewAppBar extends StatelessWidget {
  const ChatViewAppBar({
    Key? key,
    required this.chatTitle,
    @Deprecated('Use backgroundColor instead') this.backGroundColor = Colors.white,
    this.backgroundColor,
    this.centerTitle = false,
    this.userStatus,
    this.profilePicture,
    this.chatTitleTextStyle,
    this.userStatusTextStyle,
    this.backArrowColor,
    this.shimmerBaseColor = Colors.black38,
    this.shimmerHighlightColor = Colors.black12,
    this.shimmerChild,
    this.actions,
    this.elevation = 1.0,
    this.onBackPress,
    this.padding,
    this.leading,
    this.showLeading = true,
    this.defaultAvatarImage = Constants.profileImage,
    this.assetImageErrorBuilder,
    this.networkImageErrorBuilder,
    this.imageType = ImageType.network,
    this.networkImageProgressIndicatorBuilder,
  }) : super(key: key);

  /// [Deprecated] use [backgroundColor] instead, this will be removed in next versions
  @Deprecated('Use backgroundColor instead. This will be removed in future versions.')
  final Color backGroundColor;

  final Color shimmerBaseColor;

  final Color shimmerHighlightColor;

  final Widget? shimmerChild;

  /// Allow user to change colour of appbar.
  final Color? backgroundColor;

  /// Allow user to center title of appbar.
  final bool centerTitle;

  /// Allow user to change title of appbar.
  final String chatTitle;

  /// Allow user to change whether user is available or offline.
  final String? userStatus;

  /// Allow user to change profile picture in appbar.
  final String? profilePicture;

  /// Allow user to change text style of chat title.
  final TextStyle? chatTitleTextStyle;

  /// Allow user to change text style of user status.
  final TextStyle? userStatusTextStyle;

  /// Allow user to change back arrow colour.
  final Color? backArrowColor;

  /// Allow user to add actions widget in right side of appbar.
  final List<Widget>? actions;

  /// Allow user to change elevation of appbar.
  final double elevation;

  /// Provides callback when user tap on back arrow.
  final VoidCallBack? onBackPress;

  /// Allow user to change padding in appbar.
  final EdgeInsets? padding;

  /// Allow user to change leading icon of appbar.
  final Widget? leading;

  /// Allow user to turn on/off leading icon.
  final bool showLeading;

  /// Field to set default image if network url for profile image not provided
  final String defaultAvatarImage;

  /// Error builder to build error widget for asset image
  final AssetImageErrorBuilder? assetImageErrorBuilder;

  /// Error builder to build error widget for network image
  final NetworkImageErrorBuilder? networkImageErrorBuilder;

  /// Field to define image type [network, asset or base64]
  final ImageType imageType;

  /// Progress indicator builder for network image
  final NetworkImageProgressIndicatorBuilder? networkImageProgressIndicatorBuilder;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      child: Container(
        padding: padding ??
            EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              bottom: 4,
            ),
        color: backgroundColor ?? backGroundColor,
        child: Row(
          children: [
            if (showLeading)
              leading ??
                  IconButton(
                    onPressed: onBackPress ?? () => Navigator.pop(context),
                    icon: Icon(
                      (!kIsWeb && Platform.isIOS) ? Icons.arrow_back_ios : Icons.arrow_back,
                      color: backArrowColor,
                    ),
                  ),
            Expanded(
              child: Row(
                children: [
                  if (profilePicture != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ProfileImageWidget(
                        imageUrl: profilePicture,
                        defaultAvatarImage: defaultAvatarImage,
                        assetImageErrorBuilder: assetImageErrorBuilder,
                        networkImageErrorBuilder: networkImageErrorBuilder,
                        imageType: imageType,
                        networkImageProgressIndicatorBuilder: networkImageProgressIndicatorBuilder,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                      mainAxisAlignment: centerTitle ? MainAxisAlignment.center : MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: centerTitle ? Alignment.center : Alignment.centerLeft,
                          child: chatTitle.isNotEmpty
                              ? Text(
                                  chatTitle,
                                  style: chatTitleTextStyle ??
                                      const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.25,
                                      ),
                                )
                              : Shimmer.fromColors(
                                  baseColor: shimmerBaseColor,
                                  highlightColor: shimmerHighlightColor,
                                  child: shimmerChild ??
                                      Container(
                                        width: 100,
                                        height: 20,
                                        color: Colors.white,
                                      ),
                                ),
                        ),
                        if (userStatus != null)
                          Text(
                            userStatus!,
                            style: userStatusTextStyle,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }
}
