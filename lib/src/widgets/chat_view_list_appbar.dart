import 'package:flutter/material.dart';

class ChatViewListAppBar extends StatelessWidget {
  const ChatViewListAppBar({
    super.key,
    required this.title,
    this.titleTextStyle = const TextStyle(
      fontSize: 20,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    this.titleTextOverflow = TextOverflow.ellipsis,
    this.leading,
    this.actions,
    this.pinned = true,
    this.automaticallyImplyLeading = true,
    this.backgroundColor = Colors.white,
    this.centerTitle = true,
    this.primary = true,
    this.stretch = false,
    this.snap = false,
    this.surfaceTintColor = Colors.black,
    this.scrolledUnderElevation = 1.0,
  });

  /// The title of the app bar.
  final String title;

  /// The style of the title text.
  final TextStyle? titleTextStyle;

  /// The text overflow behavior for the title.
  final TextOverflow? titleTextOverflow;

  /// The leading widget, typically an icon or back button.
  final Widget? leading;

  /// The actions to display in the app bar, typically icons.
  final List<Widget>? actions;

  /// Whether the app bar should remain visible when scrolling.
  final bool pinned;

  /// Whether the app bar should automatically imply a leading widget.
  final bool automaticallyImplyLeading;

  /// The background color of the app bar.
  final Color? backgroundColor;

  /// Whether the title should be centered.
  final bool centerTitle;

  /// Whether the app bar is the primary app bar.
  final bool primary;

  /// Whether the app bar should stretch when pulled down.
  final bool stretch;

  /// Whether the app bar should snap into place when scrolling.
  final bool snap;

  /// The surface tint color of the app bar.
  final Color surfaceTintColor;

  /// The elevation of the app bar when it is scrolled under.
  final double scrolledUnderElevation;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      surfaceTintColor: surfaceTintColor,
      scrolledUnderElevation: scrolledUnderElevation,
      title: Text(
        title,
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
