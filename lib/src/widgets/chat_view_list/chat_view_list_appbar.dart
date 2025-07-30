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

class ChatViewListAppBar extends StatelessWidget {
  const ChatViewListAppBar({
    required this.title,
    this.titleMaxLines = 1,
    this.titleTextStyle = const TextStyle(
      fontSize: 20,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    this.titleTextOverflow = TextOverflow.ellipsis,
    this.pinned = true,
    this.automaticallyImplyLeading = true,
    this.backgroundColor = Colors.white,
    this.centerTitle = true,
    this.primary = true,
    this.stretch = false,
    this.snap = false,
    this.surfaceTintColor = Colors.black,
    this.scrolledUnderElevation = 1.0,
    this.leading,
    this.actions,
    super.key,
  });

  /// The title of the app bar.
  final String title;

  /// The style of the title text.
  final TextStyle? titleTextStyle;

  /// The text overflow behavior for the title.
  ///
  /// Defaults to `TextOverflow.ellipsis`.
  final TextOverflow? titleTextOverflow;

  /// The maximum number of lines for the title.
  ///
  /// Defaults to `1`.
  final int? titleMaxLines;

  /// The leading widget, typically an icon or back button.
  final Widget? leading;

  /// The actions to display in the app bar, typically icons.
  final List<Widget>? actions;

  /// Whether the app bar should remain visible when scrolling.
  ///
  /// Defaults to `true`.
  final bool pinned;

  /// Whether the app bar should automatically imply a leading widget.
  ///
  /// Defaults to `true`.
  final bool automaticallyImplyLeading;

  /// The background color of the app bar.
  ///
  /// Defaults to `Colors.white`.
  final Color? backgroundColor;

  /// Whether the title should be centered.
  ///
  /// Defaults to `true`.
  final bool centerTitle;

  /// Whether the app bar is the primary app bar.
  ///
  /// Defaults to `true`.
  final bool primary;

  /// Whether the app bar should stretch when pulled down.
  ///
  /// Defaults to `false`.
  final bool stretch;

  /// Whether the app bar should snap into place when scrolling.
  ///
  /// Defaults to `false`.
  final bool snap;

  /// The surface tint color of the app bar.
  ///
  /// Defaults to `Colors.black`.
  final Color surfaceTintColor;

  /// The elevation of the app bar when it is scrolled under.
  ///
  /// Defaults to `1.0`.
  final double scrolledUnderElevation;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      surfaceTintColor: surfaceTintColor,
      scrolledUnderElevation: scrolledUnderElevation,
      title: Text(
        title,
        maxLines: titleMaxLines,
        overflow: titleTextOverflow,
      ),
      titleTextStyle: titleTextStyle,
      pinned: pinned,
      leading: leading,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
      stretch: stretch,
      primary: primary,
      snap: snap,
    );
  }
}
