import 'package:flutter/material.dart';

class UserActiveStatusConfig {
  const UserActiveStatusConfig({
    this.size = 14,
    this.shape = BoxShape.circle,
    this.color = Colors.green,
    this.border = const Border.fromBorderSide(
      BorderSide(width: 2, color: Colors.white),
    ),
    this.statusBuilder,
  });

  /// Color of the active status indicator.
  ///
  /// Defaults to `Colors.green`.
  final Color color;

  /// Size of the active status indicator.
  ///
  /// Defaults to `14`.
  final double size;

  /// Shape of the active status indicator.
  ///
  /// Defaults to `BoxShape.circle`.
  final BoxShape shape;

  /// Border of the active status indicator.
  ///
  /// Defaults to a white border with a width of `2`.
  final BoxBorder? border;

  /// Custom widget builder for the active status indicator.
  final Widget? statusBuilder;
}
