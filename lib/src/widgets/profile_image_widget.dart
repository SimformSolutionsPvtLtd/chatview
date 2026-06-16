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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

class ProfileImageWidget extends StatelessWidget {
  const ProfileImageWidget({
    super.key,
    this.imageUrl,
    this.defaultAvatarImage = Constants.profileImage,
    this.circleRadius,
    this.assetImageErrorBuilder,
    this.networkImageErrorBuilder,
    this.imageType = ImageType.network,
    required this.networkImageProgressIndicatorBuilder,
  });

  /// Allow user to set radius of circle avatar.
  final double? circleRadius;

  /// Allow user to pass image url of user's profile picture.
  final String? imageUrl;

  /// Flag to check whether image is network or asset
  final ImageType? imageType;

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
    final radius = (circleRadius ?? 20) * 2;
    return ClipRRect(
      borderRadius: BorderRadius.circular(circleRadius ?? 20),
      child: switch (imageType) {
        ImageType.asset when (imageUrl?.isNotEmpty ?? false) => Image.asset(
            imageUrl!,
            height: radius,
            width: radius,
            fit: BoxFit.cover,
            errorBuilder: assetImageErrorBuilder ?? _errorWidget,
          ),
        ImageType.network when (imageUrl?.isNotEmpty ?? false) =>
          CachedNetworkImage(
            imageUrl: imageUrl ?? defaultAvatarImage,
            height: radius,
            width: radius,
            fit: BoxFit.cover,
            progressIndicatorBuilder:
                networkImageProgressIndicatorBuilder == null
                    ? null
                    : (context, url, progress) =>
                        networkImageProgressIndicatorBuilder!.call(
                          context,
                          url,
                          CacheNetworkImageDownloadProgress(
                            progress.originalUrl,
                            progress.totalSize,
                            progress.downloaded,
                          ),
                        ),
            errorWidget: networkImageErrorBuilder ?? _networkImageErrorWidget,
          ),
        ImageType.base64 when (imageUrl?.isNotEmpty ?? false) => Image.memory(
            base64Decode(imageUrl!),
            height: radius,
            width: radius,
            fit: BoxFit.cover,
            errorBuilder: assetImageErrorBuilder ?? _errorWidget,
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _networkImageErrorWidget(
    BuildContext context,
    String url,
    Object error,
  ) {
    return const Center(
      child: Icon(
        Icons.error_outline,
        size: 18,
      ),
    );
  }

  Widget _errorWidget(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return const Center(
      child: Icon(
        Icons.error_outline,
        size: 18,
      ),
    );
  }
}
