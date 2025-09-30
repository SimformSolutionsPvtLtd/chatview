import 'dart:io';

import 'package:chatview/chatview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

import '../../values/colors.dart';
import '../../values/icons.dart';

class CustomChatBar extends StatefulWidget {
  const CustomChatBar({
    required this.chatController,
    required this.replyMessage,
    this.onAttachPressed,
    super.key,
  });

  final ChatController chatController;
  final ReplyMessage replyMessage;
  final VoidCallback? onAttachPressed;

  @override
  State<CustomChatBar> createState() => _CustomChatBarState();
}

class _CustomChatBarState extends State<CustomChatBar> {
  RecorderController? controller;
  late ReplyMessage? _replyMessage = widget.replyMessage;
  final voiceRecordingConfig = const VoiceRecordingConfiguration();
  final isRecording = ValueNotifier(false);
  final _focusNode = FocusNode();
  final _textController = TextEditingController();
  final _hasTextNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      controller = RecorderController();
    }
    _textController.addListener(_onTextChanged);
  }

  @override
  Widget build(BuildContext context) {
    if (_replyMessage != null) {
      _replyMessage = widget.replyMessage;
    }
    final repliedUser = _replyMessage?.replyTo.isNotEmpty ?? false
        ? widget.chatController.getUserFromId(_replyMessage?.replyTo ?? '')
        : null;
    String replyTo =
        _replyMessage?.replyTo == widget.chatController.currentUser.id
            ? PackageStrings.currentLocale.you
            : repliedUser?.name ?? '';
    return Container(
      color: AppColors.uiTwoBackground,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_replyMessage?.message.isNotEmpty ?? false)
              Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 7.5, 7.5),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: AppColors.uiTwoReplyLineColor,
                      width: 4,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            replyTo,
                            style: const TextStyle(
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              height: 1.3571428571,
                              letterSpacing: -0.01,
                              color: Color(0xFFD42A66),
                            ),
                          ),
                          const SizedBox(height: 1.5),
                          Text(
                            _replyMessage?.message ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.33,
                              color: Color(0xFF0A0A0A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox.square(
                      dimension: 32,
                      child: IconButton(
                        onPressed: () => ChatView.closeReplyMessageView(
                          context,
                        ),
                        padding: EdgeInsets.zero,
                        icon: SvgPicture.asset(AppIcons.closeCircular),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 5.5, 9, 5.5),
              child: ValueListenableBuilder(
                valueListenable: isRecording,
                builder: (context, isRecordingValue, _) => Row(
                  children: <Widget>[
                    if (!isRecordingValue) ...[
                      SizedBox.square(
                        dimension: 32,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: widget.onAttachPressed,
                          icon: SvgPicture.asset(AppIcons.plus),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          border: Border.fromBorderSide(
                            BorderSide(width: 0.33, color: Color(0xFFB2B2B2)),
                          ),
                        ),
                        child: Row(
                          children: [
                            if (isRecordingValue &&
                                controller != null &&
                                !kIsWeb)
                              Expanded(
                                child: AudioWaveforms(
                                  size: const Size(double.maxFinite, 50),
                                  recorderController: controller!,
                                  margin: voiceRecordingConfig.margin,
                                  padding: voiceRecordingConfig.padding ??
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: voiceRecordingConfig.decoration ??
                                      BoxDecoration(
                                        color: voiceRecordingConfig
                                            .backgroundColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                  waveStyle: voiceRecordingConfig.waveStyle ??
                                      WaveStyle(
                                        extendWaveform: true,
                                        showMiddleLine: false,
                                        waveColor: voiceRecordingConfig
                                                .waveStyle?.waveColor ??
                                            Colors.black,
                                      ),
                                ),
                              )
                            else
                              Expanded(
                                child: TextField(
                                  maxLines: null,
                                  focusNode: _focusNode,
                                  controller: _textController,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    letterSpacing: -0.02,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 4, 16, 4),
                                    hintStyle: TextStyle(
                                      color: Color(0xFF999999),
                                      fontSize: 16,
                                    ),
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                ),
                              ),
                            if (!isRecordingValue) ...[
                              SizedBox.square(
                                dimension: 24,
                                child: EmojiPickerActionButton(
                                  context: context,
                                  style: IconButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                  ),
                                  icon: SvgPicture.asset(AppIcons.sticker),
                                  onPressed: (emoji, replyMessage) {
                                    if (emoji?.isEmpty ?? true) return;
                                    _textController.text =
                                        _textController.text + emoji!;
                                  },
                                ),
                              ),
                              const SizedBox(width: 9),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    AnimatedSize(
                      alignment: Alignment.centerRight,
                      curve: Curves.easeInOut,
                      duration: const Duration(milliseconds: 400),
                      child: ValueListenableBuilder(
                          valueListenable: _hasTextNotifier,
                          builder: (_, hasText, __) {
                            if (isRecordingValue) {
                              return Row(
                                children: [
                                  SizedBox.square(
                                    dimension: 32,
                                    child: IconButton(
                                      onPressed: _cancelRecording,
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                          Icons.stop_circle_outlined),
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  SizedBox.square(
                                    dimension: 32,
                                    child: IconButton(
                                      onPressed: _recordOrStop,
                                      padding: EdgeInsets.zero,
                                      style: IconButton.styleFrom(
                                        backgroundColor: AppColors.uiTwoGreen,
                                      ),
                                      icon: SvgPicture.asset(AppIcons.send),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Row(
                              children: hasText
                                  ? [
                                      SizedBox.square(
                                        dimension: 32,
                                        child: IconButton(
                                          onPressed: _sendMessage,
                                          padding: EdgeInsets.zero,
                                          style: IconButton.styleFrom(
                                            backgroundColor:
                                                AppColors.uiTwoGreen,
                                          ),
                                          icon: SvgPicture.asset(AppIcons.send),
                                        ),
                                      ),
                                    ]
                                  : [
                                      SizedBox.square(
                                        dimension: 32,
                                        child: CameraActionButton(
                                          icon: SvgPicture.asset(
                                            AppIcons.cameraOutline,
                                          ),
                                          style: IconButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                          ),
                                          onPressed: (path, replyMessage) {
                                            if (path?.isEmpty ?? true) return;
                                            ChatView.closeReplyMessageView(
                                                context);
                                            widget.chatController.addMessage(
                                              Message(
                                                id: DateTime.now()
                                                    .millisecondsSinceEpoch
                                                    .toString(),
                                                message: path!,
                                                createdAt: DateTime.now(),
                                                messageType: MessageType.image,
                                                replyMessage: _replyMessage ??
                                                    const ReplyMessage(),
                                                sentBy: widget.chatController
                                                    .currentUser.id,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      if (!kIsWeb) ...[
                                        const SizedBox(width: 7),
                                        SizedBox.square(
                                          dimension: 32,
                                          child: IconButton(
                                            onPressed: _recordOrStop,
                                            padding: EdgeInsets.zero,
                                            icon:
                                                SvgPicture.asset(AppIcons.mic),
                                          ),
                                        ),
                                      ],
                                    ],
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _hasTextNotifier.value = _textController.text.trim().isNotEmpty;
  }

  Future<void> _cancelRecording() async {
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

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      ChatView.closeReplyMessageView(context);
      widget.chatController.addMessage(
        Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: text,
          createdAt: DateTime.now(),
          replyMessage: _replyMessage ?? const ReplyMessage(),
          messageType: MessageType.text,
          sentBy: widget.chatController.currentUser.id,
        ),
      );
      _textController.clear();
      _hasTextNotifier.value = false;
    }
  }

  Future<void> _recordOrStop() async {
    if (!isRecording.value) {
      await controller?.record(
        sampleRate: voiceRecordingConfig.sampleRate,
        bitRate: voiceRecordingConfig.bitRate,
        androidEncoder: voiceRecordingConfig.androidEncoder,
        iosEncoder: voiceRecordingConfig.iosEncoder,
        androidOutputFormat: voiceRecordingConfig.androidOutputFormat,
      );
      isRecording.value = true;
    } else {
      final path = await controller?.stop();
      isRecording.value = false;
      if (path?.isEmpty ?? true) return;
      if (mounted) ChatView.closeReplyMessageView(context);
      widget.chatController.addMessage(
        Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: path!,
          createdAt: DateTime.now(),
          messageType: MessageType.voice,
          replyMessage: _replyMessage ?? const ReplyMessage(),
          sentBy: widget.chatController.currentUser.id,
        ),
      );
    }
  }
}
