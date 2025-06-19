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

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/chat_bubble.dart';
import '../models/config_models/message_reaction_configuration.dart';
import '../models/config_models/voice_message_configuration.dart';
import 'reaction_widget.dart';

class VoiceMessageView extends StatefulWidget {
  const VoiceMessageView({
    Key? key,
    required this.screenWidth,
    required this.message,
    required this.isMessageBySender,
    this.inComingChatBubbleConfig,
    this.outgoingChatBubbleConfig,
    this.onMaxDuration,
    this.messageReactionConfig,
    this.config,
  }) : super(key: key);

  /// Provides configuration related to voice message.
  final VoiceMessageConfiguration? config;

  /// Allow user to set width of chat bubble.
  final double screenWidth;

  /// Provides message instance of chat.
  final Message message;
  final ValueSetter<int>? onMaxDuration;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Provides configuration of reaction appearance in chat bubble.
  final MessageReactionConfiguration? messageReactionConfig;

  /// Provides configuration of chat bubble appearance from other user of chat.
  final ChatBubble? inComingChatBubbleConfig;

  /// Provides configuration of chat bubble appearance from current user of chat.
  final ChatBubble? outgoingChatBubbleConfig;

  @override
  State<VoiceMessageView> createState() => _VoiceMessageViewState();
}

class _VoiceMessageViewState extends State<VoiceMessageView> {
  late PlayerController controller;
  late StreamSubscription<PlayerState> playerStateSubscription;

  final ValueNotifier<PlayerState> _playerState =
      ValueNotifier(PlayerState.stopped);

  PlayerState get playerState => _playerState.value;

  PlayerWaveStyle playerWaveStyle = const PlayerWaveStyle(scaleFactor: 70);

  @override
  void initState() {
    super.initState();
    controller = PlayerController()
      ..preparePlayer(
        path: widget.message.message,
        noOfSamples: widget.config?.playerWaveStyle
                ?.getSamplesForWidth(widget.screenWidth * 0.5) ??
            playerWaveStyle.getSamplesForWidth(widget.screenWidth * 0.5),
      ).whenComplete(() => widget.onMaxDuration?.call(controller.maxDuration));
    playerStateSubscription = controller.onPlayerStateChanged
        .listen((state) => _playerState.value = state);
  }

  @override
  void dispose() {
    playerStateSubscription.cancel();
    controller.dispose();
    _playerState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: widget.config?.decoration ??
              BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: widget.isMessageBySender
                    ? widget.outgoingChatBubbleConfig?.color
                    : widget.inComingChatBubbleConfig?.color,
              ),
          padding: widget.config?.padding ??
              const EdgeInsets.symmetric(horizontal: 8),
          margin: widget.config?.margin ??
              EdgeInsets.symmetric(
                horizontal: 8,
                vertical: widget.message.reaction.reactions.isNotEmpty ? 15 : 0,
              ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<PlayerState>(
                builder: (context, state, child) {
                  return IconButton(
                    onPressed: _playOrPause,
                    icon:
                        state.isStopped || state.isPaused || state.isInitialised
                            ? widget.config?.playIcon ??
                                const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                )
                            : widget.config?.pauseIcon ??
                                const Icon(
                                  Icons.stop,
                                  color: Colors.white,
                                ),
                  );
                },
                valueListenable: _playerState,
              ),
              AudioFileWaveforms(
                size: Size(widget.screenWidth * 0.50, 60),
                playerController: controller,
                waveformType: WaveformType.fitWidth,
                playerWaveStyle:
                    widget.config?.playerWaveStyle ?? playerWaveStyle,
                padding: widget.config?.waveformPadding ??
                    const EdgeInsets.only(right: 10),
                margin: widget.config?.waveformMargin,
                animationCurve: widget.config?.animationCurve ?? Curves.easeIn,
                animationDuration: widget.config?.animationDuration ??
                    const Duration(milliseconds: 500),
                enableSeekGesture: widget.config?.enableSeekGesture ?? true,
              ),
            ],
          ),
        ),
        if (widget.message.reaction.reactions.isNotEmpty)
          ReactionWidget(
            isMessageBySender: widget.isMessageBySender,
            reaction: widget.message.reaction,
            messageReactionConfig: widget.messageReactionConfig,
          ),
      ],
    );
  }

  void _playOrPause() {
    assert(
      defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android,
      "Voice messages are only supported with android and ios platform",
    );
    if (playerState.isInitialised ||
        playerState.isPaused ||
        playerState.isStopped) {
      controller.startPlayer();
      controller.setFinishMode(finishMode: FinishMode.pause);
    } else {
      controller.pausePlayer();
    }
  }
}
