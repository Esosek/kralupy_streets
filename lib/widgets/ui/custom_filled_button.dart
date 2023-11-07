import 'package:flutter/material.dart';

class CustomFilledButton extends StatelessWidget {
  const CustomFilledButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.foregroundColor,
    this.backgroundColor,
    this.isLoading = false,
    this.fixWidth,
  }) : icon = null;

  const CustomFilledButton.withIcon(
    this.label, {
    super.key,
    required this.onPressed,
    required this.icon,
    this.foregroundColor,
    this.backgroundColor,
    this.isLoading = false,
    this.fixWidth,
  });

  final String label;
  final void Function() onPressed;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final IconData? icon;
  final bool isLoading;
  final double? fixWidth;

  @override
  Widget build(BuildContext context) {
    Widget btnContent = Text(
      label,
      style: Theme.of(context).textTheme.labelLarge!.copyWith(
            color: foregroundColor ??
                Theme.of(context).colorScheme.onSecondaryContainer,
          ),
    );

    if (isLoading) {
      btnContent = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (icon != null) {
      btnContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: Icon(icon),
            ),
          btnContent
        ],
      );
    }
    final backgroundColor = this.backgroundColor ??
        Theme.of(context).colorScheme.secondaryContainer;
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isLoading ? Colors.grey.shade200 : backgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: SizedBox(width: fixWidth, child: btnContent),
      ),
    );
  }
}
