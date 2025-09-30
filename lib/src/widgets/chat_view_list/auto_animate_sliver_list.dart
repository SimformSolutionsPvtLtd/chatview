import 'dart:async';

import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../../values/typedefs.dart';

/// A sliver list that automatically animates only the items that
/// move to different positions
class AutoAnimateSliverList<T> extends StatefulWidget {
  const AutoAnimateSliverList({
    required this.items,
    required this.builder,
    required this.controller,
    this.animationCurve = Curves.easeInOut,
    this.separatorBuilder,
    super.key,
  });

  final List<T> items;
  final Curve animationCurve;
  final AutoAnimateItemBuilder<T> builder;
  final AutoAnimateSliverListController<T> controller;
  final AutoAnimateSeparatorBuilder? separatorBuilder;

  @override
  State<AutoAnimateSliverList<T>> createState() =>
      AutoAnimateSliverListState<T>();
}

class AutoAnimateSliverListState<T> extends State<AutoAnimateSliverList<T>>
    with TickerProviderStateMixin {
  AutoAnimateSliverListController<T> get _controller => widget.controller;

  StreamSubscription<void>? _updateSubscription;

  @override
  void initState() {
    super.initState();
    _updateSubscription ??= _controller.updateStream.listen(
      (_) {
        if (mounted) setState(() {});
      },
    );
    _controller.initialize(tickerProvider: this);
  }

  @override
  void didUpdateWidget(AutoAnimateSliverList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Don't update items if we're currently adding or removing an item
    _controller.updateItemsWithAnimation(
      tickerProvider: this,
      updatedItems: widget.items,
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = _controller.currentItems.length;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: itemCount,
        (context, index) {
          if (index < 0 || index >= itemCount) return const SizedBox.shrink();

          final item = _controller.currentItems[index];
          final key = _controller.getItemKey(item);
          final itemState = _controller.getState(key);
          final isLast = index == itemCount - 1;

          final itemWidget = widget.builder(context, index, isLast, item);
          final separatorBuilder =
              widget.separatorBuilder?.call(context, index);

          // Build combined child (item + optional separator) so they animate together.
          final combinedChild = separatorBuilder == null
              ? itemWidget
              : Column(
                  key: ValueKey('auto_animate_combined_${key}_$index'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widget.builder(context, index, isLast, item),
                    // Give separator its own key for state retention within column
                    KeyedSubtree(
                      key: ValueKey('auto_animate_separator_${key}_$index'),
                      child: separatorBuilder,
                    ),
                  ],
                );

          if (itemState == null) {
            return KeyedSubtree(
              key: _controller.getItemGlobalKey(key),
              child: combinedChild,
            );
          }

          final isMoving = itemState.isMoving;
          final movingOffset = itemState.moveOffset;

          final moveAnimation = CurvedAnimation(
            parent: itemState.moveController,
            curve: widget.animationCurve,
          );

          return AnimatedBuilder(
            key: _controller.getItemGlobalKey(key),
            animation: moveAnimation,
            builder: (context, child) {
              double currentOffset = 0;
              double opacity = 1;
              double scale = 1;

              // Handle removal animation
              if (itemState.isRemoving) {
                // Fade out and scale down while sliding up
                opacity =
                    Tween<double>(begin: 1, end: 0).evaluate(moveAnimation);
                scale =
                    Tween<double>(begin: 1, end: 0.8).evaluate(CurvedAnimation(
                  parent: itemState.moveController,
                  curve: Curves.easeInBack,
                ));
              }
              // Animate all items down if a new item is added at the top
              if (_controller.isAddedAtTop &&
                  index >= 0 &&
                  !isMoving &&
                  !itemState.isRemoving) {
                // Animate new item at top
                if (index == 0) {
                  opacity = moveAnimation.value;
                }

                // Animate from -_newItemHeight to 0 (slide down over new item)
                currentOffset =
                    Tween<double>(begin: -_controller.itemHeight, end: 0)
                        .evaluate(moveAnimation);
              }
              // Animate move for reordered items
              if (isMoving && movingOffset != null) {
                currentOffset = Tween<double>(begin: 0, end: movingOffset)
                    .evaluate(moveAnimation);
              }

              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Transform.translate(
                    offset: Offset(0, currentOffset),
                    child: child,
                  ),
                ),
              );
            },
            child: combinedChild,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _updateSubscription?.cancel();
    _updateSubscription = null;
    _controller.disposeAnimations();
    super.dispose();
  }
}
