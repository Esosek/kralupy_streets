import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kralupy_streets/providers/hunting_street_provider.dart';
import 'package:kralupy_streets/screens/add_street.dart';
import 'package:kralupy_streets/screens/game_screen.dart';
import 'package:kralupy_streets/screens/hunting_screen.dart';
import 'package:kralupy_streets/screens/streets_screen.dart';
import 'package:kralupy_streets/widgets/ui/custom_filled_button.dart';

class HomeButtons extends ConsumerWidget {
  const HomeButtons({super.key});

  void _switchScreen(BuildContext context, Widget screenWidget) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => screenWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final huntingStreets = ref.watch(huntingStreetProvider);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomFilledButton(
          'Nová hra',
          onPressed: () => _switchScreen(
            context,
            const GameScreen(),
          ),
        ),
        const SizedBox(height: 18),
        if (huntingStreets.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 45),
            child: CustomFilledButton(
              'Lovení',
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              onPressed: () => _switchScreen(
                context,
                const HuntingScreen(),
              ),
            ),
          ),
        CustomFilledButton(
          'Ulice',
          onPressed: () => _switchScreen(
            context,
            const StreetScreen(),
          ),
        ),
        const SizedBox(height: 18),
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
