import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../chatview.dart';

class LinkPreviewText extends StatefulWidget {
  const LinkPreviewText({
    super.key,
    required this.textMessage,
    required this.extractedUrls,
    required this.onLinkTap,
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

  @override
  Widget build(BuildContext context) {
    final linkStyle = widget.linkPreviewConfig?.linkStyle;
    final spans = <TextSpan>[];
    int lastIndex = 0;

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

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }
}
