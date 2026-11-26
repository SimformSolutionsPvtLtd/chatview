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
import 'dart:async';
import 'dart:io' show File;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../extensions/extensions.dart';
import '../../models/config_models/chat_view/message_input/cancel_record_configuration.dart';
import '../../models/config_models/chat_view/message_input/image_picker_icons_configuration.dart';
import '../../models/config_models/chat_view/message_input/send_message_configuration.dart';
import '../../models/config_models/chat_view/message_input/text_field_configuration.dart';
import '../../models/config_models/chat_view/message_input/voice_recording_configuration.dart';
import '../../utils/constants/constants.dart';
import '../../utils/debounce.dart';
import '../../utils/package_strings.dart';
import '../../values/enumeration.dart';
import '../../values/typedefs.dart';
import '../action_widgets/camera_action_button.dart';
import '../action_widgets/gallery_action_button.dart';
import 'action_switcher.dart';

class ChatUITextField extends StatefulWidget {
  const ChatUITextField({
    required this.focusNode,
    required this.textEditingController,
    required this.onPressed,
    required this.onRecordingComplete,
    required this.onImageSelected,
    required this.sendMessageConfig,
    super.key,
  });

  /// Provides configuration of default text field in chat.
  final SendMessageConfiguration sendMessageConfig;

  /// Provides focusNode for focusing text field.
  final FocusNode focusNode;

  /// Provides functions which handles text field.
  final TextEditingController textEditingController;

  /// Provides callback when user tap on text field.
  final VoidCallback onPressed;

  /// Provides callback once voice is recorded.
  final ValueSetter<String?> onRecordingComplete;

  /// Provides callback when user select images from camera/gallery.
  final StringsCallBack onImageSelected;

  @override
  State<ChatUITextField> createState() => _ChatUITextFieldState();
}

class _ChatUITextFieldState extends State<ChatUITextField> {
  late final ValueNotifier<bool> _isTextNotEmptyNotifier =
      ValueNotifier(widget.textEditingController.text.isNotEmpty);

  RecorderController? controller;

  final playerController = PlayerController();

  ValueNotifier<bool> isRecording = ValueNotifier(false);

  SendMessageConfiguration get sendMessageConfig => widget.sendMessageConfig;

  VoiceRecordingConfiguration get voiceRecordingConfig =>
      widget.sendMessageConfig.voiceRecordingConfiguration;

  ImagePickerIconsConfiguration? get imagePickerIconsConfig =>
      sendMessageConfig.imagePickerIconsConfig;

  TextFieldConfiguration? get textFieldConfig =>
      sendMessageConfig.textFieldConfig;

  Color get _backgroundColor =>
      sendMessageConfig.textFieldBackgroundColor ?? Colors.white;

  /// Text colour used when no `textStyle` is given: white on a dark fill, black
  /// on a light one, so typed text is never white on white.
  /// Enabled unless explicitly disabled, including when no config is given.
  bool get _isEnabled => textFieldConfig?.enabled ?? true;

  Color get _defaultTextColor =>
      ThemeData.estimateBrightnessForColor(_backgroundColor) == Brightness.dark
          ? Colors.white
          : Colors.black;

  CancelRecordConfiguration? get cancelRecordConfiguration =>
      sendMessageConfig.cancelRecordConfiguration;

  OutlineInputBorder get _outLineBorder => OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: widget.sendMessageConfig.textFieldConfig?.borderRadius ??
            textFieldBorderRadius,
      );

  ValueNotifier<TypeWriterStatus> composingStatus =
      ValueNotifier(TypeWriterStatus.typed);

  late Debouncer debouncer;

  @override
  void initState() {
    attachListeners();
    // Used to notify instead of onChanged of text field because
    // onChanged is not called when text is set programmatically.
    widget.textEditingController.addListener(_listenTextEditingController);
    debouncer = Debouncer(
      sendMessageConfig.textFieldConfig?.compositionThresholdTime ??
          const Duration(seconds: 1),
    );
    super.initState();

    if (!kIsWeb && defaultTargetPlatform.isAndroidOrIOS) {
      controller = RecorderController();
    }
  }

  @override
  void dispose() {
    // Read before isRecording is disposed.
    final recorder = controller;
    final wasRecording = isRecording.value;
    debouncer.dispose();
    composingStatus.dispose();
    isRecording.dispose();
    _isTextNotEmptyNotifier.dispose();
    widget.textEditingController.removeListener(_listenTextEditingController);
    if (recorder != null && wasRecording) {
      unawaited(_discardRecording(recorder));
    } else {
      recorder?.dispose();
    }
    playerController.dispose();
    super.dispose();
  }

  /// Stops an in-progress recording whose screen was popped and deletes the
  /// file, since nothing will ever send it.
  Future<void> _discardRecording(RecorderController recorder) async {
    try {
      final path = await recorder.stop();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    } finally {
      recorder.dispose();
    }
  }

  void attachListeners() {
    composingStatus.addListener(() {
      widget.sendMessageConfig.textFieldConfig?.onMessageTyping
          ?.call(composingStatus.value);
    });
  }

  // Web only: Enter sends, Shift+Enter falls through so the TextField inserts
  // a newline itself. Runs only while the TextField below has focus.
  KeyEventResult _onKeyEvent(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.enter ||
        HardwareKeyboard.instance.isShiftPressed) {
      return KeyEventResult.ignored;
    }
    // Underlined IME text (CJK): Enter confirms it, it must not send.
    if (widget.textEditingController.value.composing.isValid) {
      return KeyEventResult.ignored;
    }
    if (widget.textEditingController.text.trim().isNotEmpty) _onPressed();
    return KeyEventResult.handled; // swallow Enter so no newline is inserted
  }

  @override
  Widget build(BuildContext context) {
    final outlineBorder = _outLineBorder;
    return Container(
      padding:
          textFieldConfig?.padding ?? const EdgeInsets.symmetric(horizontal: 6),
      margin: textFieldConfig?.margin,
      decoration: BoxDecoration(
        borderRadius: textFieldConfig?.borderRadius ?? textFieldBorderRadius,
        color: _backgroundColor,
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: isRecording,
        builder: (_, isRecordingValue, child) {
          return Row(
            crossAxisAlignment:
                textFieldConfig?.trailingActionsAlignment.crossAxisAlignment ??
                    CrossAxisAlignment.center,
            children: [
              if (isRecordingValue && controller != null && !kIsWeb)
                Expanded(
                  child: AudioWaveforms(
                    size: const Size(double.maxFinite, 50),
                    recorderController: controller!,
                    margin: voiceRecordingConfig.margin,
                    padding: voiceRecordingConfig.padding ??
                        EdgeInsets.symmetric(
                          horizontal: cancelRecordConfiguration == null ? 8 : 5,
                        ),
                    decoration: voiceRecordingConfig.decoration ??
                        BoxDecoration(
                          color: voiceRecordingConfig.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                    waveStyle: voiceRecordingConfig.waveStyle ??
                        WaveStyle(
                          extendWaveform: true,
                          showMiddleLine: false,
                          waveColor:
                              voiceRecordingConfig.waveStyle?.waveColor ??
                                  Colors.black,
                        ),
                  ),
                )
              else
                Expanded(
                  child: Row(
                    crossAxisAlignment: textFieldConfig
                            ?.leadingActionsAlignment.crossAxisAlignment ??
                        CrossAxisAlignment.center,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: _isTextNotEmptyNotifier,
                        builder: (context, isNotEmpty, _) {
                          final hideLeadingActions =
                              (textFieldConfig?.hideLeadingActionsOnType ??
                                      false) &&
                                  isNotEmpty;
                          if (hideLeadingActions) {
                            return const SizedBox.shrink();
                          }
                          final actions = textFieldConfig?.leadingActions?.call(
                            context,
                            widget.textEditingController,
                          );
                          final showActions =
                              !hideLeadingActions && actions != null;
                          return ActionSwitcher(
                            isLeading: true,
                            child: showActions
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: actions,
                                  )
                                : const SizedBox.shrink(),
                          );
                        },
                      ),
                      Expanded(
                        child: Focus(
                          canRequestFocus: false,
                          skipTraversal: true,
                          onKeyEvent: kIsWeb ? _onKeyEvent : null,
                          child: TextField(
                            focusNode: widget.focusNode,
                            controller: widget.textEditingController,
                            style: textFieldConfig?.textStyle ??
                                TextStyle(color: _defaultTextColor),
                            maxLines: textFieldConfig?.maxLines ?? 5,
                            minLines: textFieldConfig?.minLines ?? 1,
                            keyboardType: textFieldConfig?.textInputType,
                            inputFormatters: textFieldConfig?.inputFormatters,
                            enabled: textFieldConfig?.enabled,
                            textCapitalization:
                                textFieldConfig?.textCapitalization ??
                                    TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: textFieldConfig?.hintText ??
                                  PackageStrings.currentLocale.message,
                              fillColor: _backgroundColor,
                              filled: true,
                              hintMaxLines: textFieldConfig?.hintMaxLines ?? 1,
                              hintStyle: textFieldConfig?.hintStyle ??
                                  TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade600,
                                    letterSpacing: 0.25,
                                  ),
                              contentPadding: textFieldConfig?.contentPadding ??
                                  const EdgeInsets.symmetric(horizontal: 6),
                              border: outlineBorder,
                              focusedBorder: outlineBorder,
                              enabledBorder: outlineBorder,
                              disabledBorder: outlineBorder,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ValueListenableBuilder<bool>(
                valueListenable: _isTextNotEmptyNotifier,
                builder: (_, isNotEmpty, child) {
                  return ActionSwitcher(
                    isLeading: false,
                    child: _buildTrailing(
                      context,
                      isNotEmpty: isNotEmpty,
                      isRecordingValue: isRecordingValue,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTrailing(
    BuildContext context, {
    required bool isNotEmpty,
    required bool isRecordingValue,
  }) {
    if (isNotEmpty) {
      return IconButton(
        color: sendMessageConfig.defaultSendButtonColor ?? Colors.green,
        style: sendMessageConfig.sendButtonStyle,
        onPressed: _isEnabled ? _onPressed : null,
        icon: sendMessageConfig.sendButtonIcon ?? const Icon(Icons.send),
      );
    } else {
      return Row(
        children: [
          if (!isRecordingValue)
            ...textFieldConfig?.trailingActions?.call(
                  context,
                  widget.textEditingController,
                ) ??
                [
                  CameraActionButton(
                    imagePickerConfiguration:
                        sendMessageConfig.imagePickerConfiguration,
                    icon: imagePickerIconsConfig?.cameraImagePickerIcon ??
                        Icon(
                          Icons.camera_alt_outlined,
                          color: imagePickerIconsConfig?.cameraIconColor,
                        ),
                    onPressed: !_isEnabled
                        ? null
                        : (path, _) => widget.onImageSelected(
                              path ?? '',
                              '',
                            ),
                  ),
                  GalleryActionButton(
                    imagePickerConfiguration:
                        sendMessageConfig.imagePickerConfiguration,
                    icon: imagePickerIconsConfig?.galleryImagePickerIcon ??
                        Icon(
                          Icons.image,
                          color: imagePickerIconsConfig?.galleryIconColor,
                        ),
                    onPressed: !_isEnabled
                        ? null
                        : (path, _) => widget.onImageSelected(
                              path ?? '',
                              '',
                            ),
                  ),
                ],

          // Always add the voice button at the end if allowed
          if ((sendMessageConfig.allowRecordingVoice) &&
              !kIsWeb &&
              defaultTargetPlatform.isAndroidOrIOS)
            IconButton(
              onPressed: _isEnabled ? _recordOrStop : null,
              icon: (isRecordingValue
                      ? voiceRecordingConfig.stopIcon
                      : voiceRecordingConfig.micIcon) ??
                  Icon(
                    isRecordingValue ? Icons.stop : Icons.mic,
                    color: voiceRecordingConfig.recorderIconColor,
                  ),
            ),

          if (isRecordingValue && cancelRecordConfiguration != null)
            IconButton(
              onPressed: () {
                cancelRecordConfiguration?.onCancel?.call();
                unawaited(_cancelRecording());
              },
              icon: cancelRecordConfiguration?.icon ??
                  const Icon(Icons.cancel_outlined),
              color: cancelRecordConfiguration?.iconColor ??
                  voiceRecordingConfig.recorderIconColor,
            ),
        ],
      );
    }
  }

  void _onPressed() {
    _isTextNotEmptyNotifier.value = false;
    widget.onPressed();
  }

  Future<void> _cancelRecording() async {
    assert(
      defaultTargetPlatform.isAndroidOrIOS,
      'Voice messages are only supported with android and ios platform',
    );
    if (!isRecording.value) return;
    final path = await controller?.stop();
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }

    if (!mounted) return;
    isRecording.value = false;
  }

  Future<void> _recordOrStop() async {
    assert(
      defaultTargetPlatform.isAndroidOrIOS,
      'Voice messages are only supported with android and ios platform',
    );
    if (!isRecording.value) {
      if (chatListConfig
              .messageConfig?.voiceMessageConfig?.playerMode.isSingle ??
          false) {
        await playerController.pauseAllPlayers();
      }
      await controller?.record(
        recorderSettings: voiceRecordingConfig.recorderSettings,
      );
      if (!mounted) return;
      isRecording.value = true;
    } else {
      final path = await controller?.stop();
      if (!mounted) return;
      isRecording.value = false;
      widget.onRecordingComplete(path);
    }
  }

  void _listenTextEditingController() =>
      _onChanged(widget.textEditingController.text);

  /// Sets `typing` on every edit and reverts to `typed` after the debounce;
  /// an empty field (cleared or sent) is `typed` immediately.
  ///
  /// `onInterrupt` was removed: it missed edits spaced beyond the threshold.
  void _onChanged(String inputText) {
    if (inputText.isEmpty) {
      debouncer.cancel();
      composingStatus.value = TypeWriterStatus.typed;
    } else {
      composingStatus.value = TypeWriterStatus.typing;
      debouncer.run(
        onComplete: () => composingStatus.value = TypeWriterStatus.typed,
      );
    }
    _isTextNotEmptyNotifier.value = inputText.trim().isNotEmpty;
  }
}
