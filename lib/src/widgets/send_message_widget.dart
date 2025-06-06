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

import 'package:chatview/chatview.dart';
import 'package:chatview/src/extensions/extensions.dart';
import 'package:chatview/src/widgets/chatui_textfield.dart';
import 'package:chatview/src/widgets/reply_message_view.dart';
import 'package:chatview/src/widgets/scroll_to_bottom_button.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../utils/constants/constants.dart';

class SendMessageWidget extends StatefulWidget {
  const SendMessageWidget({
    Key? key,
    required this.onSendTap,
    this.sendMessageConfig,
    this.sendMessageBuilder,
    this.onReplyCallback,
    this.onReplyCloseCallback,
    this.messageConfig,
    this.replyMessageBuilder,
  }) : super(key: key);

  /// Provides call back when user tap on send button on text field.
  final StringMessageCallBack onSendTap;

  /// Provides configuration for text field appearance.
  final SendMessageConfiguration? sendMessageConfig;

  /// Allow user to set custom text field.
  final ReplyMessageWithReturnWidget? sendMessageBuilder;

  /// Provides callback when user swipes chat bubble for reply.
  final ReplyMessageCallBack? onReplyCallback;

  /// Provides call when user tap on close button which is showed in reply pop-up.
  final VoidCallBack? onReplyCloseCallback;

  /// Provides configuration of all types of messages.
  final MessageConfiguration? messageConfig;

  /// Provides a callback for the view when replying to message
  final CustomViewForReplyMessage? replyMessageBuilder;

  @override
  State<SendMessageWidget> createState() => SendMessageWidgetState();
}

class SendMessageWidgetState extends State<SendMessageWidget> {
  final _textEditingController = TextEditingController();
  final ValueNotifier<ReplyMessage> _replyMessage =
      ValueNotifier(const ReplyMessage());

  ReplyMessage get replyMessage => _replyMessage.value;
  final _focusNode = FocusNode();

  ChatUser? get repliedUser => replyMessage.replyTo.isNotEmpty
      ? chatViewIW?.chatController.getUserFromId(replyMessage.replyTo)
      : null;

  String get _replyTo => replyMessage.replyTo == currentUser?.id
      ? PackageStrings.currentLocale.you
      : repliedUser?.name ?? '';

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
          ? widget.sendMessageBuilder!(replyMessage)
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
                              ValueListenableBuilder<ReplyMessage>(
                                builder: (_, state, child) {
                                  final replyTitle =
                                      "${PackageStrings.currentLocale.replyTo} $_replyTo";
                                  if (state.message.isNotEmpty) {
                                    return widget.replyMessageBuilder
                                            ?.call(context, state) ??
                                        Container(
                                          decoration: BoxDecoration(
                                            color: widget.sendMessageConfig
                                                    ?.textFieldBackgroundColor ??
                                                Colors.white,
                                            borderRadius:
                                                const BorderRadius.vertical(
                                              top: Radius.circular(14),
                                            ),
                                          ),
                                          margin: const EdgeInsets.only(
                                            bottom: 17,
                                            right: 0.4,
                                            left: 0.4,
                                          ),
                                          padding: const EdgeInsets.fromLTRB(
                                            leftPadding,
                                            leftPadding,
                                            leftPadding,
                                            30,
                                          ),
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 2),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                              horizontal: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: widget.sendMessageConfig
                                                      ?.replyDialogColor ??
                                                  Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        replyTitle,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: widget
                                                                  .sendMessageConfig
                                                                  ?.replyTitleColor ??
                                                              Colors.deepPurple,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          letterSpacing: 0.25,
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      constraints:
                                                          const BoxConstraints(),
                                                      padding: EdgeInsets.zero,
                                                      icon: Icon(
                                                        Icons.close,
                                                        color: widget
                                                                .sendMessageConfig
                                                                ?.closeIconColor ??
                                                            Colors.black,
                                                        size: 16,
                                                      ),
                                                      onPressed: onCloseTap,
                                                    ),
                                                  ],
                                                ),
                                                ReplyMessageView(
                                                  message: state,
                                                  customMessageReplyViewBuilder:
                                                      widget.messageConfig
                                                          ?.customMessageReplyViewBuilder,
                                                  sendMessageConfig:
                                                      widget.sendMessageConfig,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                },
                                valueListenable: _replyMessage,
                              ),
                              ChatUITextField(
                                focusNode: _focusNode,
                                textEditingController: _textEditingController,
                                onPressed: _onPressed,
                                sendMessageConfig: widget.sendMessageConfig,
                                onRecordingComplete: _onRecordingComplete,
                                onImageSelected: _onImageSelected,
                              )
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
      widget.onSendTap.call(path, replyMessage, MessageType.voice);
      _assignRepliedMessage();
    }
  }

  void _onImageSelected(String imagePath, String error) {
    debugPrint('Call in Send Message Widget');
    if (imagePath.isNotEmpty) {
      widget.onSendTap.call(imagePath, replyMessage, MessageType.image);
      _assignRepliedMessage();
    }
  }

  void _assignRepliedMessage() {
    if (replyMessage.message.isNotEmpty) {
      _replyMessage.value = const ReplyMessage();
    }
  }

  void _onPressed() {
    final messageText = _textEditingController.text.trim();
    _textEditingController.clear();
    if (messageText.isEmpty) return;

    widget.onSendTap.call(
      messageText.trim(),
      replyMessage,
      MessageType.text,
    );
    _assignRepliedMessage();
  }

  void assignReplyMessage(Message message) {
    if (currentUser != null) {
      _replyMessage.value = ReplyMessage(
        message: message.message,
        replyBy: currentUser!.id,
        replyTo: message.sentBy,
        messageType: message.messageType,
        messageId: message.id,
        voiceMessageDuration: message.voiceMessageDuration,
      );
    }
    FocusScope.of(context).requestFocus(_focusNode);
    if (widget.onReplyCallback != null) widget.onReplyCallback!(replyMessage);
  }

  void onCloseTap() {
    _replyMessage.value = const ReplyMessage();
    if (widget.onReplyCloseCallback != null) widget.onReplyCloseCallback!();
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
    _replyMessage.dispose();
    super.dispose();
  }
}
