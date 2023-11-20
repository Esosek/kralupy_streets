import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kralupy_streets/widgets/ui/custom_filled_button.dart';
import 'package:kralupy_streets/widgets/ui/custom_switch.dart';

class DebuggerModal extends ConsumerStatefulWidget {
  const DebuggerModal({super.key});

  @override
  ConsumerState<DebuggerModal> createState() => _DebuggerModalState();
}

class _DebuggerModalState extends ConsumerState<DebuggerModal> {
  @override
  Widget build(BuildContext context) {
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
                    Text(
                      'Debug',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(width: 8),
                    CustomFilledButton(
                      'disabled',
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      onPressed: () {},
                    ),
                  ],
                ),
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Switch(
                            value: false,
                            onChanged: (value) {},
                          ),
                          const Text('Load next month hunting'),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Switch(
                                value: false,
                                onChanged: (value) {},
                              ),
                              const Text('Recognize street'),
                            ],
                          ),
                          Text(
                            'Success ratio',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Slider(
                            value: 0.5,
                            onChanged: (value) {},
                          ),
                          Text(
                            '50 %',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      CustomSwitch(
                          label: 'Print recognized texts from street image',
                          value: false,
                          onChanged: (value) {}),
                    ],
                  ),
                ),
              ],
            ),
            CustomFilledButton('Apply', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
