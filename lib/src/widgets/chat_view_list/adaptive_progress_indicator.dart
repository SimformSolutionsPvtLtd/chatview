import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdaptiveProgressIndicator extends StatelessWidget {
  const AdaptiveProgressIndicator({required this.size, this.color, super.key});

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: switch (defaultTargetPlatform) {
        TargetPlatform.iOS ||
        TargetPlatform.macOS =>
          CupertinoActivityIndicator(color: color, radius: size * 0.5),
        TargetPlatform.android ||
        TargetPlatform.fuchsia ||
        TargetPlatform.linux ||
        TargetPlatform.windows =>
          SizedBox.square(
            dimension: size,
            child: CircularProgressIndicator(color: color),
          ),
      },
    );
  }
}
