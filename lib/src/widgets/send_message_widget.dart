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
import 'selected_image_view_widget.dart';

class SendMessageWidget extends StatefulWidget {
  const SendMessageWidget({
    Key? key,
    required this.onSendTap,
    this.sendMessageConfig,
    this.sendMessageBuilder,
    this.messageConfig,
    this.replyMessageBuilder,
  }) : super(key: key);

  /// Provides call back when user tap on send button on text field.
  final StringMessageCallBack onSendTap;

  /// Provides configuration for text field appearance.
  final SendMessageConfiguration? sendMessageConfig;

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

  final GlobalKey<SelectedImageViewWidgetState> _selectedImageViewWidgetKey =
      GlobalKey();
  ReplyMessage _replyMessage = const ReplyMessage();

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
    final scrollToBottomButtonConfig =
        chatListConfig.scrollToBottomButtonConfig;
    return Align(
      alignment: Alignment.bottomCenter,
      child: widget.sendMessageBuilder != null
          ? widget.sendMessageBuilder!(_replyMessage)
          : SizedBox(
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
                      color:
                          chatListConfig.chatBackgroundConfig.backgroundColor ??
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
                        if (chatViewIW?.featureActiveConfig
                                .enableScrollToBottomButton ??
                            true)
                          Align(
                            alignment: scrollToBottomButtonConfig
                                    ?.alignment?.alignment ??
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
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              ReplyMessageView(
                                key: _replyMessageTextFieldViewKey,
                                sendMessageConfig: widget.sendMessageConfig,
                                messageConfig: widget.messageConfig,
                                builder: widget.replyMessageBuilder,
                                onChange: (value) => _replyMessage = value,
                              ),
                              if (widget.sendMessageConfig
                                      ?.shouldSendImageWithText ??
                                  false)
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
                                          ?.shouldSendImageWithText ??
                                      false) {
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
    debugPrint('Call in Send Message Widget');
    if (imagePath.isNotEmpty) {
      widget.onSendTap.call(
        imagePath,
        _replyMessage,
        MessageType.image,
      );
      onCloseTap();
    }
  }

  void _onPressed() {
    final messageText = _textEditingController.text.trim();
    _textEditingController.clear();
    if (messageText.isEmpty) return;

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

  void assignReplyMessage(Message message) {
    if (currentUser == null) {
      return;
    }
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
