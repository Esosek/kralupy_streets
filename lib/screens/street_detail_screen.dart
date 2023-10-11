import 'package:flutter/material.dart';

import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/utils/api_keys.dart';

class StreetDetailScreen extends StatelessWidget {
  const StreetDetailScreen(this.street, {super.key});

  final Street street;

  @override
  Widget build(BuildContext context) {
    final lat = street.geolocation.latitude;
    final lng = street.geolocation.longitude;
    return Scaffold(
      appBar: AppBar(
        title: Text(street.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.grey.shade300,
              height: 172,
              child: Image.network(
                'https://maps.googleapis.com/maps/api/staticmap?center=${lat},${lng}&zoom=17&size=600x300&maptype=roadmap&markers=color:red%7C$lat,$lng&key=$googleApiKey',
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
            ),
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
        ),
      ),
    );
  }
}