import 'dart:math';

import 'package:flutter/material.dart';
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
      [Map<DebugOption, dynamic>? debugOptions, BuildContext? context]) async {
    final result = await _analyzeImage(takenImagePath);
    log.trace('Found these words on image $result');

    // Debugging start
    if (debugOptions != null && debugOptions[DebugOption.enabled]) {
      log.warning('Debug mode enabled');
      if (debugOptions[DebugOption.printRecognizedTexts] &&
          context != null &&
          context.mounted) {
        _showFoundTextsDialog(context, result);
      }

      if (debugOptions[DebugOption.recognizeStreet]) {
        return _debug(debugOptions[DebugOption.recognizeSuccessRatio], texts);
      }
    }
    // Debugging end

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

  void _showFoundTextsDialog(BuildContext context, List<String> result) {
    log.debug('Found these words on image $result');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: result.isEmpty
            ? const Text('Nenalezeny žádné texty')
            : const Text('Nalezeny tyto texty'),
        content: result.isEmpty ? null : Text(result.toString()),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
