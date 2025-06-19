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

import 'package:flutter/material.dart';

import '../extensions/extensions.dart';

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
    final double buttonDisplayOffset =
        chatListConfig.scrollToBottomButtonConfig?.buttonDisplayOffset ?? 300;
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
    final scrollToBottomButtonConfig =
        chatListConfig.scrollToBottomButtonConfig;
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
              final scrollController =
                  chatViewIW?.chatController.scrollController;
              scrollController?.animateTo(
                0,
                duration: scrollToBottomButtonConfig?.scrollAnimationDuration ??
                    const Duration(milliseconds: 200),
                curve: Curves.linear,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: scrollToBottomButtonConfig?.borderRadius ??
                    BorderRadius.circular(50),
                border: scrollToBottomButtonConfig?.border ??
                    Border.all(color: Colors.grey),
                color:
                    scrollToBottomButtonConfig?.backgroundColor ?? Colors.white,
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
    super.dispose();
  }
}
