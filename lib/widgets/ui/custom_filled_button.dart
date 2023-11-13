import 'package:flutter/material.dart';

class CustomFilledButton extends StatelessWidget {
  const CustomFilledButton(this.label,
      {super.key,
      required this.onPressed,
      this.foregroundColor,
      this.backgroundColor,
      this.isLoading = false,
      this.width,
      this.fitMaxWidth = false})
      : icon = null;

  const CustomFilledButton.withIcon(this.label,
      {super.key,
      required this.onPressed,
      required this.icon,
      this.foregroundColor,
      this.backgroundColor,
      this.isLoading = false,
      this.width,
      this.fitMaxWidth = false});

  final String label;
  final void Function() onPressed;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final bool fitMaxWidth;

  @override
  Widget build(BuildContext context) {
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
    } else if (icon != null) {
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
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: SizedBox(
          width: fitMaxWidth ? double.infinity : width,
          child: btnContent,
        ),
      ),
    );
  }
}
