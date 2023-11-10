import 'dart:math';

import 'package:flutter/services.dart';

import 'package:kralupy_streets/utils/custom_logger.dart';

/// debugMode randomly decides on the result based on set successRatio
class TextRecognizer {
  TextRecognizer({this.debugMode = false, this.successRatio = .5});

  final bool debugMode;
  final double successRatio;

  static const platform =
      MethodChannel('com.example.kralupy_streets/text_recognition');
  final log = CustomLogger('TextRecognizer');

  Future<bool> analyzeImageForText(String takenImagePath, String text) async {
    // Debugging
    if (debugMode) {
      log.warning('Debug mode enabled');
      final random = Random().nextDouble();
      if (random < successRatio) {
        log.trace('Text "$text" found');
        return true;
      }
      log.trace('Text "$text" not found');
      return false;
    }

    final result = await _analyzeImage(takenImagePath);

    // Everything is lower cased to prevent casing issues
    if (result.contains(text.toLowerCase())) {
      log.trace('Text "$text" found');
      return true; // Match
    }
    log.trace('Text "$text" not found');
    return false; // No match
  }

  Future<List<String>> _analyzeImage(String takenImagePath) async {
    try {
      final result = await platform.invokeMethod<List>('analyzeImage', {
        'imagePath': takenImagePath,
      });
      return result?.map((item) => item.toString().toLowerCase()).toList() ??
          [];
    } on PlatformException catch (e) {
      log.error(e.message ?? 'Analyzing image failed');
      return [];
    }
  }
}
