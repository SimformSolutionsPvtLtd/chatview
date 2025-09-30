import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';

import '../../values/colors.dart';

class ReplyMessageTile extends StatelessWidget {
  const ReplyMessageTile({
    required this.replyMessage,
    required this.chatController,
    super.key,
  });

  final ReplyMessage? replyMessage;
  final ChatController chatController;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.33,
      color: Color(0xFF232626),
    );
    final reply = replyMessage;
    if (reply == null) {
      return const SizedBox.shrink();
    }
    final replyBySender = reply.replyBy == chatController.currentUser.id;
    final messagedUser = chatController.getUserFromId(reply.replyBy);
    final replyBy =
        replyBySender ? PackageStrings.currentLocale.you : messagedUser.name;
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: replyBySender ? AppColors.uiTwoSenderBgColor : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(9, 9.5, 9, 10.5),
        decoration: const BoxDecoration(
          color: Color(0x0A0A0A0A),
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border(
            left: BorderSide(color: AppColors.uiTwoReplyLineColor, width: 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              replyBy,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                height: 1.36,
                letterSpacing: -0.01,
                fontWeight: FontWeight.w600,
                color: AppColors.uiTwoReplyLineColor,
              ),
            ),
            const SizedBox(height: 2),
            switch (reply.messageType) {
              MessageType.voice => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.mic),
                    const SizedBox(width: 4),
                    if (reply.voiceMessageDuration != null)
                      Text(
                        reply.voiceMessageDuration!.toHHMMSS(),
                        style: textStyle,
                      ),
                  ],
                ),
              MessageType.image => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo,
                      size: 20,
                      color: Colors.grey.shade700,
                    ),
                    Text(
                      PackageStrings.currentLocale.photo,
                      style: textStyle,
                    ),
                  ],
                ),
              MessageType.custom || MessageType.text => Text(
                  reply.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
            },
          ],
        ),
      ),
    );
  }
}
