import 'package:chatview/src/extensions/extensions.dart';
import 'package:flutter/material.dart';

class ScrollToBottomButton extends StatefulWidget {
  const ScrollToBottomButton({super.key});

  @override
  ScrollToBottomButtonState createState() => ScrollToBottomButtonState();
}

class ScrollToBottomButtonState extends State<ScrollToBottomButton> {
  bool isButtonVisible = false;
  ScrollController? scrollController;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController = chatViewIW?.chatController.scrollController;
      scrollController?.addListener(_updateScrollButtonVisibility);
    });
  }

  void _updateScrollButtonVisibility() {
    if (!mounted) return;

    final double currentOffset = scrollController?.offset ?? 0;
    final double buttonDisplayOffset = chatListConfig.scrollToBottomButtonConfig?.buttonDisplayOffset ?? 300;
    final bool isOffsetCrossedLimit = currentOffset > buttonDisplayOffset;
    if (isOffsetCrossedLimit) {
      if (!isButtonVisible) {
        setState(() {
          isButtonVisible = true;
        });
      }
    } else {
      if (isButtonVisible) {
        setState(() {
          isButtonVisible = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrollToBottomButtonConfig = chatListConfig.scrollToBottomButtonConfig;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: isButtonVisible ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: InkWell(
            onTap: () {
              scrollToBottomButtonConfig?.onClick?.call();
              final scrollController = chatViewIW?.chatController.scrollController;
              scrollController?.animateTo(
                0,
                duration: scrollToBottomButtonConfig?.scrollAnimationDuration ?? const Duration(milliseconds: 200),
                curve: Curves.linear,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: scrollToBottomButtonConfig?.borderRadius ?? BorderRadius.circular(50),
                border: scrollToBottomButtonConfig?.border ?? Border.all(color: Colors.grey),
                color: scrollToBottomButtonConfig?.backgroundColor ?? Colors.white,
              ),
              padding: const EdgeInsets.all(4),
              child: scrollToBottomButtonConfig?.icon ??
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey,
                    weight: 10,
                    size: 30,
                  ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    scrollController?.removeListener(_updateScrollButtonVisibility);
    scrollController?.dispose();
    super.dispose();
  }
}
