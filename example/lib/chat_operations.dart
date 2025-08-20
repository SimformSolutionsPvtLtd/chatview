import 'dart:math';

import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';

class ChatOperations extends StatelessWidget {
  const ChatOperations({required this.controller, super.key});

  final ChatViewListController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          child: const Icon(Icons.add),
          onPressed: () {
            controller.addChat(
              ChatViewListItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: 'New Chat ${DateTime.now().millisecondsSinceEpoch}',
                lastMessage: Message(
                  message: 'Hello, this is a new chat!',
                  createdAt: DateTime.now(),
                  sentBy: 'User',
                  id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 6),
        FloatingActionButton.small(
          child: const Icon(Icons.remove),
          onPressed: () {
            final key = controller.chatListMap.keys.firstOrNull;
            if (key == null) return;
            controller.removeChat(key);
          },
        ),
        const SizedBox(width: 6),
        FloatingActionButton.small(
          child: const Icon(Icons.edit),
          onPressed: () {
            final randomChatIndex =
                Random().nextInt(controller.chatListMap.length);
            final chatId =
                controller.chatListMap.keys.elementAt(randomChatIndex);

            controller.updateChat(
              chatId,
              (previousChat) {
                final newPinStatus = switch (previousChat.settings.pinStatus) {
                  PinStatus.pinned => PinStatus.unpinned,
                  PinStatus.unpinned => PinStatus.pinned,
                };
                return previousChat.copyWith(
                  settings: previousChat.settings.copyWith(
                    pinStatus: newPinStatus,
                    pinTime: newPinStatus.isPinned ? DateTime.now() : null,
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(width: 6),
        FloatingActionButton.small(
          child: const Icon(Icons.person),
          onPressed: () {
            final randomChatIndex =
                Random().nextInt(controller.chatListMap.length);
            final chatId =
                controller.chatListMap.keys.elementAt(randomChatIndex);
            controller.updateChat(
              chatId,
              (previousChat) => previousChat.copyWith(
                name: 'Updated Chat ${Random().nextInt(100)}',
              ),
            );
          },
        ),
        const SizedBox(width: 6),
        FloatingActionButton.small(
          child: const Icon(Icons.more_horiz),
          onPressed: () {
            final chatId = controller.chatListMap.keys.elementAt(0);
            controller.updateChat(
              chatId,
              (previousChat) => previousChat.copyWith(
                typingUsers: previousChat.typingUsers.isEmpty
                    ? {const ChatUser(id: '1', name: 'John Doe')}
                    : {},
              ),
            );
          },
        ),
        const SizedBox(width: 6),
        FloatingActionButton.small(
          child: const Icon(Icons.message),
          onPressed: () {
            final randomChatIndex =
                Random().nextInt(controller.chatListMap.length);
            final chatId =
                controller.chatListMap.keys.elementAt(randomChatIndex);
            final randomId = Random().nextInt(100);
            controller.updateChat(
              chatId,
              (previousChat) => previousChat.copyWith(
                lastMessage: Message(
                  message: 'Random message $randomId',
                  createdAt: DateTime.now(),
                  sentBy: previousChat.lastMessage?.sentBy ?? '',
                  id: '$randomId',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
