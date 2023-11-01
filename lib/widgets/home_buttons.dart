import 'package:flutter/material.dart';

import 'package:kralupy_streets/screens/add_street.dart';
import 'package:kralupy_streets/screens/game_screen.dart';
import 'package:kralupy_streets/screens/streets_screen.dart';
import 'package:kralupy_streets/widgets/ui/custom_filled_button.dart';

class HomeButtons extends StatelessWidget {
  const HomeButtons({super.key});

  void _switchScreen(BuildContext context, Widget screenWidget) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => screenWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomFilledButton(
          'Nová hra',
          onPressed: () => _switchScreen(
            context,
            const GameScreen(),
          ),
        ),
        const SizedBox(height: 18),
        CustomFilledButton(
          'Ulice',
          onPressed: () => _switchScreen(
            context,
            const StreetScreen(),
          ),
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: () => _switchScreen(context, const AddStreet()),
          icon: const Icon(Icons.camera_alt),
          label: Text(
            'Přidat novou ulici',
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
      ],
    );
  }
}
