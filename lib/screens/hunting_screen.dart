import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/providers/hunting_street_provider.dart';
import 'package:kralupy_streets/utils/storage_helper.dart';
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
  static const usernamePrefsKey = 'username';
  final log = CustomLogger('HuntingScreen');
  final textRecognizer = TextRecognizer(debugMode: true, successRatio: 1);
  final storage = StorageHelper();
  final _usernameTextController = TextEditingController();

  int _selectedStreetIndex = 0;
  late HuntingStreet _activeStreet;

  bool _isDecodingImage = false;

  @override
  void initState() {
    super.initState();
    final streets = ref.read(huntingStreetProvider);
    _selectedStreetIndex = streets.indexWhere((street) => !street.found);

    _usernameTextController.text =
        storage.getStringValue(usernamePrefsKey) ?? '';

    // Prevents crash when everything is hunted
    if (_selectedStreetIndex.isNegative) {
      _selectedStreetIndex = 0;
    }
  }

  @override
  void dispose() {
    _usernameTextController.dispose();
    super.dispose();
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
      String username = '';
      if (await _isPlayerFirst) {
        await _showFinderModal();
        username = _usernameTextController.text.trim();
      }
      log.info('Street ${activeStreet.name} was successfully hunted');
      ref.read(huntingStreetProvider.notifier).huntStreet(
            activeStreet.id,
            username.isEmpty ? null : username,
          );
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

  Future<bool> get _isPlayerFirst async {
    final hasFinder = await ref
        .read(huntingStreetProvider.notifier)
        .hasFinder(_activeStreet.id);
    return !hasFinder;
  }

  Future<void> _showFinderModal() async {
    return showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isDismissible: false,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Gratulujeme!',
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Jste první, kdo ulovil tuto ulici. Vyplňte svou přezdívku a ukažte všem, že právě vy jste tuto záhadu vyřešili!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameTextController,
              maxLength: 15,
              autocorrect: false,
              decoration: const InputDecoration(
                label: Text('Přezdívka'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Přeskočit'),
            ),
            const SizedBox(height: 8),
            CustomFilledButton(
              'Odeslat',
              fitMaxWidth: true,
              onPressed: _sendFinder,
            ),
          ],
        ),
      ),
    );
  }

  void _sendFinder() {
    final username = _usernameTextController.text;
    Navigator.of(context).pop();
    storage.setStringValue(usernamePrefsKey, username);
  }

  @override
  Widget build(BuildContext context) {
    final streets = ref.watch(huntingStreetProvider);
    _activeStreet = streets[_selectedStreetIndex];
    final isFound = _activeStreet.found;
    final streetName = isFound ? _activeStreet.name : '???';
    final publicFinder = _activeStreet.finder?.trim();
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
                                  'První ulovil/a ${_activeStreet.finder}',
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
                            width: 90,
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
