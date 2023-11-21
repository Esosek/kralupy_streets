import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'package:kralupy_streets/widgets/hunting/hunting_tutorial.dart';
import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/providers/hunting_provider.dart';
import 'package:kralupy_streets/utils/storage_helper.dart';
import 'package:kralupy_streets/widgets/hunting/finder_modal.dart';
import 'package:kralupy_streets/widgets/hunting/hunting_carousel.dart';
import 'package:kralupy_streets/widgets/ui/custom_filled_button.dart';
import 'package:kralupy_streets/utils/custom_logger.dart';
import 'package:kralupy_streets/utils/text_recognizer.dart';

class HuntingScreen extends ConsumerStatefulWidget {
  const HuntingScreen({super.key});

  @override
  ConsumerState<HuntingScreen> createState() => _HuntingScreenState();
}

class _HuntingScreenState extends ConsumerState<HuntingScreen> {
  static const tutorialCompletedPrefsKey = 'tutorialCompleted';
  static const notificationsTopicName = 'hunting';
  final log = CustomLogger('HuntingScreen');
  final textRecognizer = TextRecognizer(debugMode: false, successRatio: 1);
  final storage = StorageHelper();

  int _selectedStreetIndex = 0;
  late HuntingStreet _activeStreet;

  bool _isDecodingImage = false;
  bool _isTutorialCompleted = false;

  String get currentDate {
    DateTime currentDate = DateTime.now();
    String formattedDate =
        '${currentDate.month.toString().padLeft(2, '0')}/${currentDate.year}';
    return formattedDate;
  }

  @override
  void initState() {
    super.initState();
    _setupNotifications();
    final streets = ref.read(huntingProvider);
    _selectedStreetIndex = streets.indexWhere((street) => !street.found);
    _isTutorialCompleted =
        storage.getBoolValue(tutorialCompletedPrefsKey) ?? false;

    // Prevents crash when everything is hunted
    if (_selectedStreetIndex.isNegative) {
      _selectedStreetIndex = 0;
    }
  }

  void _setupNotifications() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    fcm.subscribeToTopic(notificationsTopicName);
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

    // Debugging text recognizer
    // final takenPicture = await downloadAndSaveImage(
    //     'url');

    if (takenPicture == null) {
      setState(() {
        _isDecodingImage = false;
      });
      return;
    }
    final isValidImage = await textRecognizer.analyzeImageForText(
        takenPicture.path, activeStreet.keywords);

    if (isValidImage) {
      String username = '';
      if (await _isPlayerFirst) {
        username = await _showFinderModal() ?? '';
      }
      log.info('Street ${activeStreet.name} was successfully hunted');
      ref.read(huntingProvider.notifier).huntStreet(
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
    final hasFinder =
        await ref.read(huntingProvider.notifier).hasFinder(_activeStreet.id);
    return !hasFinder;
  }

  Future<String?> _showFinderModal() async {
    return showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isDismissible: false,
      isScrollControlled: true,
      builder: (context) => const FinderModal(),
    );
  }

  Future<void> _completeTutorial() async {
    log.info('Tutorial completed');
    setState(() => _isTutorialCompleted = true);
    storage.setBoolValue(tutorialCompletedPrefsKey, true);
  }

  // For debugging purposes
  Future<File?> downloadAndSaveImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getApplicationCacheDirectory();
        final filePath = '${directory.path}/image.jpg';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        // Handle HTTP error
        return null;
      }
    } catch (e) {
      // Handle other exceptions
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final streets = ref.watch(huntingProvider);
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
          title: Text('Lovení $currentDate'),
          actions: [
            if (_isTutorialCompleted)
              IconButton(
                onPressed: () {
                  log.trace('Tutorial requested by user');
                  setState(() => _isTutorialCompleted = false);
                },
                icon: const Icon(Icons.question_mark_rounded),
              ),
          ],
        ),
        body: !_isTutorialCompleted
            ? HuntingTutorial(
                onComplete: _completeTutorial,
              )
            : Padding(
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
                      scrollDirection:
                          isLandscape ? Axis.vertical : Axis.horizontal,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
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
