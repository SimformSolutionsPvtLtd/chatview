import 'dart:io';

import 'package:flutter/material.dart';

import '../models/config_models/send_message_configuration.dart';
import '../utils/constants/constants.dart';
import 'chat_textfield_view_builder.dart';

class SelectedImageViewWidget extends StatefulWidget {
  const SelectedImageViewWidget({
    super.key,
    required this.sendMessageConfig,
  });

  /// Provides configuration for selected image view appearance.
  final SendMessageConfiguration? sendMessageConfig;

  @override
  State<SelectedImageViewWidget> createState() =>
      SelectedImageViewWidgetState();
}

class SelectedImageViewWidgetState extends State<SelectedImageViewWidget> {
  ValueNotifier<List<String>> selectedImages = ValueNotifier<List<String>>([]);

  @override
  Widget build(BuildContext context) {
    final mqSize = MediaQuery.sizeOf(context);
    return ChatTextFieldViewBuilder<List<String>>(
      valueListenable: selectedImages,
      builder: (context, images, child) {
        if (widget.sendMessageConfig?.selectedImageViewBuilder != null) {
          return widget.sendMessageConfig?.selectedImageViewBuilder
                  ?.call(images, onImageRemove) ??
              const SizedBox.shrink();
        } else if (images.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          width: mqSize.width,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              textFieldBorderRadius,
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                images.length,
                (index) {
                  final imagePath = images[index];
                  return SizedBox(
                    height: widget.sendMessageConfig?.selectedImageViewHeight ??
                        mqSize.height / 6,
                    child: Container(
                      margin: widget.sendMessageConfig?.selectedImageMargin ??
                          const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                widget.sendMessageConfig?.imageBorderRadius ??
                                    12,
                              ),
                            ),
                            child: Image.file(
                              File(imagePath),
                              height: mqSize.height / 8,
                            ),
                          ),
                          Positioned(
                            right: -10,
                            top: -10,
                            child: IconButton(
                              iconSize: widget
                                      .sendMessageConfig?.removeImageIconSize ??
                                  18,
                              icon: widget.sendMessageConfig?.removeImageIcon ??
                                  Icon(
                                    Icons.cancel,
                                    color: widget.sendMessageConfig
                                            ?.removeImageIconColor ??
                                        Colors.white,
                                    weight: 1,
                                  ),
                              onPressed: () => onImageRemove(imagePath),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    selectedImages.dispose();
    super.dispose();
  }

  void onImageRemove(String imagePath) {
    final imageList = selectedImages.value;
    selectedImages.value = List.from(imageList..remove(imagePath));
  }
}
