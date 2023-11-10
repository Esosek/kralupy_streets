import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/providers/hunting_street_provider.dart';
import 'package:kralupy_streets/widgets/hunting_carousel.dart';
import 'package:kralupy_streets/widgets/ui/custom_filled_button.dart';
import 'package:kralupy_streets/utils/custom_logger.dart';
import 'package:kralupy_streets/utils/text_recognizer.dart';

class HuntingScreen extends ConsumerStatefulWidget {
  const HuntingScreen({super.key});

  @override
  ConsumerState<HuntingScreen> createState() => _HuntingScreenState();
}

class _HuntingScreenState extends ConsumerState<HuntingScreen> {
  final log = CustomLogger('HuntingScreen');
  final textRecognizer = TextRecognizer(debugMode: true, successRatio: .5);

  int _selectedStreetIndex = 0;
  late HuntingStreet _activeStreet;

  bool _isDecodingImage = false;

  @override
  void initState() {
    super.initState();
    final streets = ref.read(huntingStreetProvider);
    _selectedStreetIndex = streets.indexWhere((street) => !street.found);

    // Prevents crash when everything is hunted
    if (_selectedStreetIndex.isNegative) {
      _selectedStreetIndex = 0;
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedStreetIndex = index;
    });
  }

  void _huntStreet(HuntingStreet activeStreet) async {
    setState(() {
      _isDecodingImage = true;
    });
    final imagePicker = ImagePicker();
    final takenPicture = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1008,
      imageQuality: 50,
      requestFullMetadata: false,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (takenPicture == null) {
      setState(() {
        _isDecodingImage = false;
      });
      return;
    }
    final isValidImage = await textRecognizer.analyzeImageForText(
        takenPicture.path, activeStreet.keyword);

    if (isValidImage) {
      log.info('Street ${activeStreet.name} was successfully hunted');
      ref.read(huntingStreetProvider.notifier).huntStreet(activeStreet.id);
    } else {
      log.trace('Street hunting failed, showing SnackBar');
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 10),
            content: Text(
                'Omlouváme se, ale ulice nebyla rozpoznána. Zkuste to prosím znovu a ujistěte se, že je cedule s názvem ulice čitelná a dobře viditelná.'),
          ),
        );
      }
    }
    setState(() {
      _isDecodingImage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final streets = ref.watch(huntingStreetProvider);
    _activeStreet = streets[_selectedStreetIndex];
    final isFound = _activeStreet.found;
    final streetName = isFound ? _activeStreet.name : '???';
    final publicFinder = _activeStreet.publicFinder?.trim();
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
                    child: _activeStreet.found
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Uloveno ${_activeStreet.foundDate}',
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
                                  'První ulovil/a ${_activeStreet.publicFinder}',
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
                            fixWidth: 90,
                            isLoading: _isDecodingImage,
                            onPressed: () => _huntStreet(_activeStreet),
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
