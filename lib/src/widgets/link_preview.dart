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
import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../extensions/extensions.dart';
import '../models/config_models/link_preview_configuration.dart';
import '../utils/constants/constants.dart';

class LinkPreview extends StatelessWidget {
  const LinkPreview({
    Key? key,
    required this.url,
    this.linkPreviewConfig,
  }) : super(key: key);

  /// Provides url which is passed in message.
  final String url;

  /// Provides configuration of chat bubble appearance when link/URL is passed
  /// in message.
  final LinkPreviewConfiguration? linkPreviewConfig;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: linkPreviewConfig?.padding ??
          const EdgeInsets.symmetric(horizontal: 6, vertical: verticalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!url.isImageUrl &&
              !(context.chatBubbleConfig?.disableLinkPreview ?? false)) ...{
            Padding(
              padding: const EdgeInsets.symmetric(vertical: verticalPadding),
              child: AnyLinkPreview(
                link: url,
                removeElevation: true,
                errorBody: linkPreviewConfig?.errorBody,
                proxyUrl: linkPreviewConfig?.proxyUrl,
                onTap: _onLinkTap,
                placeholderWidget: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: double.infinity,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                      color: linkPreviewConfig?.loadingColor,
                    ),
                  ),
                ),
                backgroundColor:
                    linkPreviewConfig?.backgroundColor ?? Colors.grey.shade200,
                borderRadius: linkPreviewConfig?.borderRadius,
                bodyStyle: linkPreviewConfig?.bodyStyle ??
                    const TextStyle(color: Colors.black),
                titleStyle: linkPreviewConfig?.titleStyle,
              ),
            ),
          } else if (url.isImageUrl) ...{
            Padding(
              padding: const EdgeInsets.symmetric(vertical: verticalPadding),
              child: InkWell(
                onTap: _onLinkTap,
                child: Image.network(
                  url,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          },
          const SizedBox(height: verticalPadding),
          InkWell(
            onTap: _onLinkTap,
            child: Text(
              url,
              style: linkPreviewConfig?.linkStyle ??
                  const TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _onLinkTap() {
    if (linkPreviewConfig?.onUrlDetect != null) {
      linkPreviewConfig?.onUrlDetect!(url);
    } else {
      _launchURL();
    }
  }

  void _launchURL() async {
    final parsedUrl = Uri.parse(url);
    await canLaunchUrl(parsedUrl)
        ? await launchUrl(parsedUrl)
        : throw couldNotLaunch;
  }
}
