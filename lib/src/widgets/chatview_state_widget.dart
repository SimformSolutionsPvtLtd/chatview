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

import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../extensions/extensions.dart';
import '../models/config_models/chat_view_states_configuration.dart';
import '../utils/package_strings.dart';
import '../values/enumeration.dart';

class ChatViewStateWidget extends StatelessWidget {
  const ChatViewStateWidget({
    Key? key,
    this.chatViewStateWidgetConfig,
    required this.chatViewState,
    this.onReloadButtonTap,
  }) : super(key: key);

  /// Provides configuration of chat view's different states such as text styles,
  /// widgets and etc.
  final ChatViewStateWidgetConfiguration? chatViewStateWidgetConfig;

  /// Provides current state of chat view.
  final ChatViewState chatViewState;

  /// Provides callback when user taps on reload button in error and no messages
  /// state.
  final VoidCallback? onReloadButtonTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: chatViewStateWidgetConfig?.widget ??
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                (chatViewStateWidgetConfig?.title
                    .getChatViewStateTitle(chatViewState))!,
                style: chatViewStateWidgetConfig?.titleTextStyle ??
                    const TextStyle(
                      fontSize: 22,
                    ),
              ),
              if (chatViewStateWidgetConfig?.subTitle != null)
                Text(
                  (chatViewStateWidgetConfig?.subTitle)!,
                  style: chatViewStateWidgetConfig?.subTitleTextStyle,
                ),
              if (chatViewState.isLoading)
                CircularProgressIndicator(
                  color: chatViewStateWidgetConfig?.loadingIndicatorColor,
                ),
              if (chatViewStateWidgetConfig?.imageWidget != null)
                (chatViewStateWidgetConfig?.imageWidget)!,
              if (chatViewStateWidgetConfig?.reloadButton != null)
                (chatViewStateWidgetConfig?.reloadButton)!,
              if (chatViewStateWidgetConfig != null &&
                  (chatViewStateWidgetConfig?.showDefaultReloadButton)! &&
                  chatViewStateWidgetConfig?.reloadButton == null &&
                  (chatViewState.isError || chatViewState.noMessages)) ...[
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: onReloadButtonTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        chatViewStateWidgetConfig?.reloadButtonColor ??
                            const Color(0xffEE5366),
                  ),
                  child: Text(PackageStrings.currentLocale.reload),
                )
              ]
            ],
          ),
    );
  }
}
