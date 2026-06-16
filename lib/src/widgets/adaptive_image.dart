import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatview/src/extensions/extensions.dart';
import 'package:chatview/src/models/config_models/image_message_configuration.dart';
import 'package:chatview/src/utils/constants/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdaptiveImage extends StatelessWidget {
  const AdaptiveImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  final String imageUrl;

  /// How the image is inscribed into its box. See [BoxFit].
  final BoxFit fit;

  /// Builds a custom error widget with access to the failing [imageUrl] and
  /// [error]. Falls back to a built-in placeholder when null.
  final ImageMessageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isUrl) {
      // Use [CachedNetworkImage] (instead of [Image.network]) so images are
      // persisted to disk. When scrolling back through a long conversation,
      // images are served from the cache instead of being re-downloaded,
      // which keeps large image-heavy chats smooth and saves bandwidth.
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        progressIndicatorBuilder: (context, url, progress) => Center(
          child: CircularProgressIndicator(value: progress.progress),
        ),
        errorWidget: (context, _, error) => _buildError(context, error),
      );
    } else if (imageUrl.fromMemory) {
      return Image.memory(
        _decodeBase64(imageUrl),
        fit: fit,
        // Avoid a flicker to a blank frame while the next decode happens on
        // rebuild (e.g. during scrolling).
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) =>
            _buildError(context, error),
      );
    } else {
      return kIsWeb
          ? Image.network(
              imageUrl,
              fit: fit,
              errorBuilder: (context, error, _) => _buildError(context, error),
            )
          : Image.file(
              File(imageUrl),
              fit: fit,
              errorBuilder: (context, error, _) => _buildError(context, error),
            );
    }
  }

  Widget _buildError(BuildContext context, Object error) =>
      errorBuilder?.call(context, imageUrl, error) ??
      const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 30, color: Colors.white70),
            SizedBox(height: 8),
            Text(
              couldNotLoadImage,
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      );

  /// Decodes the base64 payload of a `data:image` URI.
  Uint8List _decodeBase64(String value) {
    final startIndex = value.indexOf('base64,');
    return base64Decode(
      startIndex == -1 ? value : value.substring(startIndex + 7),
    );
  }
}
