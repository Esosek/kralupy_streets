import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

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
  static const platform =
      MethodChannel('com.example.kralupy_streets/text_recognition');

  int _selectedStreetIndex = 0;
  late HuntingStreet _activeStreet;

  void _onPageChanged(int index) {
    setState(() {
      _selectedStreetIndex = index;
    });
  }

  void _huntStreet(HuntingStreet activeStreet) async {
    final imagePicker = ImagePicker();
    final takenPicture = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1008,
      imageQuality: 50,
      requestFullMetadata: false,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (takenPicture == null) {
      return;
    }
    // START testing asset image
    final ByteData assetData =
        await rootBundle.load('assets/images/street_multiple_text.jpg');
    final List<int> byteList = assetData.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final tempFile = await File('${tempDir.path}/street_multiple_text.jpg')
        .writeAsBytes(byteList);

    final List<String> result = await _analyzeImage(tempFile.path);
    // END testing asset image

    // Production variant
    //final List<String> result = await _analyzeImage(takenPicture.path);
    debugPrint('Recognized text: $result');
    const keyword = 'PALACKEHO';
    if (result.contains(keyword)) {
      print('street name matched');
    }

    //ref.read(huntingStreetProvider.notifier).huntStreet(activeStreet.id);
  }

  Future<List<String>> _analyzeImage(String takenImagePath) async {
    try {
      final result = await platform.invokeMethod<List>('analyzeImage', {
        'imagePath': takenImagePath,
      });
      return result?.map((item) => item.toString()).toList() ?? [];
    } on PlatformException catch (e) {
      debugPrint(e.message);
      return [];
    }
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
