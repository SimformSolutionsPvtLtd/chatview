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

import '../../models/config_models/mention_configuration.dart';
import '../../utils/package_strings.dart';
import '../chat_view_inherited_widget.dart';
import '../profile_image_widget.dart';
import 'mention_config_inherited_widget.dart';
import 'mention_text_editing_controller.dart';

/// The suggestion dropdown shown above the text field while the user types a
/// mention. It reacts to [MentionTextEditingController.queryNotifier], filters
/// the group members (auto-sourced from the chat controller) and the optional
/// `@everyone` entry, and selects a mention on tap.
class MentionList extends StatelessWidget {
  const MentionList({super.key, required this.controller});

  /// The mention-aware controller driving this list.
  final MentionTextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final mentionConfig = MentionConfigIW.of(context)?.mentionConfig;
    final chatController = ChatViewInheritedWidget.of(context)?.chatController;
    if (mentionConfig == null || chatController == null) {
      return const SizedBox.shrink();
    }
    final listConfig = mentionConfig.listConfig;

    return ValueListenableBuilder<MentionQuery?>(
      valueListenable: controller.queryNotifier,
      builder: (context, query, _) {
        final candidates = query == null
            ? const <MentionedUser>[]
            : _candidates(query.text, chatController, mentionConfig);

        Widget child;
        if (query == null ||
            (candidates.isEmpty && listConfig.emptyBuilder == null)) {
          child = const SizedBox(width: double.infinity);
        } else if (candidates.isEmpty) {
          child =
              _decorate(context, listConfig, listConfig.emptyBuilder!(context));
        } else {
          child = _decorate(
            context,
            listConfig,
            ListView.builder(
              shrinkWrap: true,
              padding:
                  listConfig.padding ?? const EdgeInsets.symmetric(vertical: 4),
              itemCount: candidates.length,
              itemBuilder: (context, index) =>
                  _item(context, mentionConfig, candidates[index]),
            ),
          );
        }

        return AnimatedSize(
          duration: listConfig.animationDuration,
          curve: Curves.easeOut,
          alignment: Alignment.bottomCenter,
          child: child,
        );
      },
    );
  }

  /// Builds the filtered, ordered list of taggable entries for [rawQuery].
  List<MentionedUser> _candidates(
    String rawQuery,
    ChatController chatController,
    MentionConfiguration mentionConfig,
  ) {
    final query = rawQuery.trim().toLowerCase();

    final source = <ChatUser>[
      if (!mentionConfig.excludeCurrentUser) chatController.currentUser,
      ...chatController.otherUsers,
    ];

    final results = <MentionedUser>[];

    if (mentionConfig.showEveryone) {
      final everyoneName =
          mentionConfig.everyoneTitle ?? PackageStrings.currentLocale.everyone;
      if (query.isEmpty || everyoneName.toLowerCase().contains(query)) {
        results.add(
          MentionedUser.everyone(
            id: mentionConfig.everyoneId,
            name: everyoneName,
          ),
        );
      }
    }

    for (final user in source) {
      if (query.isEmpty || user.name.toLowerCase().contains(query)) {
        results.add(MentionedUser.fromChatUser(user));
      }
    }
    return results;
  }

  Widget _decorate(
    BuildContext context,
    MentionListConfig listConfig,
    Widget content,
  ) {
    final constrained = ConstrainedBox(
      constraints: BoxConstraints(maxHeight: listConfig.maxHeight),
      child: content,
    );

    final Widget surface;
    if (listConfig.decoration != null) {
      surface = Container(
        decoration: listConfig.decoration,
        clipBehavior: Clip.hardEdge,
        child: constrained,
      );
    } else {
      surface = Material(
        elevation: listConfig.elevation,
        color: listConfig.backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: listConfig.borderRadius ?? BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: constrained,
      );
    }

    return Padding(
      padding: listConfig.margin ?? const EdgeInsets.fromLTRB(8, 0, 8, 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: surface,
      ),
    );
  }

  Widget _item(
    BuildContext context,
    MentionConfiguration mentionConfig,
    MentionedUser mention,
  ) {
    final listConfig = mentionConfig.listConfig;
    return InkWell(
      onTap: () => controller.selectMention(mention),
      child: listConfig.itemBuilder?.call(context, mention) ??
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                if (listConfig.showAvatar) ...[
                  _avatar(mention, listConfig),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    mention.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: listConfig.itemTextStyle ??
                        const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _avatar(MentionedUser mention, MentionListConfig listConfig) {
    if (mention.isEveryone) {
      return listConfig.everyoneAvatar ??
          CircleAvatar(
            radius: listConfig.avatarRadius,
            child: const Icon(Icons.groups, size: 20),
          );
    }
    final user = mention.user;
    return ProfileImageWidget(
      circleRadius: listConfig.avatarRadius,
      imageUrl: user?.profilePhoto,
      imageType: user?.imageType ?? ImageType.network,
      defaultAvatarImage: user?.defaultAvatarImage ?? Constants.profileImage,
      assetImageErrorBuilder: user?.assetImageErrorBuilder,
      networkImageErrorBuilder: user?.networkImageErrorBuilder,
      networkImageProgressIndicatorBuilder:
          user?.networkImageProgressIndicatorBuilder,
    );
  }
}
