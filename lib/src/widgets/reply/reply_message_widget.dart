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
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../../inherited_widgets/chat_view_inherited_widget.dart';
import '../../models/config_models/chat_view/reply/replied_message_configuration.dart';
import '../../utils/constants/constants.dart';
import '../../utils/package_strings.dart';
import 'reply_bar.dart';

class ReplyMessageWidget extends StatelessWidget {
  const ReplyMessageWidget({
    required this.replyMessage,
    this.config,
    this.onTap,
    super.key,
  });

  /// The replied message, if the user has replied to any message.
  final ReplyMessage replyMessage;

  /// Provides configurations related to replied message such as text style
  /// padding, margin etc. Also, this widget is located upon chat bubble.
  final RepliedMessageConfiguration? config;

  /// Provides call back when user taps on replied message.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chatController = ChatViewInheritedWidget.of(context)?.chatController;
    final currentUser = chatController?.currentUser;
    final replyBySender = replyMessage.replyBy == currentUser?.id;
    final textTheme = Theme.of(context).textTheme;
    final replyMessageContent = replyMessage.message;
    final messagedUser = chatController?.getUserFromId(replyMessage.replyBy);
    final replyBy =
        replyBySender ? PackageStrings.currentLocale.you : messagedUser?.name;
    final title = replyBy == null
        ? PackageStrings.currentLocale.repliedBy
        : '${PackageStrings.currentLocale.repliedBy} $replyBy';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: config?.margin ??
            const EdgeInsets.only(
              right: horizontalPadding,
              left: horizontalPadding,
              bottom: 4,
            ),
        constraints: BoxConstraints(maxWidth: config?.maxWidth ?? 280),
        child: Column(
          crossAxisAlignment:
              replyBySender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: config?.replyTitleTextStyle ??
                  textTheme.bodyMedium
                      ?.copyWith(fontSize: 14, letterSpacing: 0.3),
            ),
            const SizedBox(height: 6),
            ReplyBar(
              replyBySender: replyBySender,
              verticalBarWidth: config?.verticalBarWidth,
              verticalBarColor: config?.verticalBarColor,
              child: Opacity(
                opacity: config?.opacity ?? 0.8,
                child: replyMessage.messageType.isImage
                    ? Container(
                        height: config?.repliedImageMessageHeight ?? 100,
                        width: config?.repliedImageMessageWidth ?? 80,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image:
                                CachedNetworkImageProvider(replyMessageContent),
                            fit: BoxFit.fill,
                          ),
                          borderRadius: config?.borderRadius ??
                              const BorderRadius.all(Radius.circular(14)),
                        ),
                      )
                    : Container(
                        constraints: BoxConstraints(
                          maxWidth: config?.maxWidth ?? 280,
                        ),
                        padding: config?.padding ??
                            const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                        decoration: BoxDecoration(
                          borderRadius: _borderRadius(
                            replyMessage: replyMessageContent,
                            replyBySender: replyBySender,
                          ),
                          color:
                              config?.backgroundColor ?? Colors.grey.shade500,
                        ),
                        child: replyMessage.messageType.isVoice
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.mic,
                                    color: config?.micIconColor ?? Colors.white,
                                  ),
                                  const SizedBox(width: 2),
                                  if (replyMessage.voiceMessageDuration
                                      case final duration?)
                                    Text(
                                      duration.toHHMMSS(),
                                      style: config?.textStyle,
                                    ),
                                ],
                              )
                            : Text(
                                replyMessageContent,
                                style: config?.textStyle ??
                                    textTheme.bodyMedium
                                        ?.copyWith(color: Colors.black),
                              ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BorderRadiusGeometry _borderRadius({
    required String replyMessage,
    required bool replyBySender,
  }) {
    final threshold = replyBySender ? 37 : 29;
    return config?.borderRadius ??
        (replyMessage.length < threshold
            ? const BorderRadius.all(Radius.circular(replyBorderRadius1))
            : const BorderRadius.all(Radius.circular(replyBorderRadius2)));
  }
}
