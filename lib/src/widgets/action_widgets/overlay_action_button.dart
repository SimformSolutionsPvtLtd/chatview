import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';

/// Custom action button that displays a plus icon and shows a horizontal row of options when pressed.
class OverlayActionButton extends TextFieldActionButton {
  const OverlayActionButton({
    super.key,
    required super.icon,
    super.onPressed,
    super.color,
    required this.actions,
    this.isLeading = false,
  });

  /// List of actions to display in the overlay.
  final List<OverlayActionWidget> actions;

  /// Whether the overlay should be anchored to the leading edge (left) or trailing edge (right).
  final bool isLeading;

  @override
  State<OverlayActionButton> createState() => _OverlayActionButtonState();
}

class _OverlayActionButtonState
    extends TextFieldActionButtonState<OverlayActionButton>
    with SingleTickerProviderStateMixin {
  late OverlayEntry _plusOverlayEntry;
  late AnimationController _overlayAnimationController;
  late Animation<Offset> _overlayOffsetAnimation;
  final GlobalKey _plusIconKey = GlobalKey();

  @override
  void initState() {
    _overlayAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    // Create the slide animation for the overlay
    _overlayOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      // Use a curved animation for smooth transition
      CurvedAnimation(
        parent: _overlayAnimationController,
        curve: Curves.easeOut,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: _plusIconKey,
      icon: widget.icon,
      color: widget.color,
      onPressed: () {
        widget.onPressed != null
            ? widget.onPressed?.call()
            : _showOverlay(
                widget.actions,
                plusIconKey: _plusIconKey,
                isLeading: widget.isLeading, // Pass isLeading
              );
      },
    );
  }

  @override
  void dispose() {
    _overlayAnimationController.dispose();
    super.dispose();
  }

  /// Shows a horizontal row of options above the plus icon.
  /// - If all options fit, overlay width matches content exactly (no extra space)
  /// - If too many options, overlay is scrollable and takes max width
  /// - Overlay is always anchored above the plus icon and never overflows screen
  void _showOverlay(
    List<OverlayActionWidget> plusOptions, {
    GlobalKey? plusIconKey,
    bool isLeading = false,
  }) {
    _overlayAnimationController.reset();

    var overlayBottom = 0.0;
    var overlayLeft = 0.0;

    final size = MediaQuery.sizeOf(context);
    final screenHeight = size.height;
    var overlayWidth = size.width;
    const horizontalPadding = 24.0; // Margin from screen edge
    var iconLeft = 0.0;
    var iconRight = 0.0;
    var optionButtonWidth = 0.0;

    if (plusIconKey?.currentContext case final context?) {
      final renderObject = context.findRenderObject();
      if (renderObject is RenderBox) {
        final RenderBox iconBox = renderObject;
        final Offset iconOffset = iconBox.localToGlobal(Offset.zero);
        // Plus icon width
        optionButtonWidth = iconBox.size.width;
        // Left edge of the plus icon for leading
        iconLeft = iconOffset.dx;
        // Right edge of the plus icon
        iconRight = iconOffset.dx + optionButtonWidth;
        // Calculate overlay bottom based on icon position
        overlayBottom = screenHeight - iconOffset.dy;
      }
    }

    (overlayLeft, overlayWidth) = _getOverlaySize(
      plusOptions: plusOptions,
      iconLeft: iconLeft,
      iconRight: iconRight,
      horizontalPadding: horizontalPadding,
      optionButtonWidth: optionButtonWidth,
      screenWidth: overlayWidth,
      isLeading: isLeading,
    );

    _plusOverlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: hideOverlay, // Dismiss overlay on outside tap
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(
                  left: overlayLeft,
                  bottom: overlayBottom,
                  width: overlayWidth,
                  child: SlideTransition(
                    position: _overlayOffsetAnimation,
                    child: Container(
                      // Overlay container with animation, shadow, and rounded corners
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.08 * 255).round()),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: SizedBox(
                        height: 48,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          reverse: !isLeading, // Reverse for trailing
                          itemCount: plusOptions.length,
                          itemBuilder: (context, index) {
                            final option = plusOptions[index];
                            return IconButton(
                              icon: option.icon,
                              tooltip: option.label,
                              onPressed: () {
                                hideOverlay();
                                option.onTap.call();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    Overlay.of(context, rootOverlay: true).insert(_plusOverlayEntry);
    _overlayAnimationController.forward();
  }

  /// Calculates the size and position of the overlay based on the options and screen dimensions.
  (double, double) _getOverlaySize({
    required List<OverlayActionWidget> plusOptions,
    required double iconLeft,
    required double iconRight,
    required double horizontalPadding,
    required double optionButtonWidth,
    required double screenWidth,
    required bool isLeading,
  }) {
    var overlayWidth = 0.0;
    var overlayLeft = 0.0;
    // Calculate total width of all options
    final totalOptionsWidth = plusOptions.length * optionButtonWidth;
    // Calculate the maximum width for the overlay
    // - 24 for horizontal padding on each side (left and right)
    // Multiply by 2 for both sides to account extra padding on right side
    // So, overlay shown above of plus icon
    final maxOverlayWidth = screenWidth - horizontalPadding * 4;

    // - If all options fit, overlay is just wide enough and right-aligned to plus icon
    // - If leading icon, overlay is left-aligned to plus icon
    // - If not, overlay is scrollable and takes max width
    if (totalOptionsWidth < maxOverlayWidth) {
      // Overlay just wide enough for options
      overlayWidth = totalOptionsWidth;
      // Align overlay to plus icon
      // If leading, align left edge of overlay to left edge of plus icon
      // If trailing, align right edge of overlay to right edge of plus icon
      overlayLeft = isLeading ? iconLeft : iconRight - overlayWidth;
    } else {
      // Overlay takes full width, scrollable
      overlayWidth = maxOverlayWidth;
      if (isLeading) {
        // Always align left edge of overlay to left edge of plus icon
        overlayLeft = iconLeft;
        // If leading, ensure overlay doesn't overflow right side
        // Ensure overlay does not overflow right side
        overlayWidth -= overlayLeft - horizontalPadding * 2;
      } else {
        // For trailing, keep plus icon at right edge of overlay, but don't overflow left
        overlayLeft = iconRight - overlayWidth;
      }
    }

    return (overlayLeft, overlayWidth);
  }

  // Dismisses the plus/attach overlay with animation and cleans up the entry.
  void hideOverlay() async {
    await _overlayAnimationController.reverse();
    _plusOverlayEntry.remove();
  }
}
