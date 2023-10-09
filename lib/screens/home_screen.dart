import 'package:flutter/material.dart';

import 'package:kralupy_streets/data/dummy_streets.dart';
import 'package:kralupy_streets/screens/add_street.dart';
import 'package:kralupy_streets/screens/game_screen.dart';
import 'package:kralupy_streets/screens/streets_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _switchScreen(BuildContext context, Widget screenWidget) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => screenWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1),
                  ),
                  child: Image.asset('assets/images/city_sign.png'),
                ),
                const SizedBox(height: 70),
                ElevatedButton(
                  onPressed: () => _switchScreen(
                    context,
                    const GameScreen(
                      streets: dummyStreets,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Text(
                      'Nová hra',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () => _switchScreen(
                      context,
                      StreetScreen(
                        streets: dummyStreets,
                      )),
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Text(
                      'Ulice',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
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
            ),
          ),
        ),
      ),
    );
  }
}
