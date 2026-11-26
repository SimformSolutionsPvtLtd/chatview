import 'dart:async';

import 'package:chatview_utils/chatview_utils.dart' show ReplyMessage;
import 'package:flutter/material.dart';

import '../../../chatview.dart' show ChatView;
import '../../models/config_models/chat_view/message_input/overlay_action_widget.dart';
import 'text_field_action_button.dart';

/// Custom action button that displays a plus icon and
/// shows a horizontal row of options when pressed.
class OverlayActionButton extends TextFieldActionButton {
  const OverlayActionButton({
    required super.icon,
    required this.actions,
    this.isLeading = false,
    super.key,
    super.onPressed,
    super.color,
    super.style,
  });

  /// List of actions to display in the overlay.
  final List<OverlayActionWidget> actions;

  /// Whether the overlay should be anchored to the leading edge (left)
  /// or trailing edge (right).
  final bool isLeading;

  @override
  State<OverlayActionButton> createState() => _OverlayActionButtonState();
}

class _OverlayActionButtonState
    extends TextFieldActionButtonState<OverlayActionButton>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const Duration _overlayDuration = Duration(milliseconds: 250);

  /// The entry while the overlay is shown, null otherwise.
  OverlayEntry? _plusOverlayEntry;

  /// True while the overlay slides out, so a second dismiss is ignored.
  bool _isHiding = false;

  late AnimationController _overlayAnimationController;
  late CurvedAnimation _overlayCurve;
  late Animation<Offset> _overlayOffsetAnimation;
  final GlobalKey _plusIconKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _overlayAnimationController = AnimationController(
      vsync: this,
      duration: _overlayDuration,
    );
    _overlayCurve = CurvedAnimation(
      parent: _overlayAnimationController,
      curve: Curves.easeOut,
      // Reversed easeOut starts slow and ends fast, which looks like a snap.
      reverseCurve: Curves.easeIn,
    );
    // A short slide plus a fade: a full-height slide of an opaque menu would
    // sweep over the input bar and pop out of view at the end.
    _overlayOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(_overlayCurve);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: _plusIconKey,
      icon: widget.icon,
      color: widget.color,
      style: widget.style,
      onPressed: () {
        widget.onPressed != null
            ? widget.onPressed?.call(context)
            : _showOverlay(
                widget.actions,
                plusIconKey: _plusIconKey,
                isLeading: widget.isLeading, // Pass isLeading
                replyMessage: ChatView.getReplyMessage(context),
              );
      },
    );
  }

  // The overlay is placed once from the button's position, so a keyboard or
  // rotation change would leave it where the button used to be.
  @override
  void didChangeMetrics() => unawaited(hideOverlay());

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // The screen can close while the overlay is open or sliding out.
    _removeOverlay();
    _overlayCurve.dispose();
    _overlayAnimationController.dispose();
    super.dispose();
  }

  /// Shows a horizontal row of options above the plus icon.
  /// - If all options fit, overlay width matches content exactly
  /// (no extra space)
  /// - If too many options, overlay is scrollable and takes max width
  /// - Overlay is always anchored above the plus icon and never overflows
  /// screen
  void _showOverlay(
    List<OverlayActionWidget> plusOptions, {
    GlobalKey? plusIconKey,
    bool isLeading = false,
    ReplyMessage? replyMessage,
  }) {
    // Already open: a second one would leave the first entry on screen.
    if (_plusOverlayEntry != null) return;

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
        final iconBox = renderObject;
        final iconOffset = iconBox.localToGlobal(Offset.zero);
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

    final entry = _plusOverlayEntry = OverlayEntry(
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
                  child: FadeTransition(
                    opacity: _overlayCurve,
                    child: SlideTransition(
                      position: _overlayOffsetAnimation,
                      child: Container(
                        // Overlay container with animation, shadow,
                        // and rounded corners
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withAlpha((0.08 * 255).round()),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: SizedBox(
                          height: 48,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            // The root overlay has no Scaffold to remove the screen's
                            // safe-area insets, which a horizontal list adds itself.
                            padding: EdgeInsets.zero,
                            reverse: !isLeading, // Reverse for trailing
                            itemCount: plusOptions.length,
                            itemBuilder: (context, index) {
                              final option = plusOptions[index];
                              return IconButton(
                                icon: option.icon,
                                tooltip: option.label,
                                onPressed: () {
                                  unawaited(hideOverlay());
                                  option.onTap.call(replyMessage);
                                },
                              );
                            },
                          ),
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
    Overlay.of(context, rootOverlay: true).insert(entry);
    unawaited(_overlayAnimationController.forward());
  }

  /// Calculates the size and position of the overlay based on
  /// the options and screen dimensions.
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

    // - If all options fit, overlay is just wide enough and right-aligned
    // to plus icon
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
        // For trailing, keep plus icon at right edge of overlay,
        // but don't overflow left
        overlayLeft = iconRight - overlayWidth;
      }
    }

    return (overlayLeft, overlayWidth);
  }

  // Dismisses the plus/attach overlay with animation and cleans up the entry.
  ///
  /// Safe to call more than once: taps while it slides out are ignored.
  Future<void> hideOverlay() async {
    if (_plusOverlayEntry == null || _isHiding) return;
    _isHiding = true;
    await _overlayAnimationController.reverse();
    // If the widget was disposed meanwhile, dispose() already removed it.
    _removeOverlay();
  }

  void _removeOverlay() {
    final entry = _plusOverlayEntry;
    if (entry == null) return;
    _plusOverlayEntry = null;
    _isHiding = false;
    entry
      ..remove()
      ..dispose();
  }
}
