import 'package:flutter/material.dart';

/// A generic action button for text fields that can be used for various actions
/// like opening the camera, or selecting images from the gallery.
class TextFieldActionButton extends StatefulWidget {
  const TextFieldActionButton({
    required this.icon,
    this.color,
    this.onPressed,
    super.key,
  });

  final Widget icon;
  final Color? color;
  final VoidCallback? onPressed;

  @override
  State<TextFieldActionButton> createState() => TextFieldActionButtonState();
}

class TextFieldActionButtonState<T extends TextFieldActionButton>
    extends State<T> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.onPressed,
      icon: widget.icon,
      color: widget.color,
    );
  }
}
