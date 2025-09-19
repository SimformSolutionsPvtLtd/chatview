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
import '../models/config_models/chat_view_state_widget_config.dart';
import '../utils/package_strings.dart';
import '../values/enumeration.dart';
import 'chat_view_list/adaptive_progress_indicator.dart';

class ChatViewStateWidget extends StatelessWidget {
  const ChatViewStateWidget({
    required this.type,
    required this.config,
    required this.chatViewState,
    this.title,
    this.onReloadButtonTap,
    super.key,
  });

  final String? title;

  /// Creates a widget that displays different states of the chat view.
  final ChatViewStateType type;

  /// Provides configuration of chat view's different states such as text styles,
  /// widgets and etc.
  final ChatViewStateWidgetConfiguration config;

  /// Provides current state of chat view.
  final ChatViewState chatViewState;

  /// Provides callback when user taps on reload button in error and no messages
  /// state.
  final VoidCallback? onReloadButtonTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: config.widget ??
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title ??
                    switch (type) {
                      ChatViewStateType.chatView =>
                        config.title.getChatViewStateTitle(chatViewState),
                      ChatViewStateType.chatViewList =>
                        config.title.getChatViewListStateTitle(chatViewState),
                    },
                style: config.titleTextStyle,
              ),
              if (config.subTitle case final subtitle?)
                Text(
                  subtitle,
                  style: config.subTitleTextStyle,
                ),
              if (chatViewState.isLoading)
                AdaptiveProgressIndicator(
                  color: config.loadingIndicatorColor,
                  size: config.loadingIndicatorSize,
                ),
              if (config.imageWidget case final image?) image,
              if (config.reloadButton case final reload?)
                reload
              else if (config.showDefaultReloadButton &&
                  (chatViewState.isError || chatViewState.noMessages)) ...[
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: onReloadButtonTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: config.reloadButtonColor,
                  ),
                  child: Text(PackageStrings.currentLocale.reload),
                )
              ]
            ],
          ),
    );
  }
}
