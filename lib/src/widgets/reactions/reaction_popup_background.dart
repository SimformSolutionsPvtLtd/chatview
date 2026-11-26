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

import '../../models/config_models/chat_view/reactions/reaction_popup_configuration.dart';
import 'glassmorphism_reaction_popup.dart';

/// Background of the reaction pop-up. Draws the glass effect or a plain
/// container around [child] (the emoji row).
class ReactionPopupBackground extends StatelessWidget {
  const ReactionPopupBackground({
    required this.child,
    this.config,
    super.key,
  });

  /// Provides configuration for reaction pop-up appearance.
  final ReactionPopupConfiguration? config;

  /// Content shown on the background.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (config?.showGlassMorphismEffect ?? false) {
      return GlassMorphismReactionPopup(
        reactionPopupConfig: config,
        child: child,
      );
    }
    return Container(
      constraints: BoxConstraints(maxWidth: config?.maxWidth ?? 350),
      margin: config?.margin ?? const EdgeInsets.symmetric(horizontal: 25),
      padding: config?.padding ??
          const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: BoxDecoration(
        color: config?.backgroundColor ?? Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        boxShadow: [
          config?.shadow ??
              BoxShadow(
                color: Colors.grey.shade400,
                blurRadius: 8,
                spreadRadius: -2,
                offset: const Offset(0, 8),
              ),
        ],
      ),
      child: child,
    );
  }
}
