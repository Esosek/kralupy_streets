import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/utils/api_keys.dart';

final analytics = FirebaseAnalytics.instance;

class StreetDetailScreen extends StatelessWidget {
  const StreetDetailScreen(this.street, {super.key});

  final Street street;

  void _logVisit() {
    analytics.logEvent(
      name: 'street_detail_visit',
      parameters: {
        'street_name': street.name,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _logVisit();
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final lat = street.geolocation.latitude;
    final lng = street.geolocation.longitude;

    Widget mapPreview = Container(
      color: const Color.fromRGBO(224, 224, 224, 1),
      width: double.infinity,
      child: Image.network(
        'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=17&size=600x300&maptype=roadmap&markers=color:red%7C$lat,$lng&key=$googleApiKey',
        fit: BoxFit.fitWidth,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        mapPreview,
        if (street.descriptionParagraphs != null)
          for (String paragraph in street.descriptionParagraphs!)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                paragraph,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
        const SizedBox(height: 16),
        Image.network(street.imageUrl),
      ],
    );

    if (isLandscape) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (street.descriptionParagraphs != null)
            for (String paragraph in street.descriptionParagraphs!)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  paragraph,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(street.imageUrl),
              ),
              const SizedBox(width: 20),
              Expanded(child: mapPreview),
            ],
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(street.name),
      ),
      body: SingleChildScrollView(
        padding: isLandscape
            ? const EdgeInsets.symmetric(vertical: 6, horizontal: 16)
            : const EdgeInsets.all(16),
        child: content,
      ),
    );
  }
}
