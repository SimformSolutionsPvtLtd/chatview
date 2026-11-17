import 'package:flutter/material.dart';

import '../../extensions/extensions.dart';

/// Default builder when the message has got seen as of now
/// is visible at the bottom of the chat bubble
class MessageLastSeenAgo extends StatelessWidget {
  const MessageLastSeenAgo({required this.createAt, super.key});

  final DateTime createAt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Text(
        'Seen ${createAt.applicationDateFormatter}    ',
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }
}
