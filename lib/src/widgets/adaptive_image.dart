import 'dart:convert';
import 'dart:io';

import 'package:chatview/src/extensions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdaptiveImage extends StatelessWidget {
  const AdaptiveImage({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isUrl) {
      return Image.network(
        imageUrl,
        fit: BoxFit.fitHeight,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    } else if (imageUrl.fromMemory) {
      return Image.memory(
        base64Decode(imageUrl.substring(imageUrl.indexOf('base64') + 7)),
        fit: BoxFit.fill,
      );
    } else {
      return kIsWeb
          ? Image.network(imageUrl, fit: BoxFit.fill)
          : Image.file(File(imageUrl), fit: BoxFit.fill);
    }
  }
}
