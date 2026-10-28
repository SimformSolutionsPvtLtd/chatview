/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import 'package:flutter/material.dart';

import '../../../../values/typedefs.dart';
import 'cancel_record_configuration.dart';
import 'image_picker_configuration.dart';
import 'image_picker_icons_configuration.dart';
import 'text_field_configuration.dart';
import 'voice_recording_configuration.dart';

class SendMessageConfiguration {
  const SendMessageConfiguration({
    this.voiceRecordingConfiguration = const VoiceRecordingConfiguration(),
    this.shouldSendImageWithText = false,
    this.allowRecordingVoice = true,
    this.textFieldConfig,
    this.textFieldBackgroundColor,
    this.imagePickerIconsConfig,
    this.imagePickerConfiguration,
    this.defaultSendButtonColor,
    this.sendButtonIcon,
    this.replyDialogColor,
    this.replyTitleColor,
    this.replyMessageColor,
    this.closeIconColor,
    this.micIconColor,
    this.cancelRecordConfiguration,
    this.removeImageIcon,
    this.removeImageIconColor,
    this.removeImageIconSize,
    this.selectedImageMargin,
    this.selectedImageViewHeight,
    this.imageBorderRadius,
    this.selectedImageViewBuilder,
    this.sendButtonStyle,
    this.editLabel,
  });

  /// Used to give background color to text field.
  final Color? textFieldBackgroundColor;

  /// Used to give color to send button.
  final Color? defaultSendButtonColor;

  /// Provides ability to give custom send button.
  final Widget? sendButtonIcon;

  /// Used to give reply dialog color.
  final Color? replyDialogColor;

  /// Used to give color to title of reply pop-up.
  final Color? replyTitleColor;

  /// Used to give color to reply message.
  final Color? replyMessageColor;

  /// Used to give color to close icon in reply pop-up.
  final Color? closeIconColor;

  /// Provides configuration of image picker functionality.
  final ImagePickerIconsConfiguration? imagePickerIconsConfig;

  /// Provides configuration of image picker plugin.
  final ImagePickerConfiguration? imagePickerConfiguration;

  /// Provides configuration of text field.
  final TextFieldConfiguration? textFieldConfig;

  /// Enable/disable voice recording. Enabled by default.
  final bool allowRecordingVoice;

  /// Color of mic icon when replying to some voice message.
  final Color? micIconColor;

  /// Styling configuration for recorder widget.
  final VoiceRecordingConfiguration voiceRecordingConfiguration;

  /// Configuration for cancel voice recording
  final CancelRecordConfiguration? cancelRecordConfiguration;

  /// If true, then image will be sent with text message.
  final bool shouldSendImageWithText;

  /// Icon to remove image from text field.
  final Widget? removeImageIcon;

  /// Color of remove image icon.
  final Color? removeImageIconColor;

  /// Size of remove image icon.
  final double? removeImageIconSize;

  /// Margin around selected image in text field.
  final EdgeInsets? selectedImageMargin;

  /// Height of selected image view in text field.
  final double? selectedImageViewHeight;

  /// Border radius of selected image in text field.
  final double? imageBorderRadius;

  /// Provides ability to build custom view for selected images in text field.
  final SelectedImageViewBuilder? selectedImageViewBuilder;

  /// Used to give style to send button.
  final ButtonStyle? sendButtonStyle;

  /// Custom label displayed in the "editing message" indicator bar shown
  /// above the text field when the user is editing an existing message.
  ///
  /// Example: `"Editing message"` or a localized equivalent.
  ///
  /// If not provided, falls back to the locale-resolved value of
  /// `PackageStrings.currentLocale.editing`.
  final String? editLabel;
}
