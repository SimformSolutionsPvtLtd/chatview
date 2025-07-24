import 'package:flutter/widgets.dart';

class MuteIconConfig {
  const MuteIconConfig({
    this.iconSize = 18,
    this.widget,
    this.iconColor,
  });

  final Widget? widget;
  final double? iconSize;
  final Color? iconColor;
}
