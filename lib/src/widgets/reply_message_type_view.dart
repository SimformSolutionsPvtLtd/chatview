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
import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../models/config_models/send_message_configuration.dart';
import '../utils/package_strings.dart';
import '../values/typedefs.dart';

class ReplyMessageTypeView extends StatelessWidget {
  const ReplyMessageTypeView({
    super.key,
    required this.message,
    this.customMessageReplyViewBuilder,
    this.sendMessageConfig,
  });

  /// Provides reply message instance of chat.
  final ReplyMessage message;

  /// Provides builder callback to build the custom view of the reply message view.
  final CustomMessageReplyViewBuilder? customMessageReplyViewBuilder;

  /// Provides configuration for send message
  final SendMessageConfiguration? sendMessageConfig;

  @override
  Widget build(BuildContext context) {
    return switch (message.messageType) {
      MessageType.voice => Row(
          children: [
            Icon(
              Icons.mic,
              color: sendMessageConfig?.micIconColor,
            ),
            const SizedBox(width: 4),
            if (message.voiceMessageDuration != null)
              Text(
                message.voiceMessageDuration!.toHHMMSS(),
                style: TextStyle(
                  fontSize: 12,
                  color: sendMessageConfig?.replyMessageColor ?? Colors.black,
                ),
              ),
          ],
        ),
      MessageType.image => Row(
          children: [
            Icon(
              Icons.photo,
              size: 20,
              color:
                  sendMessageConfig?.replyMessageColor ?? Colors.grey.shade700,
            ),
            Text(
              PackageStrings.currentLocale.photo,
              style: TextStyle(
                color: sendMessageConfig?.replyMessageColor ?? Colors.black,
              ),
            ),
          ],
        ),
      MessageType.custom when customMessageReplyViewBuilder != null =>
        customMessageReplyViewBuilder!(message),
      MessageType.custom || MessageType.text => Text(
          message.message,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: sendMessageConfig?.replyMessageColor ?? Colors.black,
          ),
        ),
    };
  }
}
