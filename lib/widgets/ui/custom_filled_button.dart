import 'package:flutter/material.dart';

class CustomFilledButton extends StatelessWidget {
  const CustomFilledButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.foregroundColor,
    this.backgroundColor,
  }) : icon = null;

  const CustomFilledButton.withIcon(
    this.label, {
    super.key,
    required this.onPressed,
    required this.icon,
    this.foregroundColor,
    this.backgroundColor,
  });

  final String label;
  final void Function() onPressed;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = this.backgroundColor ??
        Theme.of(context).colorScheme.secondaryContainer;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: backgroundColor),
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Icon(icon),
                ),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: foregroundColor ??
                          Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
            ],
          )),
    );
  }
}
