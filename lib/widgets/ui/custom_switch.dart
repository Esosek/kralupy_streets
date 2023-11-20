import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  const CustomSwitch(
      {super.key,
      required this.label,
      required this.value,
      required this.onChanged});

  final String label;
  final bool value;
  final void Function(bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Switch(
          value: value,
          onChanged: onChanged,
        ),
        Text(label),
      ],
    );
  }
}
