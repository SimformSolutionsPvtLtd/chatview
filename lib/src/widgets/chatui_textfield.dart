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
import 'dart:io' show File, Platform;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../extensions/extensions.dart';
import '../models/config_models/send_message_configuration.dart';
import '../utils/constants/constants.dart';
import '../utils/debounce.dart';
import '../utils/package_strings.dart';
import '../values/enumeration.dart';
import '../values/typedefs.dart';
import 'action_widgets/camera_action_button.dart';
import 'action_widgets/gallery_action_button.dart';
import 'chat_textfield_view_builder.dart';

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

  bool Function(KeyEvent)? _keyboardHandler;

  SendMessageConfiguration get sendMessageConfig => widget.sendMessageConfig;

  VoiceRecordingConfiguration get voiceRecordingConfig =>
      widget.sendMessageConfig.voiceRecordingConfiguration;

  ImagePickerIconsConfiguration? get imagePickerIconsConfig =>
      sendMessageConfig.imagePickerIconsConfig;

  TextFieldConfiguration? get textFieldConfig =>
      sendMessageConfig.textFieldConfig;

  CancelRecordConfiguration? get cancelRecordConfiguration =>
      sendMessageConfig.cancelRecordConfiguration;

  OutlineInputBorder get _outLineBorder => OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: widget.sendMessageConfig.textFieldConfig?.borderRadius ??
            BorderRadius.circular(textFieldBorderRadius),
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
            const Duration(seconds: 1));
    super.initState();

    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      controller = RecorderController();
    }
    if (kIsWeb) {
      if (_attachHardwareKeyboardHandler() case final handler) {
        _keyboardHandler = handler;
        HardwareKeyboard.instance.addHandler(handler);
      }
    }
  }

  @override
  void dispose() {
    debouncer.dispose();
    composingStatus.dispose();
    isRecording.dispose();
    _isTextNotEmptyNotifier.dispose();
    if (_keyboardHandler case final handler?) {
      HardwareKeyboard.instance.removeHandler(handler);
    }
    widget.textEditingController.removeListener(_listenTextEditingController);
    playerController.dispose();
    super.dispose();
  }

  void attachListeners() {
    composingStatus.addListener(() {
      widget.sendMessageConfig.textFieldConfig?.onMessageTyping
          ?.call(composingStatus.value);
    });
  }

  // Attaches a hardware keyboard handler to handle Enter key events.
  // This is only applicable for web platforms.
  // It checks if the Enter key is pressed then sends the message
  // or inserts a new line based on whether Enter + Shift is pressed.
  bool Function(KeyEvent) _attachHardwareKeyboardHandler() {
    return (KeyEvent event) {
      if (event is! KeyDownEvent ||
          event.logicalKey != LogicalKeyboardKey.enter) {
        return false;
      }

      final pressedKeys = HardwareKeyboard.instance.logicalKeysPressed;
      final isShiftPressed = pressedKeys.any((key) =>
          key == LogicalKeyboardKey.shiftLeft ||
          key == LogicalKeyboardKey.shiftRight);
      if (!isShiftPressed) {
        // Send message on Enter
        final text = widget.textEditingController.text;
        if (text.trim().isNotEmpty) {
          _onPressed();
        }
      } else {
        // Shift+Enter: insert new line
        final text = widget.textEditingController.text;
        final selection = widget.textEditingController.selection;

        // Insert a newline ('\n') at the current cursor position or
        // replace selected text with it.
        final newText = text.replaceRange(
          selection.start,
          selection.end,
          '\n',
        );
        widget.textEditingController
          ..text = newText
          ..selection = TextSelection.collapsed(offset: selection.start + 1);
      }
      return true;
    };
  }

  @override
  Widget build(BuildContext context) {
    final outlineBorder = _outLineBorder;
    return Container(
      padding:
          textFieldConfig?.padding ?? const EdgeInsets.symmetric(horizontal: 6),
      margin: textFieldConfig?.margin,
      decoration: BoxDecoration(
        borderRadius: textFieldConfig?.borderRadius ??
            BorderRadius.circular(textFieldBorderRadius),
        color: sendMessageConfig.textFieldBackgroundColor ?? Colors.white,
      ),
      child: ChatTextFieldViewBuilder<bool>(
        valueListenable: isRecording,
        builder: (_, isRecordingValue, child) {
          return Row(
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
                          return actions == null
                              ? const SizedBox.shrink()
                              : Row(children: actions);
                        },
                      ),
                      Expanded(
                        child: TextField(
                          focusNode: widget.focusNode,
                          controller: widget.textEditingController,
                          style: textFieldConfig?.textStyle ??
                              const TextStyle(color: Colors.white),
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
                            fillColor:
                                sendMessageConfig.textFieldBackgroundColor ??
                                    Colors.white,
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
                    ],
                  ),
                ),
              ValueListenableBuilder<bool>(
                valueListenable: _isTextNotEmptyNotifier,
                builder: (_, isNotEmpty, child) {
                  if (isNotEmpty) {
                    return IconButton(
                      color: sendMessageConfig.defaultSendButtonColor ??
                          Colors.green,
                      style: sendMessageConfig.sendButtonStyle,
                      onPressed: (textFieldConfig?.enabled ?? true)
                          ? _onPressed
                          : null,
                      icon: sendMessageConfig.sendButtonIcon ??
                          const Icon(Icons.send),
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
                                  icon: imagePickerIconsConfig
                                          ?.cameraImagePickerIcon ??
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        color: imagePickerIconsConfig
                                            ?.cameraIconColor,
                                      ),
                                  onPressed:
                                      !(textFieldConfig?.enabled ?? false)
                                          ? null
                                          : (path, _) => widget.onImageSelected(
                                                path ?? '',
                                                '',
                                              ),
                                ),
                                GalleryActionButton(
                                  icon: imagePickerIconsConfig
                                          ?.galleryImagePickerIcon ??
                                      Icon(
                                        Icons.image,
                                        color: imagePickerIconsConfig
                                            ?.galleryIconColor,
                                      ),
                                  onPressed:
                                      !(textFieldConfig?.enabled ?? false)
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
                            (Platform.isIOS || Platform.isAndroid))
                          IconButton(
                            onPressed: (textFieldConfig?.enabled ?? true)
                                ? _recordOrStop
                                : null,
                            icon: (isRecordingValue
                                    ? voiceRecordingConfig.stopIcon
                                    : voiceRecordingConfig.micIcon) ??
                                Icon(
                                  isRecordingValue ? Icons.stop : Icons.mic,
                                  color: voiceRecordingConfig.recorderIconColor,
                                ),
                          ),

                        if (isRecordingValue &&
                            cancelRecordConfiguration != null)
                          IconButton(
                            onPressed: () {
                              cancelRecordConfiguration?.onCancel?.call();
                              _cancelRecording();
                            },
                            icon: cancelRecordConfiguration?.icon ??
                                const Icon(Icons.cancel_outlined),
                            color: cancelRecordConfiguration?.iconColor ??
                                voiceRecordingConfig.recorderIconColor,
                          ),
                      ],
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _onPressed() {
    _isTextNotEmptyNotifier.value = false;
    widget.onPressed();
  }

  FutureOr<void> _cancelRecording() async {
    assert(
      defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android,
      'Voice messages are only supported with android and ios platform',
    );
    if (!isRecording.value) return;
    final path = await controller?.stop();
    if (path == null) {
      isRecording.value = false;
      return;
    }
    final file = File(path);

    if (await file.exists()) {
      await file.delete();
    }

    isRecording.value = false;
  }

  Future<void> _recordOrStop() async {
    assert(
      defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android,
      'Voice messages are only supported with android and ios platform',
    );
    if (!isRecording.value) {
      if (chatListConfig
              .messageConfig?.voiceMessageConfig?.playerMode.isSingle ??
          false) {
        playerController.pauseAllPlayers();
      }
      await controller?.record(
        recorderSettings: voiceRecordingConfig.recorderSettings,
      );
      isRecording.value = true;
    } else {
      final path = await controller?.stop();
      isRecording.value = false;
      widget.onRecordingComplete(path);
    }
  }

  void _listenTextEditingController() {
    widget.textEditingController.addListener(() {
      _onChanged(widget.textEditingController.text);
    });
  }

  void _onChanged(String inputText) {
    debouncer.run(onComplete: () {
      composingStatus.value = TypeWriterStatus.typed;
    }, onInterrupt: () {
      composingStatus.value = TypeWriterStatus.typing;
    });
    _isTextNotEmptyNotifier.value = inputText.trim().isNotEmpty;
  }
}
