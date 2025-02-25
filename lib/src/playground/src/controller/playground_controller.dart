import 'dart:developer';
import 'dart:ui' as ui;

import 'package:drishya_picker/src/sticker_booth/sticker_booth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:photo_manager/photo_manager.dart';

import '../entities/playground_background.dart';
import '../entities/playground_value.dart';

///
class PlaygroundController extends ValueNotifier<PlaygroundValue> {
  ///
  PlaygroundController()
      : _playgroundKey = GlobalKey(),
        stickerController = StickerboothController(),
        textController = TextEditingController(),
        super(PlaygroundValue());

  final GlobalKey _playgroundKey;

  ///
  final StickerboothController stickerController;

  ///
  final TextEditingController textController;

  ///
  GlobalKey get playgroundKey => _playgroundKey;

  ///
  bool get isPlaygroundEmpty => !value.hasStickers;

  @override
  void dispose() {
    stickerController.dispose();
    super.dispose();
  }

  /// Update playground value
  void updateValue({
    bool? fillColor,
    int? maxLines,
    TextAlign? textAlign,
    bool? hasFocus,
    bool? editingMode,
    bool? hasStickers,
    bool? isEditing,
  }) {
    value = value.copyWith(
      fillColor: fillColor,
      maxLines: maxLines,
      textAlign: textAlign,
      hasFocus: hasFocus,
      editingMode: editingMode,
      hasStickers: hasStickers,
      isEditing: isEditing,
    );
  }

  /// Clear playground
  void clearPlayground() {
    stickerController.clearStickers();
    value = value.copyWith(hasStickers: false);
  }

  /// Change playground background
  void changeBackground({PlaygroundBackground? background}) {
    // Photo background
    if (background != null && background is PhotoBackground) {
      value = value.copyWith(background: background);
    } else {
      final current = value.background;
      final index = value.background is GradientBackground
          ? gradients.indexOf(current as GradientBackground)
          : 0;
      final hasMatch = index != -1;
      final nextIndex =
          hasMatch && index + 1 < gradients.length ? index + 1 : 0;
      final bg = gradients[nextIndex];
      value = value.copyWith(background: bg, textBackground: bg);
    }
  }

  /// Take screen shot of the playground
  Future<AssetEntity?> takeScreenshot() async {
    try {
      final boundary = _playgroundKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage();
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final data = byteData!.buffer.asUint8List();
        final entity = await PhotoManager.editor.saveImage(data);
        return entity;
      }
    } catch (e) {
      log('Exception occured while capturing picture : $e');
    }
  }

  //
}
