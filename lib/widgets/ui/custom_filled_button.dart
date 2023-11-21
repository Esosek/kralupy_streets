import 'package:flutter/material.dart';

class CustomFilledButton extends StatelessWidget {
  const CustomFilledButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.foregroundColor,
    this.backgroundColor,
    this.isLoading = false,
    this.width,
    this.fitMaxWidth = false,
    this.isThin = false,
  }) : icon = null;

  const CustomFilledButton.withIcon(
    this.label, {
    super.key,
    required this.onPressed,
    required this.icon,
    this.foregroundColor,
    this.backgroundColor,
    this.isLoading = false,
    this.width,
    this.fitMaxWidth = false,
    this.isThin = false,
  });

  final String label;
  final void Function() onPressed;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final IconData? icon;
  final bool isLoading;
  final double? width;

  /// Expands the button to maximum available space.
  final bool fitMaxWidth;

  /// Removes most of the padding for thin button look
  final bool isThin;

  @override
  Widget build(BuildContext context) {
    // Default button content without icon
    Widget btnContent = Text(
      label,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.labelLarge!.copyWith(
            color: foregroundColor ??
                Theme.of(context).colorScheme.onSecondaryContainer,
          ),
    );

    if (isLoading) {
      btnContent = const Center(
        child: CircularProgressIndicator(),
      );
    }
    // Button content with icon
    else if (icon != null) {
      btnContent = Row(
        mainAxisSize: fitMaxWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
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
        padding: isThin ? const EdgeInsets.all(0) : null,
        minimumSize: const Size(50, 36),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        width: fitMaxWidth ? double.infinity : width,
        child: btnContent,
      ),
    );
  }
}
