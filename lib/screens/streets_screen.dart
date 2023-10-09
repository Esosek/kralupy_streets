import 'package:flutter/material.dart';

import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/widgets/street_list_item.dart';

class StreetScreen extends StatelessWidget {
  const StreetScreen({super.key, required this.streets});

  final List<Street> streets;

  @override
  Widget build(BuildContext context) {
    final sortedStreets = List.of(streets);
    sortedStreets.sort(
      (a, b) => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
    );
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ulice'),
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: streets.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
          ),
          itemBuilder: (context, index) {
            return StreetListItem(
              sortedStreets[index],
            );
          },
        ),
      ),
    );
  }
}
