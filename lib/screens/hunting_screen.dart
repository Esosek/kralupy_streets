import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/providers/hunting_street_provider.dart';
import 'package:kralupy_streets/widgets/hunting_carousel.dart';
import 'package:kralupy_streets/widgets/ui/custom_filled_button.dart';

class HuntingScreen extends ConsumerStatefulWidget {
  const HuntingScreen({super.key});

  @override
  ConsumerState<HuntingScreen> createState() => _HuntingScreenState();
}

class _HuntingScreenState extends ConsumerState<HuntingScreen> {
  int _selectedStreetIndex = 0;

  void _onPageChanged(int index) {
    setState(() {
      _selectedStreetIndex = index;
    });
  }

  void _huntStreet(HuntingStreet activeStreet) {
    ref.read(huntingStreetProvider.notifier).huntStreet(activeStreet.id);
  }

  @override
  Widget build(BuildContext context) {
    final streets = ref.watch(huntingStreetProvider);
    final activeStreet = streets[_selectedStreetIndex];
    final isFound = activeStreet.found;
    final streetName = isFound ? activeStreet.name : '???';
    final publicFinder = activeStreet.publicFinder?.trim();
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final streetLabelWidget = Text(
      streetName,
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: isFound ? Colors.black : Colors.grey,
            fontStyle: isFound ? FontStyle.normal : FontStyle.italic,
          ),
    );
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lovení 12/2023'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Flex(
            direction: isLandscape ? Axis.horizontal : Axis.vertical,
            mainAxisAlignment: isLandscape
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.spaceEvenly,
            children: [
              if (!isLandscape) streetLabelWidget,
              HuntingCarousel(
                streets,
                currentIndex: _selectedStreetIndex,
                scrollDirection: isLandscape ? Axis.vertical : Axis.horizontal,
                onPageChanged: _onPageChanged,
              ),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (isLandscape) streetLabelWidget,
                  SizedBox(
                    height: isLandscape ? null : 55,
                    child: activeStreet.found
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Uloveno ${activeStreet.foundDate}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                              const SizedBox(height: 7),
                              if (publicFinder != null)
                                Text(
                                  'První ulovil/a ${activeStreet.publicFinder}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                            ],
                          )
                        : CustomFilledButton.withIcon(
                            'Ulovit',
                            icon: Icons.camera_alt_rounded,
                            onPressed: () => _huntStreet(activeStreet),
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }
}
