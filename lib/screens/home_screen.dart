import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kralupy_streets/providers/hunting_provider.dart';
import 'package:kralupy_streets/providers/street_provider.dart';
import 'package:kralupy_streets/widgets/home/home_buttons.dart';
import 'package:kralupy_streets/widgets/home/version_text.dart';

final db = FirebaseFirestore.instance;
final analytics = FirebaseAnalytics.instance;
const appVersion = '1.2.1';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    ref.read(originalStreetProvider.notifier).loadStreets();
    ref.read(huntingProvider.notifier).loadHuntingStreets();
  }

  @override
  Widget build(BuildContext context) {
    final streets = ref.watch(enrichedStreetProvider);
    if (streets.isNotEmpty) {
      _isLoading = false;
    }
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Fetching streets data...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Flex(
                          direction:
                              isLandscape ? Axis.horizontal : Axis.vertical,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: isLandscape
                                  ? MediaQuery.of(context).size.width * 0.25
                                  : MediaQuery.of(context).size.width * 0.8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(width: 1),
                              ),
                              child: Image.asset(
                                'assets/images/city_sign.png',
                              ),
                            ),
                            const SizedBox(
                              width: 60,
                              height: 60,
                            ),
                            const HomeButtons(),
                          ],
                        ),
                      ),
                      const VersionText(appVersion),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
