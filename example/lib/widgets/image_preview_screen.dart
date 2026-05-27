// Conditional import for dart:io (only available on non-web platforms)
// ignore: uri_does_not_exist
import 'dart:io';

import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// A full-screen image preview screen shown before sending an image.
///
/// Displays the selected image full-screen with:
/// - A close button at the top-left
/// - A chat name in the top bar
/// - A caption text field + send button pinned to the bottom
class ImagePreviewScreen extends StatefulWidget {
  const ImagePreviewScreen({
    super.key,
    required this.imagePath,
    required this.onSend,
    this.replyMessage,
    this.chatName,
  });

  /// Local file path of the selected image.
  final String imagePath;

  /// Optional chat/contact name shown in the top bar.
  final String? chatName;

  /// Active reply message carried over from the chat screen (may be null).
  final ReplyMessage? replyMessage;

  /// Called when the user taps send. Provides the image path, caption text,
  /// and the original reply message.
  final void Function(
    String imagePath,
    String caption,
    ReplyMessage? replyMessage,
  ) onSend;

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  final _captionController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _captionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    widget.onSend(
      widget.imagePath,
      _captionController.text.trim(),
      widget.replyMessage,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                maxScale: 4.0,
                child: Center(
                  child: kIsWeb
                      ? Image.network(
                          widget.imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image,
                                color: Colors.white54, size: 64),
                          ),
                        )
                      : Image.file(
                          File(widget.imagePath),
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image,
                                color: Colors.white54, size: 64),
                          ),
                        ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                        tooltip: 'Close',
                      ),
                      if (widget.chatName != null) ...[
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Send to ${widget.chatName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: bottomInset,
              left: 0,
              right: 0,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Caption text field
                      Expanded(
                        child: TextField(
                          controller: _captionController,
                          focusNode: _focusNode,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 4,
                          minLines: 1,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            hintText: 'Add a caption…',
                            hintStyle: const TextStyle(color: Colors.white60),
                            filled: true,
                            fillColor: Colors.black45,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Send button
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: FloatingActionButton(
                          onPressed: _send,
                          backgroundColor: const Color(0xFF574FF0),
                          elevation: 4,
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
