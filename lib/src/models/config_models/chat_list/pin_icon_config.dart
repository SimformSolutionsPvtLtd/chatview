import 'package:flutter/widgets.dart';

class PinIconConfig {
  const PinIconConfig({
    this.size = 18,
    this.widget,
    this.color,
  });

  final Widget? widget;
  final double? size;
  final Color? color;
}
