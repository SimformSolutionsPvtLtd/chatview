import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../chatview.dart';

class LinkPreviewText extends StatefulWidget {
  const LinkPreviewText({
    required this.textMessage,
    required this.extractedUrls,
    required this.onLinkTap,
    super.key,
    this.linkPreviewConfig,
    this.normalTextStyle,
  });

  /// Provides the whole text message to show.
  final String textMessage;

  /// Provides urls which are passed in message.
  final List<String> extractedUrls;

  /// Provides configuration of chat bubble appearance when link/URL is passed
  final LinkPreviewConfiguration? linkPreviewConfig;

  /// Callback when a link is tapped.
  final ValueSetter<String> onLinkTap;

  /// Provides normal text style for message text.
  final TextStyle? normalTextStyle;

  @override
  State<LinkPreviewText> createState() => _LinkPreviewTextState();
}

class _LinkPreviewTextState extends State<LinkPreviewText> {
  final List<TapGestureRecognizer> _recognizers = [];

  /// Built when the text or its styles change, not on every build, so the
  /// recognizers are created once and not once per rebuild.
  late List<TextSpan> _spans;

  @override
  void initState() {
    super.initState();
    _spans = _buildSpans();
  }

  @override
  void didUpdateWidget(LinkPreviewText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.textMessage != widget.textMessage ||
        !listEquals(oldWidget.extractedUrls, widget.extractedUrls) ||
        oldWidget.normalTextStyle != widget.normalTextStyle ||
        oldWidget.linkPreviewConfig?.linkStyle !=
            widget.linkPreviewConfig?.linkStyle) {
      _disposeRecognizers();
      _spans = _buildSpans();
    }
  }

  List<TextSpan> _buildSpans() {
    final linkStyle = widget.linkPreviewConfig?.linkStyle;
    final spans = <TextSpan>[];
    var lastIndex = 0;

    for (final url in widget.extractedUrls) {
      final start = widget.textMessage.indexOf(url, lastIndex);
      if (start == -1) continue;

      if (start > lastIndex) {
        spans.add(
          TextSpan(
            text: widget.textMessage.substring(lastIndex, start),
            style: widget.normalTextStyle,
          ),
        );
      }

      // Reads [widget] when tapped, so a new `onLinkTap` needs no new span.
      final recognizer = TapGestureRecognizer()
        ..onTap = () => widget.onLinkTap(url);
      _recognizers.add(recognizer);

      spans.add(
        TextSpan(
          text: url,
          style: linkStyle,
          recognizer: recognizer,
        ),
      );

      lastIndex = start + url.length;
    }

    if (lastIndex < widget.textMessage.length) {
      spans.add(
        TextSpan(
          text: widget.textMessage.substring(lastIndex),
          style: widget.normalTextStyle,
        ),
      );
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(TextSpan(children: _spans));
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }
}
