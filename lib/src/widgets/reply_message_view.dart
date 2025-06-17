import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../extensions/extensions.dart';
import '../models/models.dart';
import '../utils/constants/constants.dart';
import '../utils/package_strings.dart';
import '../values/typedefs.dart';
import 'chat_textfield_view_builder.dart';
import 'reply_message_type_view.dart';

class ReplyMessageView extends StatefulWidget {
  const ReplyMessageView({
    super.key,
    required this.sendMessageConfig,
    required this.messageConfig,
    required this.builder,
    required this.onChange,
  });

  /// Provides configuration for sending message.
  final SendMessageConfiguration? sendMessageConfig;

  /// Provides configuration for message view.
  final MessageConfiguration? messageConfig;

  /// Provides a callback for the view when replying to message
  final CustomViewForReplyMessage? builder;

  /// Provides a callback when reply message changes.
  final ValueSetter<ReplyMessage> onChange;

  @override
  State<ReplyMessageView> createState() => ReplyMessageViewState();
}

class ReplyMessageViewState extends State<ReplyMessageView> {
  final ValueNotifier<ReplyMessage> replyMessage =
      ValueNotifier(const ReplyMessage());

  ChatUser? currentUser;

  ChatUser? get repliedUser => replyMessage.value.replyTo.isNotEmpty
      ? context.chatViewIW?.chatController
          .getUserFromId(replyMessage.value.replyTo)
      : null;

  String get _replyTo => replyMessage.value.replyTo == currentUser?.id
      ? PackageStrings.currentLocale.you
      : repliedUser?.name ?? '';

  @override
  void initState() {
    replyMessage.addListener(_handleReplyMessageChange);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (chatViewIW != null) {
      currentUser = chatViewIW!.chatController.currentUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    final replyTitle = "${PackageStrings.currentLocale.replyTo} $_replyTo";

    return ChatTextFieldViewBuilder<ReplyMessage>(
      valueListenable: replyMessage,
      builder: (_, state, child) {
        if (state.message.isEmpty) {
          return const SizedBox.shrink();
        }

        return widget.builder?.call(context, state) ??
            Container(
              decoration: BoxDecoration(
                color: widget.sendMessageConfig?.textFieldBackgroundColor ??
                    Colors.white,
                borderRadius: const BorderRadius.vertical(
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
                margin: const EdgeInsets.only(bottom: 2),
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.sendMessageConfig?.replyDialogColor ??
                      Colors.grey.shade200,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            replyTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  widget.sendMessageConfig?.replyTitleColor ??
                                      Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.25,
                            ),
                          ),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.close,
                            color: widget.sendMessageConfig?.closeIconColor ??
                                Colors.black,
                            size: 16,
                          ),
                          onPressed: onClose,
                        ),
                      ],
                    ),
                    ReplyMessageTypeView(
                      message: state,
                      customMessageReplyViewBuilder:
                          widget.messageConfig?.customMessageReplyViewBuilder,
                      sendMessageConfig: widget.sendMessageConfig,
                    ),
                  ],
                ),
              ),
            );
      },
    );
  }

  @override
  void dispose() {
    replyMessage
      ..removeListener(_handleReplyMessageChange)
      ..dispose();
    super.dispose();
  }

  void _handleReplyMessageChange() {
    widget.onChange.call(replyMessage.value);
  }

  void onClose() {
    replyMessage.value = const ReplyMessage();
  }
}
