import 'package:flutter/widgets.dart';

class PinIconConfig {
  const PinIconConfig({
    this.iconSize = 18,
    this.widget,
    this.iconColor,
  });

  final Widget? widget;
  final double? iconSize;
  final Color? iconColor;
}
