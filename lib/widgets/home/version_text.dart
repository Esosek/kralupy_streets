import 'dart:async';

import 'package:flutter/material.dart';

import 'package:kralupy_streets/utils/custom_logger.dart';
import 'package:kralupy_streets/widgets/home/debugger_modal.dart';

class VersionText extends StatefulWidget {
  const VersionText(this.version, {super.key});

  final String version;

  @override
  State<VersionText> createState() => _VersionTextState();
}

class _VersionTextState extends State<VersionText> {
  final log = CustomLogger('Debugger');
  final _requiredDuration = const Duration(seconds: 3);

  bool _isPressed = false;

  void _handleLongPress() {
    setState(() {
      _isPressed = true;
    });
    Timer(_requiredDuration, () {
      if (_isPressed) {
        log.debug('Opening debug settings modal');
        showModalBottomSheet(
          context: context,
          enableDrag: false,
          builder: (context) => const DebuggerModal(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _handleLongPress,
      onLongPressEnd: (_) => setState(() => _isPressed = false),
      child: Text(
        'v${widget.version}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
