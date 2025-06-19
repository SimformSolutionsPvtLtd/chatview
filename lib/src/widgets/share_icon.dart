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
import 'package:flutter/material.dart';

import '../models/config_models/image_message_configuration.dart';

class ShareIcon extends StatelessWidget {
  const ShareIcon({
    Key? key,
    this.shareIconConfig,
    required this.imageUrl,
  }) : super(key: key);

  /// Provides configuration of share icon which is showed in image preview.
  final ShareIconConfiguration? shareIconConfig;

  /// Provides image url of image message.
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => shareIconConfig?.onPressed != null
          ? shareIconConfig?.onPressed!(imageUrl)
          : null,
      padding: shareIconConfig?.margin ?? const EdgeInsets.all(8.0),
      icon: shareIconConfig?.icon ??
          Container(
            alignment: Alignment.center,
            padding: shareIconConfig?.padding ?? const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: shareIconConfig?.defaultIconBackgroundColor ??
                  Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.send,
              color: shareIconConfig?.defaultIconColor ?? Colors.black,
              size: 16,
            ),
          ),
    );
  }
}
