import 'package:flutter/material.dart';

import '../values/typedefs.dart';

/// Represents a widget that can be used in the plus/attach modal sheet.
class OverlayActionWidget {
  final Widget icon;
  final String label;
  final VoidCallBack onTap;

  const OverlayActionWidget({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
