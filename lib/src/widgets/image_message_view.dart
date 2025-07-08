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
import 'dart:async'; // Added this import for Completer if not already present
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../extensions/extensions.dart';
import '../models/config_models/image_message_configuration.dart';
import '../models/config_models/message_reaction_configuration.dart';
import 'reaction_widget.dart';
import 'share_icon.dart';

class ImageMessageView extends StatefulWidget {
  const ImageMessageView({
    Key? key,
    required this.message,
    required this.isMessageBySender,
    this.imageMessageConfig,
    this.messageReactionConfig,
    this.highlightImage = false,
    this.highlightScale = 1.2,
  }) : super(key: key);

  final Message message;
  final bool isMessageBySender;
  final ImageMessageConfiguration? imageMessageConfig;
  final MessageReactionConfiguration? messageReactionConfig;
  final bool highlightImage;
  final double highlightScale;

  @override
  State<ImageMessageView> createState() => _ImageMessageViewState();
}

class _ImageMessageViewState extends State<ImageMessageView> {
  String get imageUrl => widget.message.message;
  double _imageAspectRatio = 1.0;

  @override
  void initState() {
    super.initState();
    _loadImageAndGetAspectRatio();
  }

  // Helper to robustly get a clean local path and handle decoding
  String _getCleanLocalPath(String pathOrUrl) {
    String cleanedPath = pathOrUrl;

    // First, try to parse as URI to handle file:/// and potential encoding
    try {
      final Uri uri = Uri.parse(pathOrUrl);
      if (uri.scheme == 'file') {
        // This is a file URI, extract its path component
        // Uri.file.path handles decoding automatically
        cleanedPath = uri.toFilePath();
        print('offline-chatview: _getCleanLocalPath: Parsed as file URI: $cleanedPath');
      } else {
        // Not a file URI, treat as a regular path and just decode
        cleanedPath = Uri.decodeComponent(pathOrUrl);
        print('offline-chatview: _getCleanLocalPath: Not file URI, just decoded: $cleanedPath');
      }
    } catch (e) {
      // If Uri.parse fails (e.g., it's just a raw path like /storage/emulated/0/...),
      // then try to decode it directly as a component.
      cleanedPath = Uri.decodeComponent(pathOrUrl);
      print('offline-chatview: _getCleanLocalPath: URI parse failed, direct decode: $cleanedPath');
    }
    return cleanedPath;
  }

  Future<void> _loadImageAndGetAspectRatio() async {
    final String cleanPath = _getCleanLocalPath(imageUrl);
    final File imageFile = File(cleanPath);

    if (await imageFile.exists()) {
      try {
        final Image image = Image.file(imageFile);
        final Completer<ui.Image> completer = Completer<ui.Image>();
        image.image.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener((ImageInfo info, bool _) {
            completer.complete(info.image);
          }),
        );
        final ui.Image uiImage = await completer.future;
        final double actualWidth = uiImage.width.toDouble();
        final double actualHeight = uiImage.height.toDouble();
        uiImage.dispose(); // Release image resources

        if (actualHeight > 0 && mounted) {
          setState(() {
            _imageAspectRatio = actualWidth / actualHeight;
            print('offline-chatview: Calculated image aspect ratio: $_imageAspectRatio');
          });
        }
      } catch (e) {
        print('offline-chatview: Error getting image dimensions for $cleanPath: $e');
        // Fallback to default aspect ratio
        if (mounted) {
          setState(() { _imageAspectRatio = 1.0; });
        }
      }
    } else {
      print('offline-chatview: Image file does not exist for aspect ratio calculation: $cleanPath');
      // If file doesn't exist, use a default aspect ratio and ensure UI fallback
      if (mounted) {
        setState(() { _imageAspectRatio = 1.0; }); // Keep default
      }
    }
  }

  Widget get iconButton => ShareIcon(
        shareIconConfig: widget.imageMessageConfig?.shareIconConfig,
        imageUrl: imageUrl,
      );

  @override
  Widget build(BuildContext context) {
    final double maxWidthForContent = MediaQuery.of(context).size.width * 0.7;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          widget.isMessageBySender ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (widget.isMessageBySender && !(widget.imageMessageConfig?.hideShareIcon ?? false))
          iconButton,
        Stack(
          children: [
            GestureDetector(
              onTap: () => widget.imageMessageConfig?.onTap != null
                  ? widget.imageMessageConfig?.onTap!(widget.message)
                  : null,
              child: Transform.scale(
                scale: widget.highlightImage ? widget.highlightScale : 1.0,
                alignment: widget.isMessageBySender
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  padding: widget.imageMessageConfig?.padding ?? EdgeInsets.zero,
                  margin: widget.imageMessageConfig?.margin ??
                      EdgeInsets.only(
                        top: 6,
                        right: widget.isMessageBySender ? 6 : 0,
                        left: widget.isMessageBySender ? 0 : 6,
                        bottom: widget.message.reaction.reactions.isNotEmpty ? 15 : 0,
                      ),
                  constraints: BoxConstraints(
                    maxWidth: maxWidthForContent,
                  ),
                  child: ClipRRect(
                    borderRadius: widget.imageMessageConfig?.borderRadius ??
                        BorderRadius.circular(14),
                    child: (() {
                      // More robust check for local file path
                      final bool isLocalFilePath = imageUrl.startsWith('file:///') || // explicit file URI
                                                   imageUrl.startsWith('/') ||      // absolute path on Unix-like (Android/iOS)
                                                   (Platform.isWindows && (imageUrl.contains(':') && imageUrl.startsWith(RegExp(r'^[a-zA-Z]:[/\\]')))); // Windows path

                      if (isLocalFilePath) {
                        final String cleanPath = _getCleanLocalPath(imageUrl);
                        final File localFile = File(cleanPath);

                        return FutureBuilder<bool>(
                          future: localFile.exists(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              if (snapshot.hasData && snapshot.data == true) {
                                print('offline-chatview: Image File exists (rendering): $cleanPath');
                                return AspectRatio(
                                  aspectRatio: _imageAspectRatio,
                                  child: Image.file(
                                    localFile,
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      print('offline-chatview: Error rendering local file: $error');
                                      return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                                    },
                                  ),
                                );
                              } else {
                                print('offline-chatview: Local file does not exist (displaying broken icon): $cleanPath');
                                return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                              }
                            }
                            return const CircularProgressIndicator();
                          },
                        );
                      }
                      else if (imageUrl.fromMemory) {
                        print('offline-chatview: Displaying image from memory (Base64).');
                        return AspectRatio(
                          aspectRatio: _imageAspectRatio,
                          child: Image.memory(
                            base64Decode(imageUrl.substring(imageUrl.indexOf('base64') + 7)),
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                                print('offline-chatview: Error loading Base64 image: $error');
                                return const Icon(Icons.broken_image, size: 50, color: Colors.redAccent);
                            },
                          ),
                        );
                      }
                      else if (imageUrl.isUrl) {
                        print('offline-chatview: Displaying network image from: $imageUrl');
                        return AspectRatio(
                          aspectRatio: _imageAspectRatio,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              print('offline-chatview: Error loading network image: $error');
                              return const Icon(Icons.error, size: 50, color: Colors.red);
                            },
                          ),
                        );
                      }
                      else {
                        print('offline-chatview: Unrecognized image URL format (displaying placeholder): $imageUrl');
                        return const Icon(Icons.broken_image, size: 50, color: Colors.purple);
                      }
                    }()),
                  ),
                ),
              ),
            ),
            if (widget.message.reaction.reactions.isNotEmpty)
              ReactionWidget(
                isMessageBySender: widget.isMessageBySender,
                reaction: widget.message.reaction,
                messageReactionConfig: widget.messageReactionConfig,
              ),
          ],
        ),
        if (!widget.isMessageBySender && !(widget.imageMessageConfig?.hideShareIcon ?? false))
          iconButton,
      ],
    );
  }
}