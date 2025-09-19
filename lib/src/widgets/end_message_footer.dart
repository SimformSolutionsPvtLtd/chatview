import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../extensions/extensions.dart';
import 'pagination_loader.dart';
import 'suggestions/suggestion_list.dart';
import 'type_indicator_widget.dart';

class EndMessageFooter extends StatefulWidget {
  const EndMessageFooter({
    required this.child,
    required this.isNextPageLoading,
    this.loadingWidget,
    this.typingIndicatorNotifier,
    super.key,
  });

  final Widget child;
  final Widget? loadingWidget;
  final ValueListenable<bool>? typingIndicatorNotifier;
  final ValueNotifier<bool> isNextPageLoading;

  @override
  State<EndMessageFooter> createState() => _EndMessageFooterState();
}

class _EndMessageFooterState extends State<EndMessageFooter>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.child,
        if (widget.typingIndicatorNotifier case final notifier?)
          ValueListenableBuilder(
            valueListenable: notifier,
            builder: (_, showIndicator, __) => TypingIndicator(
              typeIndicatorConfig: chatListConfig.typeIndicatorConfig,
              chatBubbleConfig:
                  chatListConfig.chatBubbleConfig?.inComingChatBubbleConfig,
              showIndicator: showIndicator,
            ),
          ),
        const SuggestionList(),
        if (widget.isNextPageLoading.value)
          PaginationLoader(
            listenable: widget.isNextPageLoading,
            loader: widget.loadingWidget,
          ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
