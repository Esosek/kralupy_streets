import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kralupy_streets/utils/custom_logger.dart';

enum DebugOption {
  enabled,
  loadNextHunt,
  recognizeStreet,
  recognizeSuccessRatio,
  printRecognizedTexts,
}

final _defaultSettings = {
  DebugOption.enabled: false,
  DebugOption.loadNextHunt: false,
  DebugOption.recognizeStreet: false,
  DebugOption.recognizeSuccessRatio: .5,
  DebugOption.printRecognizedTexts: false,
};

class DebuggerStateNotifier extends StateNotifier<Map<DebugOption, dynamic>> {
  DebuggerStateNotifier() : super(_defaultSettings);

  final log = CustomLogger('Debugger');

  void toggleSetting(DebugOption option, dynamic value) {
    log.debug('Setting $option to $value');
    final updatedSettings = {
      ...state,
      option: value,
    };
    state = updatedSettings;
  }
}

final debuggerProvider =
    StateNotifierProvider<DebuggerStateNotifier, Map<DebugOption, dynamic>>(
        (ref) => DebuggerStateNotifier());
