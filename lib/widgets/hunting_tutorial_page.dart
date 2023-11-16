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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Flex(
        direction: isLandscape ? Axis.horizontal : Axis.vertical,
        mainAxisAlignment:
            isLandscape ? MainAxisAlignment.center : MainAxisAlignment.start,
        crossAxisAlignment:
            isLandscape ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            height:
                MediaQuery.of(context).size.height / (isLandscape ? 2.5 : 4),
            child: Image.asset(
              imagePath,
            ),
          ),
          SizedBox.square(dimension: MediaQuery.of(context).size.height * .1),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLandscape)
                SizedBox(height: MediaQuery.of(context).size.height * .1),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.w600, fontSize: 26),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width:
                    isLandscape ? MediaQuery.of(context).size.width / 2 : null,
                child: Text(
                  body,
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
