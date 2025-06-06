import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/helper.dart';

/// Gallery action button implementation.
class GalleryActionButton extends TextFieldActionButton {
  GalleryActionButton({
    super.key,
    required super.icon,
    ValueSetter<String?>? onPressed,
    super.color,
    this.imagePickerConfiguration,
  }) : super(
          onPressed: onPressed == null
              ? null
              : () async {
                  final path = await onMediaActionButtonPressed(
                    ImageSource.gallery,
                    config: imagePickerConfiguration,
                  );
                  onPressed.call(path);
                },
        );

  final ImagePickerConfiguration? imagePickerConfiguration;

  @override
  State<GalleryActionButton> createState() => _GalleryActionButtonState();
}

class _GalleryActionButtonState
    extends TextFieldActionButtonState<GalleryActionButton> {}
