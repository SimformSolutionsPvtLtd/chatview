import 'package:flutter/material.dart';

import '../../models/chat_view_list_item.dart';
import '../../values/typedefs.dart';

class _ItemState<T extends ChatViewListItem> {
  _ItemState({
    required this.moveController,
    required this.item,
    required this.currentIndex,
    this.isMoving = false,
    this.isRemoving = false,
  });

  final AnimationController moveController;
  T item;
  int currentIndex;
  double? moveOffset;
  bool isMoving;
  bool isRemoving;
}

/// A sliver list that automatically animates only the items that
/// move to different positions
class AutoAnimateSliverList<T extends ChatViewListItem> extends StatefulWidget {
  const AutoAnimateSliverList({
    required this.items,
    required this.builder,
    required this.itemKeyExtractor,
    this.enableMoveAnimation = true,
    this.animationCurve = Curves.easeInOut,
    this.animationDuration = const Duration(milliseconds: 400),
    super.key,
  });

  final List<T> items;
  final AutoAnimateItemBuilder<T> builder;
  final AutoAnimateItemExtractor<T> itemKeyExtractor;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool enableMoveAnimation;

  @override
  State<AutoAnimateSliverList<T>> createState() =>
      AutoAnimateSliverListState<T>();
}

class AutoAnimateSliverListState<T extends ChatViewListItem>
    extends State<AutoAnimateSliverList<T>> with TickerProviderStateMixin {
  final _itemStates = <String, _ItemState<T>>{};
  final _itemKeys = <String, GlobalKey>{};
  final _removingItems = <String>{};

  late var _currentItems = List<T>.from(widget.items);
  var _isNewItemAddedAtTop = false;
  var _newItemHeight = 0.0;
  var _isAddingItem = false;
  var _isRemovingItem = false;

  @override
  void initState() {
    super.initState();
    _initializeItemStates();
  }

  @override
  void didUpdateWidget(AutoAnimateSliverList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Don't update items if we're currently adding or removing an item
    if (!_isAddingItem && !_isRemovingItem) {
      _updateItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: _currentItems.length,
        (context, index) {
          final currentItemsLength = _currentItems.length;
          if (index >= currentItemsLength) return const SizedBox.shrink();

          final item = _currentItems[index];
          final key = widget.itemKeyExtractor(item);
          final itemState = _itemStates[key];

          if (itemState == null) return const SizedBox.shrink();

          final isMoving = itemState.isMoving;
          final movingOffset = itemState.moveOffset;

          final moveAnimation = CurvedAnimation(
            parent: itemState.moveController,
            curve: widget.animationCurve,
          );

          return AnimatedBuilder(
            key: _itemKeys[key],
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
              if (_isNewItemAddedAtTop &&
                  index >= 0 &&
                  !isMoving &&
                  !itemState.isRemoving) {
                // Animate new item at top
                if (index == 0) {
                  opacity = moveAnimation.value;
                }

                // Animate from -_newItemHeight to 0 (slide down over new item)
                currentOffset = Tween<double>(begin: -_newItemHeight, end: 0)
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
            child: widget.builder(
              context,
              index,
              index == _currentItems.length - 1,
              item,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    final values = _itemStates.values.toList();
    final valuesLength = values.length;
    for (var i = 0; i < valuesLength; i++) {
      values[i].moveController.dispose();
    }
    super.dispose();
  }

  void _initializeItemStates() {
    final currentItemsLength = _currentItems.length;
    for (var i = 0; i < currentItemsLength; i++) {
      final item = _currentItems[i];
      final key = widget.itemKeyExtractor(item);
      if (_itemStates.containsKey(key)) continue;
      _addItemState(
        key: key,
        currentIndex: i,
        item: item,
      );
    }
  }

  void _updateItems() {
    final newItems = List<T>.from(widget.items);
    final newItemKeys = <String>{};

    // Create maps for old and new positions
    final oldPositions = <String, int>{};
    final newPositions = <String, int>{};
    final removedKeys = <String>[];

    // Map new positions
    var newItemsLength = newItems.length;
    for (var i = 0; i < newItemsLength; i++) {
      final key = widget.itemKeyExtractor(newItems[i]);
      newItemKeys.add(key);
      newPositions[key] = i;
    }

    // Map current positions
    final currentItemsLength = _currentItems.length;
    for (var i = 0; i < currentItemsLength; i++) {
      final key = widget.itemKeyExtractor(_currentItems[i]);
      oldPositions[key] = i;
      if (!newItemKeys.contains(key)) {
        removedKeys.add(key);
      }
    }

    if (removedKeys.isNotEmpty) {
      // If items are removed, update immediately without animating moves
      _currentItems = newItems;
      _cleanupRemovedItems(newItemKeys);
      setState(() {});
      return;
    }

    // Capture current positions before any changes
    final renderBoxes = <String, RenderBox?>{};
    if (widget.enableMoveAnimation) {
      final entries = _itemKeys.entries.toList();
      final entriesLength = entries.length;
      for (var i = 0; i < entriesLength; i++) {
        final entry = entries[i];
        final renderObject = entry.value.currentContext?.findRenderObject();
        if (renderObject is RenderBox && renderObject.hasSize) {
          renderBoxes[entry.key] = renderObject;
        }
      }
    }

    var needsReorder = false;

    // Process all items
    newItemsLength = newItems.length;
    for (var i = 0; i < newItemsLength; i++) {
      final key = widget.itemKeyExtractor(newItems[i]);
      final oldIndex = oldPositions[key];
      final newIndex = i;

      if (_itemStates.containsKey(key)) {
        final itemState = _itemStates[key]!;
        // Only animate if item actually moved and
        // not just shifted due to insertion
        if (oldIndex != null &&
                oldIndex != newIndex &&
                widget.enableMoveAnimation &&
                oldPositions.length == newItemsLength // No new item inserted
            ) {
          needsReorder = true;

          // Calculate the offset this item needs to move
          final renderBox = renderBoxes[key];
          // Default fallback
          var itemHeight = 80.0;

          if (renderBox != null && renderBox.hasSize) {
            itemHeight = renderBox.size.height;
          }

          // This item moved - calculate the offset and animate only this item
          _animateItemMove(
            key,
            itemState,
            oldIndex,
            newIndex,
            itemHeight: itemHeight,
            onAnimationEnd: () {
              if (!mounted) return;
              // Apply reorder
              setState(() => _currentItems = List.from(newItems));
            },
          );
        }

        itemState
          ..item = newItems[i]
          ..currentIndex = i;
      } else {
        if (_itemStates.containsKey(key)) {
          // Item already exists (was added via addItem), just update its data
          _itemStates[key]!
            ..item = newItems[i]
            ..currentIndex = i;
        } else {
          _addItemState(
            key: key,
            currentIndex: i,
            item: newItems[i],
          );
        }
      }
    }

    // Clean up removed items
    _cleanupRemovedItems(newItemKeys);

    // If nothing moved, apply immediately
    if (!needsReorder) {
      _currentItems = newItems;
    }
  }

  void _addItemState({
    required String key,
    required T item,
    required int currentIndex,
    AnimationController? moveController,
  }) {
    final controller = moveController ??
        AnimationController(
          value: 1,
          duration: widget.animationDuration,
          vsync: this,
        );

    _itemStates[key] = _ItemState<T>(
      item: item,
      moveController: controller,
      currentIndex: currentIndex,
    );
    _itemKeys[key] = GlobalKey();
  }

  void _animateItemMove(
    String key,
    _ItemState<T> itemState,
    int oldIndex,
    int newIndex, {
    required double itemHeight,
    VoidCallback? onAnimationEnd,
  }) {
    // Calculate how many positions this item moved
    final positionDiff = newIndex - oldIndex;
    final moveOffset = positionDiff * itemHeight;

    itemState
      ..moveOffset = moveOffset
      ..isMoving = true;

    // Two-phase animation: first go on top, then come back behind
    itemState.moveController
      ..reset()
      ..forward().then((_) {
        if (!mounted) return;
        setState(() {
          itemState
            ..isMoving = false
            ..moveOffset = null;
          onAnimationEnd?.call();
        });
      });
  }

  void _cleanupRemovedItems(Set<String> newItemKeys) {
    final keysToRemove =
        _itemStates.keys.where((key) => !newItemKeys.contains(key)).toList();
    final keysToRemoveLength = keysToRemove.length;
    for (var i = 0; i < keysToRemoveLength; i++) {
      final key = keysToRemove[i];
      _itemStates[key]?.moveController.dispose();
      _itemStates.remove(key);
      _itemKeys.remove(key);
    }
  }

  /// Adds a new item with animation at the specified
  /// position (typically at top)
  void _addItem(T newItem, {int position = 0, bool shouldAnimate = true}) {
    _isAddingItem = true;

    final newItems = List<T>.from(_currentItems)..insert(position, newItem);

    final key = widget.itemKeyExtractor(newItem);

    // Only animate if adding at top AND shouldAnimate is true
    _isNewItemAddedAtTop = position == 0 && shouldAnimate;
    _newItemHeight = 0.0;

    // Only setup animation parameters if adding at top and should animate
    if (_isNewItemAddedAtTop && _currentItems.isNotEmpty) {
      // Estimate new item height based on existing items
      final firstOldKey = widget.itemKeyExtractor(_currentItems[0]);
      final renderBox =
          _itemKeys[firstOldKey]?.currentContext?.findRenderObject();
      if (renderBox is RenderBox && renderBox.hasSize) {
        _newItemHeight = renderBox.size.height;
      } else {
        _newItemHeight = 80.0;
      }
    }

    // Update the list immediately so new item is rendered
    _currentItems = newItems;

    // Create animation controller for new item
    final moveController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _addItemState(
      key: key,
      item: newItem,
      currentIndex: position,
      moveController: moveController,
    );

    // Update indices for existing items after the insertion point
    for (var i = position + 1; i < _currentItems.length; i++) {
      final itemKey = widget.itemKeyExtractor(_currentItems[i]);
      final itemState = _itemStates[itemKey];
      if (itemState != null) {
        itemState.currentIndex = i;
      }
    }

    setState(() {
      if (!_isNewItemAddedAtTop) {
        // No animation for items added at other positions or
        // when shouldAnimate is false
        moveController.value = 1;
      } else {
        // Only animate if new item is added at top
        moveController
          ..value = 0
          ..forward();

        // Animate all existing items down when new item added at top
        for (var i = position + 1; i < _currentItems.length; i++) {
          final itemKey = widget.itemKeyExtractor(_currentItems[i]);
          final itemState = _itemStates[itemKey];
          if (itemState != null) {
            itemState.moveController
              ..value = 0
              ..forward();
          }
        }
      }

      // Reset the flag after a brief delay to allow any pending widget updates
      Future.microtask(() {
        if (mounted) {
          _isAddingItem = false;
        }
      });
    });
  }

  /// Adds a new chat item, considering pinned items at the top
  /// If there are pinned items, the new item will be added after
  /// them without animation If no pinned items, it will be added
  /// at top with animation
  void addChatItem(
    T newItem, {
    ChatPinnedCallback<T>? isPinned,
  }) {
    // Count pinned items at the top
    var pinnedCount = 0;

    final currentItemsLength = _currentItems.length;
    for (var i = 0; i < currentItemsLength; i++) {
      final item = _currentItems[i];
      if (isPinned?.call(item) ?? item.settings.pinStatus.isPinned) {
        pinnedCount++;
      } else {
        // Stop at first non-pinned item
        break; // Stop at first non-pinned item
      }
    }

    // If there are pinned items, add after them without animation
    // If no pinned items, add at top with animation
    final shouldAnimate = pinnedCount == 0;
    _addItem(newItem, position: pinnedCount, shouldAnimate: shouldAnimate);
  }

  /// Removes an item with a smooth animation
  /// The item will fade out, scale down, and slide up before being removed
  void _removeItem(T item, {bool shouldAnimate = true}) {
    final key = widget.itemKeyExtractor(item);
    final itemState = _itemStates[key];

    if (itemState == null) {
      // Item doesn't exist, nothing to remove
      return;
    }

    final itemIndex =
        _currentItems.indexWhere((i) => widget.itemKeyExtractor(i) == key);
    if (itemIndex == -1) {
      return;
    }

    if (!shouldAnimate) {
      // Remove immediately without animation
      _currentItems.removeAt(itemIndex);
      final currentItemsLength = _currentItems.length;
      _cleanupRemovedItems(
        {
          for (var i = 0; i < currentItemsLength; i++)
            if (_currentItems[i] case final item) widget.itemKeyExtractor(item),
        },
      );
      setState(() {});
      return;
    }

    _isRemovingItem = true;
    _removingItems.add(key);

    // Mark item as removing
    itemState.isRemoving = true;

    // Start removal animation
    itemState.moveController
      ..reset()
      ..forward().then((_) {
        if (!mounted) return;

        // Remove the item from the list
        final newItems = List<T>.from(_currentItems)
          ..removeWhere((i) => widget.itemKeyExtractor(i) == key);
        _currentItems = newItems;

        // Update indices for remaining items
        final currentItemsLength = _currentItems.length;
        for (var i = 0; i < currentItemsLength; i++) {
          final itemKey = widget.itemKeyExtractor(_currentItems[i]);
          final state = _itemStates[itemKey];
          if (state != null) {
            state.currentIndex = i;
          }
        }

        // Cleanup the removed item
        _removingItems.remove(key);
        _itemStates[key]?.moveController.dispose();
        _itemStates.remove(key);
        _itemKeys.remove(key);

        // Reset the removing flag
        _isRemovingItem = _removingItems.isNotEmpty;

        setState(() {});
      });

    setState(() {});
  }

  /// Removes an item by its key with animation
  void removeItemByKey(String key, {bool shouldAnimate = true}) {
    final item = _currentItems.cast<T?>().firstWhere(
          (item) => item != null && widget.itemKeyExtractor(item) == key,
          orElse: () => null,
        );

    if (item == null) return;

    _removeItem(item, shouldAnimate: shouldAnimate);
  }
}
