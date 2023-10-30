import 'package:flutter/material.dart';

import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/screens/add_street.dart';
import 'package:kralupy_streets/screens/game_screen.dart';
import 'package:kralupy_streets/screens/streets_screen.dart';

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
        ElevatedButton(
          onPressed: () => _switchScreen(
            context,
            const GameScreen(),
          ),
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Text(
              'Nová hra',
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        ElevatedButton(
          onPressed: () => _switchScreen(
            context,
            const StreetScreen(),
          ),
          style: ElevatedButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.secondaryContainer),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Text(
              'Ulice',
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
            ),
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
