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

import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import 'profile_image_widget.dart';

class ReactionsBottomSheet {
  Future<void> show({
    required BuildContext context,

    /// Provides reaction instance of message.
    required Reaction reaction,

    /// Provides controller for accessing few function for running chat.
    required ChatController chatController,

    /// Provides configuration of reaction bottom sheet appearance.
    required ReactionsBottomSheetConfiguration? reactionsBottomSheetConfig,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          color: reactionsBottomSheetConfig?.backgroundColor,
          child: ListView.builder(
            padding: reactionsBottomSheetConfig?.bottomSheetPadding ??
                const EdgeInsets.only(
                  right: 12,
                  left: 12,
                  top: 18,
                ),
            itemCount: reaction.reactedUserIds.length,
            itemBuilder: (_, index) {
              final reactedUser =
                  chatController.getUserFromId(reaction.reactedUserIds[index]);
              return GestureDetector(
                onTap: () {
                  reactionsBottomSheetConfig?.reactedUserCallback?.call(
                    reactedUser,
                    reaction.reactions[index],
                  );
                },
                child: Container(
                  margin: reactionsBottomSheetConfig?.reactionWidgetMargin ??
                      const EdgeInsets.only(bottom: 8),
                  padding: reactionsBottomSheetConfig?.reactionWidgetPadding ??
                      const EdgeInsets.all(8),
                  decoration:
                      reactionsBottomSheetConfig?.reactionWidgetDecoration ??
                          BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                offset: const Offset(0, 20),
                                blurRadius: 40,
                              )
                            ],
                            borderRadius: const BorderRadius.all(
                              Radius.circular(
                                10,
                              ),
                            ),
                          ),
                  child: Row(
                    children: [
                      ProfileImageWidget(
                        circleRadius:
                            reactionsBottomSheetConfig?.profileCircleRadius ??
                                16,
                        imageUrl: reactedUser.profilePhoto,
                        imageType: reactedUser.imageType,
                        defaultAvatarImage: reactedUser.defaultAvatarImage,
                        assetImageErrorBuilder:
                            reactedUser.assetImageErrorBuilder,
                        networkImageErrorBuilder:
                            reactedUser.networkImageErrorBuilder,
                        networkImageProgressIndicatorBuilder:
                            reactedUser.networkImageProgressIndicatorBuilder,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          reactedUser.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              reactionsBottomSheetConfig?.reactedUserTextStyle,
                        ),
                      ),
                      Text(
                        reaction.reactions[index],
                        style: TextStyle(
                          fontSize:
                              reactionsBottomSheetConfig?.reactionSize ?? 14,
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
