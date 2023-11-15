import 'package:flutter/material.dart';

class HuntingTutorialPage extends StatelessWidget {
  const HuntingTutorialPage({
    super.key,
    required this.title,
    required this.body,
    required this.imagePath,
  });

  final String title;
  final String body;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 4,
            child: Image.asset(
              imagePath,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * .1),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.w600, fontSize: 26),
              ),
              const SizedBox(height: 12),
              Text(
                body,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
