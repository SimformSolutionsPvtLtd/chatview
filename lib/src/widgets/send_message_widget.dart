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
import 'dart:io' if (kIsWeb) 'dart:html';

import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../extensions/extensions.dart';
import '../models/config_models/message_configuration.dart';
import '../models/config_models/send_message_configuration.dart';
import '../utils/constants/constants.dart';
import '../values/typedefs.dart';
import 'chatui_textfield.dart';
import 'reply_message_view.dart';
import 'scroll_to_bottom_button.dart';
import 'edit_message_view.dart';
import 'selected_image_view_widget.dart';

class SendMessageWidget extends StatefulWidget {
  const SendMessageWidget({
    required this.onSendTap,
    required this.sendMessageConfig,
    this.onEditTap,
    this.sendMessageBuilder,
    this.messageConfig,
    this.replyMessageBuilder,
    super.key,
  });

  /// Provides call back when user tap on send button on text field.
  final StringMessageCallBack onSendTap;

  /// Provides configuration for text field appearance.
  final SendMessageConfiguration sendMessageConfig;

  /// Callback invoked when the user confirms an edit.
  /// Receives the original [Message] and the updated [Message] with new content.
  final EditMessageCallback? onEditTap;

  /// Allow user to set custom text field.
  final ReplyMessageWithReturnWidget? sendMessageBuilder;

  /// Provides configuration of all types of messages.
  final MessageConfiguration? messageConfig;

  /// Provides a callback for the view when replying to message
  final CustomViewForReplyMessage? replyMessageBuilder;

  @override
  State<SendMessageWidget> createState() => SendMessageWidgetState();
}

class SendMessageWidgetState extends State<SendMessageWidget> {
  final _textEditingController = TextEditingController();

  final _focusNode = FocusNode();

  final GlobalKey<ReplyMessageViewState> _replyMessageTextFieldViewKey =
      GlobalKey();

  final GlobalKey<EditMessageViewState> _editMessageViewKey = GlobalKey();

  final GlobalKey<SelectedImageViewWidgetState> _selectedImageViewWidgetKey =
      GlobalKey();
  ReplyMessage _replyMessage = const ReplyMessage();

  /// The message currently being edited, or `null` if not in edit mode.
  Message? _currentlyEditingMessage;

  /// Whether the text field is currently in edit mode.
  bool get isEditMode => _currentlyEditingMessage != null;

  /// Public read-only access to the message currently being edited.
  Message? get currentlyEditingMessage => _currentlyEditingMessage;

  ReplyMessage get replyMessage => _replyMessage;

  ChatUser? currentUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (chatViewIW != null) {
      currentUser = chatViewIW!.chatController.currentUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCustomTextField = widget.sendMessageBuilder != null;
    final scrollToBottomButtonConfig =
        chatListConfig.scrollToBottomButtonConfig;
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            // This has been added to prevent messages from being
            // displayed below the text field
            // when the user scrolls the message list.
            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).size.height /
                    ((!kIsWeb && Platform.isIOS) ? 24 : 28),
                color: chatListConfig.chatBackgroundConfig.backgroundColor ??
                    Colors.white,
              ),
            ),
            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (chatViewIW
                          ?.featureActiveConfig.enableScrollToBottomButton ??
                      true)
                    Align(
                      alignment:
                          scrollToBottomButtonConfig?.alignment?.alignment ??
                              Alignment.bottomCenter,
                      child: Padding(
                        padding: scrollToBottomButtonConfig?.padding ??
                            EdgeInsets.zero,
                        child: const ScrollToBottomButton(),
                      ),
                    ),
                  Padding(
                    key: chatViewIW?.chatTextFieldViewKey,
                    padding: EdgeInsets.fromLTRB(
                      bottomPadding4,
                      bottomPadding4,
                      bottomPadding4,
                      _bottomPadding,
                    ),
                    child: isCustomTextField
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ReplyMessageView(
                                key: _replyMessageTextFieldViewKey,
                                sendMessageConfig: widget.sendMessageConfig,
                                messageConfig: widget.messageConfig,
                                builder: widget.replyMessageBuilder,
                                onChange: (value) => _replyMessage = value,
                              ),
                              Builder(
                                builder: (context) {
                                  WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => context
                                        .calculateAndUpdateTextFieldHeight(),
                                  );
                                  return widget.sendMessageBuilder
                                          ?.call(_replyMessage) ??
                                      const SizedBox.shrink();
                                },
                              ),
                            ],
                          )
                        : Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              ReplyMessageView(
                                key: _replyMessageTextFieldViewKey,
                                sendMessageConfig: widget.sendMessageConfig,
                                messageConfig: widget.messageConfig,
                                builder: widget.replyMessageBuilder,
                                onChange: (value) => _replyMessage = value,
                              ),
                              EditMessageView(
                                key: _editMessageViewKey,
                                sendMessageConfig: widget.sendMessageConfig,
                                onChange: (value) {
                                  // When the user cancels via the X button
                                  // on EditMessageView, clear the text field.
                                  if (value == null &&
                                      _currentlyEditingMessage != null) {
                                    _textEditingController.clear();
                                  }
                                  _currentlyEditingMessage = value;
                                },
                              ),
                              if (widget
                                  .sendMessageConfig.shouldSendImageWithText)
                                SelectedImageViewWidget(
                                  key: _selectedImageViewWidgetKey,
                                  sendMessageConfig: widget.sendMessageConfig,
                                ),
                              ChatUITextField(
                                focusNode: _focusNode,
                                textEditingController: _textEditingController,
                                onPressed: _onPressed,
                                sendMessageConfig: widget.sendMessageConfig,
                                onRecordingComplete: _onRecordingComplete,
                                onImageSelected: (images, messageId) {
                                  if (widget.sendMessageConfig
                                      .shouldSendImageWithText) {
                                    if (images.isNotEmpty) {
                                      _selectedImageViewWidgetKey.currentState
                                          ?.selectedImages.value = [
                                        ...?_selectedImageViewWidgetKey
                                            .currentState?.selectedImages.value,
                                        images
                                      ];

                                      FocusScope.of(context)
                                          .requestFocus(_focusNode);
                                    }
                                  } else {
                                    _onImageSelected(images, '');
                                  }
                                },
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onRecordingComplete(String? path) {
    if (path != null) {
      widget.onSendTap.call(
        path,
        _replyMessage,
        MessageType.voice,
      );
      onCloseTap();
    }
  }

  void _onImageSelected(String imagePath, String error) {
    if (imagePath.isEmpty) return;

    widget.onSendTap.call(imagePath, _replyMessage, MessageType.image);
    _assignRepliedMessage();
  }

  void _assignRepliedMessage() {
    if (_replyMessage.message.isEmpty) return;
    _replyMessage = const ReplyMessage();
  }

  void _onPressed() {
    final messageText = _textEditingController.text.trim();
    _textEditingController.clear();
    if (messageText.isEmpty) return;

    // If in edit mode, delegate to onEditTap instead of onSendTap.
    if (isEditMode) {
      // Only confirm the edit if a handler is registered; otherwise keep edit
      // mode active so the user's text is not silently discarded.
      if (widget.onEditTap == null) return;
      if (messageText == _currentlyEditingMessage!.message) {
        _closeEditMode();
        return;
      }
      widget.onEditTap!.call(
        _currentlyEditingMessage!,
        _currentlyEditingMessage!.copyWith(
          message: messageText,
          updatedAt: DateTime.now(),
        ),
      );
      _closeEditMode();
      return;
    }

    if (_selectedImageViewWidgetKey.currentState?.selectedImages.value
        case final selectedImages?) {
      for (final image in selectedImages) {
        _onImageSelected(image, '');
      }
      _selectedImageViewWidgetKey.currentState?.selectedImages.value = [];
    }

    widget.onSendTap.call(
      messageText.trim(),
      _replyMessage,
      MessageType.text,
    );
    onCloseTap();
  }

  /// Puts the text field into edit mode for [message].
  /// Pre-fills the text field with the existing message content.
  void assignEditMessage(Message message) {
    // Always clear any active reply before entering edit mode.
    _replyMessage = const ReplyMessage();
    if (_replyMessageTextFieldViewKey.currentState != null) {
      _replyMessageTextFieldViewKey.currentState!.replyMessage.value =
          const ReplyMessage();
    }

    _currentlyEditingMessage = message;
    _textEditingController.text = message.message;
    // Place cursor at end.
    _textEditingController.selection = TextSelection.fromPosition(
      TextPosition(offset: message.message.length),
    );
    FocusScope.of(context).requestFocus(_focusNode);

    if (_editMessageViewKey.currentState == null) {
      setState(() {});
    } else {
      _editMessageViewKey.currentState!.editMessage.value = message;
    }
  }

  void _closeEditMode() {
    if (_currentlyEditingMessage == null) return; // Nothing to close.
    // Clear the text field when cancelling an edit.
    _textEditingController.clear();
    if (_editMessageViewKey.currentState == null) {
      setState(() {
        _currentlyEditingMessage = null;
      });
    } else {
      _editMessageViewKey.currentState?.onClose();
    }
  }

  void assignReplyMessage(Message message) {
    if (currentUser == null) {
      return;
    }
    // Clear any active edit mode before entering reply mode.
    _closeEditMode();

    FocusScope.of(context).requestFocus(_focusNode);
    _replyMessage = ReplyMessage(
      message: message.message,
      replyBy: currentUser!.id,
      replyTo: message.sentBy,
      messageType: message.messageType,
      messageId: message.id,
      voiceMessageDuration: message.voiceMessageDuration,
    );

    if (_replyMessageTextFieldViewKey.currentState == null) {
      setState(() {});
    } else {
      _replyMessageTextFieldViewKey.currentState!.replyMessage.value =
          _replyMessage;
    }
  }

  void onCloseTap() {
    if (_replyMessageTextFieldViewKey.currentState == null) {
      setState(() {
        _replyMessage = const ReplyMessage();
      });
    } else {
      _replyMessageTextFieldViewKey.currentState?.onClose();
    }
    // Also clear edit mode if active.
    _closeEditMode();
  }

  double get _bottomPadding => (!kIsWeb && Platform.isIOS)
      ? (_focusNode.hasFocus
          ? bottomPadding1
          : View.of(context).viewPadding.bottom > 0
              ? bottomPadding2
              : bottomPadding3)
      : bottomPadding3;

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
