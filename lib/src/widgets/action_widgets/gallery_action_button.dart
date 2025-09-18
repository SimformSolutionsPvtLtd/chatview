import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/config_models/send_message_configuration.dart';
import '../../utils/helper.dart';
import 'text_field_action_button.dart';

/// Gallery action button implementation.
class GalleryActionButton extends TextFieldActionButton {
  GalleryActionButton({
    required super.icon,
    required ValueSetter<String?>? onPressed,
    this.imagePickerConfiguration,
    super.key,
    super.color,
    super.style,
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
                  // When the user taps on the gallery icon, and the text field
                  // has focus, the keyboard should close.
                  // We need to request focus again to open the keyboard.
                  // This is not required for Android.
                  // This is a workaround for the issue where the keyboard
                  // remain open and overlaps the text field.

                  // https://github.com/SimformSolutionsPvtLtd/chatview/issues/266
                  if (!kIsWeb && Platform.isIOS && hasFocus) {
                    primaryFocus?.requestFocus();
                  }
                  onPressed.call(path);
                },
        );

  final ImagePickerConfiguration? imagePickerConfiguration;

  @override
  State<GalleryActionButton> createState() => _GalleryActionButtonState();
}

// As no need to custom build method,
// we are using the same state class as parent.
class _GalleryActionButtonState
    extends TextFieldActionButtonState<GalleryActionButton> {}
