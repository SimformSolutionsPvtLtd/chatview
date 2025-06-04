import 'dart:io';

import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/helper.dart';

/// Gallery action button implementation.
class GalleryActionButton extends TextFieldActionButton {
  GalleryActionButton({
    super.key,
    required super.icon,
    required ValueSetter<String?>? onPressed,
    super.color,
    this.imagePickerConfiguration,
  }) : super(
          onPressed: onPressed == null
              ? null
              : () async {
                  final primaryFocus = FocusManager.instance.primaryFocus;
                  final hasFocus = primaryFocus?.hasFocus ?? false;
                  primaryFocus?.unfocus();
                  final path = await onMediaActionButtonPressed(
                    ImageSource.gallery,
                    config: imagePickerConfiguration,
                  );
                  // To maintain the iOS native behavior of text field,
                  // When the user taps on the gallery icon, and the text field has focus,
                  // the keyboard should close.
                  // We need to request focus again to open the keyboard.
                  // This is not required for Android.
                  // This is a workaround for the issue where the keyboard remain open and overlaps the text field.

                  // https://github.com/SimformSolutionsPvtLtd/chatview/issues/266
                  if (Platform.isIOS && hasFocus) {
                    primaryFocus?.requestFocus();
                  }
                  onPressed.call(path);
                },
        );

  final ImagePickerConfiguration? imagePickerConfiguration;

  @override
  State<GalleryActionButton> createState() => _GalleryActionButtonState();
}

class _GalleryActionButtonState
    extends TextFieldActionButtonState<GalleryActionButton> {}
