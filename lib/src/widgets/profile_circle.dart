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

import 'package:flutter/material.dart';
import 'package:chatview_utils/chatview_utils.dart';

import 'profile_image_widget.dart';

class ProfileCircle extends StatelessWidget {
  const ProfileCircle({
    Key? key,
    required this.bottomPadding,
    this.imageUrl,
    this.profileCirclePadding,
    this.circleRadius,
    this.onTap,
    this.onLongPress,
    this.defaultAvatarImage = Constants.profileImage,
    this.assetImageErrorBuilder,
    this.networkImageErrorBuilder,
    this.imageType = ImageType.network,
    this.httpHeaders,
    this.networkImageProgressIndicatorBuilder,
  }) : super(key: key);

  /// Allow users to give  default bottom padding according to user case.
  final double bottomPadding;

  /// Allow user to pass image url, asset image of user's profile.
  /// Or
  /// Allow user to pass image data of user's profile picture in base64.
  final String? imageUrl;

  /// Field to define image type [network, asset or base64]
  final ImageType? imageType;

  /// Optional HTTP headers used for querying images.
  final Map<String, String>? httpHeaders;

  /// Allow user to set whole padding of profile circle view.
  final EdgeInsetsGeometry? profileCirclePadding;

  /// Allow user to set radius of circle avatar.
  final double? circleRadius;

  /// Allow user to do operation when user tap on profile circle.
  final VoidCallback? onTap;

  /// Allow user to do operation when user long press on profile circle.
  final VoidCallback? onLongPress;

  /// Field to set default avatar image if profile image link not provided
  final String defaultAvatarImage;

  /// Error builder to build error widget for asset image
  final AssetImageErrorBuilder? assetImageErrorBuilder;

  /// Error builder to build error widget for network image
  final NetworkImageErrorBuilder? networkImageErrorBuilder;

  /// Progress indicator builder for network image
  final NetworkImageProgressIndicatorBuilder?
      networkImageProgressIndicatorBuilder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: profileCirclePadding ??
          EdgeInsets.only(left: 6.0, right: 4, bottom: bottomPadding),
      child: InkWell(
        onLongPress: onLongPress,
        onTap: onTap,
        child: ProfileImageWidget(
          circleRadius: circleRadius ?? 16,
          imageUrl: imageUrl,
          httpHeaders: httpHeaders,
          defaultAvatarImage: defaultAvatarImage,
          assetImageErrorBuilder: assetImageErrorBuilder,
          networkImageErrorBuilder: networkImageErrorBuilder,
          imageType: imageType,
          networkImageProgressIndicatorBuilder:
              networkImageProgressIndicatorBuilder,
        ),
      ),
    );
  }
}
