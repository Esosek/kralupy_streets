import 'package:flutter/material.dart';

import 'package:kralupy_streets/models/street.dart';

class StreetSign extends StatelessWidget {
  const StreetSign(this.street, {super.key, this.size = 160});

  final Street street;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('assets/images/street_sign_template.png'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                street.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 19,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
