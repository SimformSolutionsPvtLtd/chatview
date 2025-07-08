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
import 'dart:convert';
import 'dart:io'; // Ensure this is imported

import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../extensions/extensions.dart';
import '../models/config_models/image_message_configuration.dart';
import '../models/config_models/message_reaction_configuration.dart';
import 'reaction_widget.dart';
import 'share_icon.dart';

class ImageMessageView extends StatelessWidget {
  const ImageMessageView({
    Key? key,
    required this.message,
    required this.isMessageBySender,
    this.imageMessageConfig,
    this.messageReactionConfig,
    this.highlightImage = false,
    this.highlightScale = 1.2,
  }) : super(key: key);

  /// Provides message instance of chat.
  final Message message;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Provides configuration for image message appearance.
  final ImageMessageConfiguration? imageMessageConfig;

  /// Provides configuration of reaction appearance in chat bubble.
  final MessageReactionConfiguration? messageReactionConfig;

  /// Represents flag of highlighting image when user taps on replied image.
  final bool highlightImage;

  /// Provides scale of highlighted image when user taps on replied image.
  final double highlightScale;

  String get imageUrl => message.message;

  Widget get iconButton => ShareIcon(
        shareIconConfig: imageMessageConfig?.shareIconConfig,
        imageUrl: imageUrl,
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          isMessageBySender ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (isMessageBySender && !(imageMessageConfig?.hideShareIcon ?? false))
          iconButton,
        Stack(
          children: [
            GestureDetector(
              onTap: () => imageMessageConfig?.onTap != null
                  ? imageMessageConfig?.onTap!(message)
                  : null,
              child: Transform.scale(
                scale: highlightImage ? highlightScale : 1.0,
                alignment: isMessageBySender
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  padding: imageMessageConfig?.padding ?? EdgeInsets.zero,
                  margin: imageMessageConfig?.margin ??
                      EdgeInsets.only(
                        top: 6,
                        right: isMessageBySender ? 6 : 0,
                        left: isMessageBySender ? 0 : 6,
                        bottom: message.reaction.reactions.isNotEmpty ? 15 : 0,
                      ),
                  height: imageMessageConfig?.height ?? 200,
                  width: imageMessageConfig?.width ?? 150,
                  child: ClipRRect(
                    borderRadius: imageMessageConfig?.borderRadius ??
                        BorderRadius.circular(14),
                    child: (() {
                      // --- MODIFIED LOGIC STARTS HERE ---

                      // 1. Check if it's a local file path
                      // We're being explicit here for Windows paths as well
                      // Consider using Uri.tryParse for a more robust scheme check
                      final bool isLocalFilePath = imageUrl.startsWith('file:///') ||
                                                   (Platform.isWindows && imageUrl.contains(':') && imageUrl.startsWith(RegExp(r'^[a-zA-Z]:[/\\]')));

                      if (isLocalFilePath) {
                        String path = imageUrl;
                        if (imageUrl.startsWith('file:///')) {
                          path = imageUrl.substring('file:///'.length);
                        }

                        final File localFile = File(path);
                        print('offline-chatview: Attempting to load local file: $path');
                        return FutureBuilder<bool>(
                          future: localFile.exists(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              if (snapshot.hasData && snapshot.data == true) {
                                return Image.file(
                                  localFile,
                                  fit: BoxFit.fill,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('offline-chatview: Error loading local file: $error');
                                    return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                                  },
                                );
                              } else {
                                print('offline-chatview: Local file does not exist: $path');
                                return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                              }
                            }
                            return const CircularProgressIndicator(); // Show loading while checking existence
                          },
                        );
                      }
                      // 2. Check if it's a Base64 string (using your existing `fromMemory` extension)
                      else if (imageUrl.fromMemory) {
                        print('offline-chatview: Displaying image from memory (Base64).');
                        return Image.memory(
                          base64Decode(imageUrl.substring(imageUrl.indexOf('base64') + 7)),
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) {
                             print('offline-chatview: Error loading Base64 image: $error');
                             return const Icon(Icons.broken_image, size: 50, color: Colors.redAccent);
                          },
                        );
                      }
                      // 3. Otherwise, assume it's a network URL (using your existing `isUrl` extension)
                      else if (imageUrl.isUrl) { // This check remains but is now the last resort for URLs
                        print('offline-chatview: Displaying network image from: $imageUrl');
                        return Image.network(
                          imageUrl,
                          fit: BoxFit.fitHeight,
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
                        );
                      }
                      // 4. Fallback for any other unrecognized format
                      else {
                        print('offline-chatview: Unrecognized image URL format: $imageUrl');
                        return const Icon(Icons.broken_image, size: 50, color: Colors.purple);
                      }
                      // --- MODIFIED LOGIC ENDS HERE ---
                    }()),
                  ),
                ),
              ),
            ),
            if (message.reaction.reactions.isNotEmpty)
              ReactionWidget(
                isMessageBySender: isMessageBySender,
                reaction: message.reaction,
                messageReactionConfig: messageReactionConfig,
              ),
          ],
        ),
        if (!isMessageBySender && !(imageMessageConfig?.hideShareIcon ?? false))
          iconButton,
      ],
    );
  }
}