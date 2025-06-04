import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/config_models/send_message_configuration.dart';
import '../../utils/helper.dart';
import 'text_field_action_button.dart';

/// Camera action button implementation.
class CameraActionButton extends TextFieldActionButton {
  CameraActionButton({
    super.key,
    required super.icon,
    super.color,
    required ValueSetter<String?>? onPressed,
    this.imagePickerConfiguration,
  }) : super(
          onPressed: onPressed == null
              ? null
              : () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  final path = await onMediaActionButtonPressed(
                    ImageSource.camera,
                    config: imagePickerConfiguration,
                  );
                  onPressed.call(path);
                },
        );

  final ImagePickerConfiguration? imagePickerConfiguration;

  @override
  State<CameraActionButton> createState() => _CameraActionButtonState();
}

class _CameraActionButtonState
    extends TextFieldActionButtonState<CameraActionButton> {}
