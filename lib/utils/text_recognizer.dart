import 'dart:math';

import 'package:flutter/services.dart';
import 'package:kralupy_streets/providers/debugger_provider.dart';

import 'package:kralupy_streets/utils/custom_logger.dart';

/// debugMode randomly decides on the result based on set successRatio
class TextRecognizer {
  TextRecognizer();

  static const platform =
      MethodChannel('com.example.kralupy_streets/text_recognition');
  final log = CustomLogger('TextRecognizer');

  Future<bool> analyzeImageForText(String takenImagePath, List<String> texts,
      [Map<DebugOption, dynamic>? debugOptions]) async {
    // Debugging
    if (debugOptions != null &&
        debugOptions[DebugOption.enabled] &&
        debugOptions[DebugOption.recognizeStreet]) {
      return _debug(debugOptions[DebugOption.recognizeSuccessRatio], texts);
    }

    final result = await _analyzeImage(takenImagePath);
    log.trace('Found these words on image $result');

    for (String text in texts) {
      // Everything is lower cased to prevent casing issues
      if (result.contains(text.toLowerCase())) {
        log.trace('Text "$text" found');
        return true; // Match
      }
    }
    log.trace('None of these texts "$texts" were found');
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

  bool _debug(double successRatio, List<String> texts) {
    log.warning('Debug mode enabled');
    final random = Random().nextDouble();
    if (random < successRatio) {
      log.trace('One of these texts "$texts" found');
      return true;
    }
    log.trace('None of these texts "$texts" were found');
    return false;
  }
}
