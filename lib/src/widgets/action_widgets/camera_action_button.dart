import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../chatview.dart' show ChatView;
import '../../models/config_models/send_message_configuration.dart';
import '../../utils/helper.dart';
import '../../values/typedefs.dart';
import 'text_field_action_button.dart';

/// Camera action button implementation.
class CameraActionButton extends TextFieldActionButton {
  CameraActionButton({
    required super.icon,
    required CameraActionCallback? onPressed,
    this.imagePickerConfiguration,
    super.key,
    super.color,
    super.style,
  }) : super(
          onPressed: onPressed == null
              ? null
              : (context) async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  final path = await onMediaActionButtonPressed(
                    ImageSource.camera,
                    config: imagePickerConfiguration,
                  );
                  final replyMessage = context.mounted
                      ? ChatView.getReplyMessage(context)
                      : null;
                  onPressed.call(path, replyMessage);
                },
        );

  final ImagePickerConfiguration? imagePickerConfiguration;

  @override
  State<CameraActionButton> createState() => _CameraActionButtonState();
}

// As no need to custom build method,
// we are using the same state class as parent.
class _CameraActionButtonState
    extends TextFieldActionButtonState<CameraActionButton> {}
