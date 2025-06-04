import 'package:flutter/widgets.dart';

/// Represents a widget that can be used in the plus/attach modal sheet.
class OverlayActionWidget {
  const OverlayActionWidget({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;
}
