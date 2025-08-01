import 'package:flutter/material.dart';

import '../../values/typedefs.dart';

class _ItemState<T> {
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
class AutoAnimateSliverList<T> extends StatefulWidget {
  const AutoAnimateSliverList({
    required this.items,
    required this.itemBuilder,
    required this.keyExtractor,
    this.enableMoveAnimation = true,
    this.animationCurve = Curves.easeInOut,
    this.animationDuration = const Duration(milliseconds: 400),
    super.key,
  });

  final List<T> items;
  final AutoAnimateItemBuilder<T> itemBuilder;
  final AutoAnimateItemExtractor keyExtractor;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool enableMoveAnimation;

  @override
  State<AutoAnimateSliverList<T>> createState() =>
      AutoAnimateSliverListState<T>();
}

class AutoAnimateSliverListState<T> extends State<AutoAnimateSliverList<T>>
    with TickerProviderStateMixin {
  final Map<String, _ItemState<T>> _itemStates = {};
  final Map<String, GlobalKey> _itemKeys = {};
  late List<T> _currentItems = _currentItems = List.from(widget.items);

  // Add these fields to _AutoAnimateSliverListState
  bool _isNewItemAddedAtTop = false;
  double _newItemHeight = 0;
  bool _isAddingItem = false;
  final Set<String> _removingItems = {};
  bool _isRemovingItem = false;

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
          final key = widget.keyExtractor(item);
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
                  index > 0 &&
                  !isMoving &&
                  !itemState.isRemoving) {
                // Animate from -_newItemHeight to 0 (slide down over new item)
                currentOffset = Tween<double>(begin: -_newItemHeight, end: 0)
                    .evaluate(moveAnimation);
              }
              // Animate new item at top
              if (_isNewItemAddedAtTop &&
                  index == 0 &&
                  !isMoving &&
                  !itemState.isRemoving) {
                opacity = moveAnimation.value;
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
            child: widget.itemBuilder(context, index, item),
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
      final key = widget.keyExtractor(item);
      if (_itemStates.containsKey(key)) continue;

      final moveController = AnimationController(
        value: 1,
        vsync: this,
        duration: widget.animationDuration,
      );

      _itemStates[key] = _ItemState<T>(
        item: item,
        currentIndex: i,
        moveController: moveController,
      );
      _itemKeys[key] = GlobalKey();
    }
  }

  void _updateItems() {
    final newItems = List<T>.from(widget.items);
    final newItemKeys = <String>{};

    // Create maps for old and new positions
    final oldPositions = <String, int>{};
    final newPositions = <String, int>{};

    // Map current positions
    final currentItemsLength = _currentItems.length;
    for (var i = 0; i < currentItemsLength; i++) {
      final key = widget.keyExtractor(_currentItems[i]);
      oldPositions[key] = i;
    }

    // Map new positions
    var newItemsLength = newItems.length;
    for (var i = 0; i < newItemsLength; i++) {
      final key = widget.keyExtractor(newItems[i]);
      newItemKeys.add(key);
      newPositions[key] = i;
    }

    // Detect removed items
    final removedKeys =
        oldPositions.keys.where((key) => !newItemKeys.contains(key)).toList();
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
      final key = widget.keyExtractor(newItems[i]);
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
        // New item - only initialize if not already handled by addItem methods
        if (!_itemStates.containsKey(key)) {
          final moveController = AnimationController(
            value: 1,
            duration: widget.animationDuration,
            vsync: this,
          );

          _itemStates[key] = _ItemState<T>(
            moveController: moveController,
            item: newItems[i],
            currentIndex: i,
          );
          _itemKeys[key] = GlobalKey();
        } else {
          // Item already exists (was added via addItem), just update its data
          _itemStates[key]!
            ..item = newItems[i]
            ..currentIndex = i;
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
    itemState.moveController.reset();
    itemState.moveController.forward().then((_) {
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

    final key = widget.keyExtractor(newItem);

    // Only animate if adding at top AND shouldAnimate is true
    _isNewItemAddedAtTop = position == 0 && shouldAnimate;
    _newItemHeight = 0.0;

    // Only setup animation parameters if adding at top and should animate
    if (_isNewItemAddedAtTop && _currentItems.isNotEmpty) {
      // Estimate new item height based on existing items
      final firstOldKey = widget.keyExtractor(_currentItems[0]);
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

    _itemStates[key] = _ItemState<T>(
      moveController: moveController,
      item: newItem,
      currentIndex: position,
    );
    _itemKeys[key] = GlobalKey();

    // Update indices for existing items after the insertion point
    for (var i = position + 1; i < _currentItems.length; i++) {
      final itemKey = widget.keyExtractor(_currentItems[i]);
      final itemState = _itemStates[itemKey];
      if (itemState != null) {
        itemState.currentIndex = i;
      }
    }

    setState(() {
      // Only animate if new item is added at top and should animate
      if (_isNewItemAddedAtTop) {
        // Animate new item at top
        moveController
          ..value = 0
          ..forward();

        // Animate all existing items down when new item added at top
        for (var i = position + 1; i < _currentItems.length; i++) {
          final itemKey = widget.keyExtractor(_currentItems[i]);
          final itemState = _itemStates[itemKey];
          if (itemState != null) {
            itemState.moveController
              ..value = 0
              ..forward();
          }
        }
      } else {
        // No animation for items added at other positions or
        // when shouldAnimate is false
        moveController.value = 1;
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
  void addChatItem(T newItem, {required bool Function(T item) isPinned}) {
    // Count pinned items at the top
    var pinnedCount = 0;

    final currentItemsLength = _currentItems.length;
    for (var i = 0; i < currentItemsLength; i++) {
      if (isPinned(_currentItems[i])) {
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
    final key = widget.keyExtractor(item);
    final itemState = _itemStates[key];

    if (itemState == null) {
      // Item doesn't exist, nothing to remove
      return;
    }

    final itemIndex =
        _currentItems.indexWhere((i) => widget.keyExtractor(i) == key);
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
            if (_currentItems[i] case final item) widget.keyExtractor(item),
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
    itemState.moveController.reset();
    itemState.moveController.forward().then((_) {
      if (!mounted) return;

      // Remove the item from the list
      final newItems = List<T>.from(_currentItems)
        ..removeWhere((i) => widget.keyExtractor(i) == key);
      _currentItems = newItems;

      // Update indices for remaining items
      final currentItemsLength = _currentItems.length;
      for (var i = 0; i < currentItemsLength; i++) {
        final itemKey = widget.keyExtractor(_currentItems[i]);
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
    T? item;

    try {
      item = _currentItems.cast<T?>().firstWhere(
            (item) => item != null && widget.keyExtractor(item) == key,
            orElse: () => null,
          );
    } catch (_) {}

    if (item == null) return;

    _removeItem(item, shouldAnimate: shouldAnimate);
  }
}
