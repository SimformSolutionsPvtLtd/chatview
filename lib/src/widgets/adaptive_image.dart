import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatview/src/extensions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdaptiveImage extends StatelessWidget {
  const AdaptiveImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;

  /// How the image is inscribed into its box. See [BoxFit].
  final BoxFit fit;

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
        errorWidget: (context, url, error) => const Center(
          child: Icon(Icons.error_outline, size: 18),
        ),
      );
    } else if (imageUrl.fromMemory) {
      return Image.memory(
        _decodeBase64(imageUrl),
        fit: fit,
        // Avoid a flicker to a blank frame while the next decode happens on
        // rebuild (e.g. during scrolling).
        gaplessPlayback: true,
      );
    } else {
      return kIsWeb
          ? Image.network(imageUrl, fit: fit)
          : Image.file(File(imageUrl), fit: fit);
    }
  }

  /// Decodes the base64 payload of a `data:image` URI.
  Uint8List _decodeBase64(String value) {
    final startIndex = value.indexOf('base64,');
    return base64Decode(
      startIndex == -1 ? value : value.substring(startIndex + 7),
    );
  }
}
