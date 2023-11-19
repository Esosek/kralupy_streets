import 'package:flutter/material.dart';
import 'package:kralupy_streets/widgets/ui/custom_filled_button.dart';

class AnimatedFilledButton extends StatefulWidget {
  const AnimatedFilledButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.foregroundColor,
    this.backgroundColor,
  });

  final String label;
  final void Function() onPressed;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  State<AnimatedFilledButton> createState() => _AnimatedFilledButtonState();
}

class _AnimatedFilledButtonState extends State<AnimatedFilledButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _animation = Tween(begin: 2.0, end: 5.0).animate(_animController);
    _animController.repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => Container(
        decoration: ShapeDecoration(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          shadows: [
            for (int i = 1; i <= 2; i++)
              BoxShadow(
                spreadRadius: i * _animation.value,
                color: Colors.yellow.withOpacity(0.5 / i),
              ),
          ],
        ),
        child: CustomFilledButton(
          widget.label,
          onPressed: widget.onPressed,
          foregroundColor: widget.foregroundColor,
          backgroundColor: widget.backgroundColor,
        ),
      ),
    );
  }
}
