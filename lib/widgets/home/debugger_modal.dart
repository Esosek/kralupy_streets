import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kralupy_streets/providers/debugger_provider.dart';
import 'package:kralupy_streets/providers/hunting_provider.dart';
import 'package:kralupy_streets/widgets/ui/custom_filled_button.dart';
import 'package:kralupy_streets/widgets/ui/custom_switch.dart';

class DebuggerModal extends ConsumerStatefulWidget {
  const DebuggerModal({super.key});

  @override
  ConsumerState<DebuggerModal> createState() => _DebuggerModalState();
}

class _DebuggerModalState extends ConsumerState<DebuggerModal> {
  late double _recognizeSuccessRatio;
  String get _formattedRecognizeSuccesRatio {
    return (_recognizeSuccessRatio * 100).toStringAsFixed(0);
  }

  @override
  void initState() {
    _recognizeSuccessRatio =
        ref.read(debuggerProvider)[DebugOption.recognizeSuccessRatio];
    super.initState();
  }

  void _setDebugOption(DebugOption option, dynamic value) {
    ref.read(debuggerProvider.notifier).toggleSetting(option, value);
  }

  @override
  Widget build(BuildContext context) {
    final debugOptions = ref.watch(debuggerProvider);
    final debugEnabled = debugOptions[DebugOption.enabled];

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Debug',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(width: 8),
                    CustomFilledButton(
                      width: 80,
                      debugEnabled ? 'enabled' : 'disabled',
                      foregroundColor: Colors.white,
                      backgroundColor: debugEnabled ? Colors.green : Colors.red,
                      onPressed: () =>
                          _setDebugOption(DebugOption.enabled, !debugEnabled),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomSwitch(
                        label: 'Load next month hunting',
                        value: debugOptions[DebugOption.loadNextHunt],
                        onChanged: (value) =>
                            _setDebugOption(DebugOption.loadNextHunt, value),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomSwitch(
                            label: 'Recognize street',
                            value: debugOptions[DebugOption.recognizeStreet],
                            onChanged: (value) => _setDebugOption(
                                DebugOption.recognizeStreet, value),
                          ),
                          if (debugOptions[DebugOption.recognizeStreet])
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Success ratio',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Row(
                                  children: [
                                    CustomFilledButton(
                                      '0',
                                      isThin: true,
                                      onPressed: () {
                                        _setDebugOption(
                                            DebugOption.recognizeSuccessRatio,
                                            0);
                                        setState(() {
                                          _recognizeSuccessRatio = 0;
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: Slider(
                                        value: _recognizeSuccessRatio,
                                        onChanged: (value) => setState(() =>
                                            _recognizeSuccessRatio = value),
                                        onChangeEnd: (value) => _setDebugOption(
                                            DebugOption.recognizeSuccessRatio,
                                            _recognizeSuccessRatio),
                                      ),
                                    ),
                                    CustomFilledButton(
                                      '100',
                                      isThin: true,
                                      onPressed: () {
                                        _setDebugOption(
                                            DebugOption.recognizeSuccessRatio,
                                            1);
                                        setState(() {
                                          _recognizeSuccessRatio = 1;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                Text(
                                  '$_formattedRecognizeSuccesRatio %',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                        ],
                      ),
                      CustomSwitch(
                        label: 'Print recognized texts from street image',
                        value: debugOptions[DebugOption.printRecognizedTexts],
                        onChanged: (value) => _setDebugOption(
                            DebugOption.printRecognizedTexts, value),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            CustomFilledButton('Save', fitMaxWidth: true, onPressed: () {
              if (context.mounted) {
                ref.read(huntingProvider.notifier).loadHuntingStreets();
                Navigator.pop(context);
              }
            }),
          ],
        ),
      ),
    );
  }
}
