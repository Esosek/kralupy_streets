import 'package:flutter/material.dart';

import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/screens/add_street.dart';
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
          // actions: [
          //   IconButton(
          //     onPressed: () {},
          //     icon: const Icon(Icons.filter_alt_rounded),
          //   ),
          // ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddStreet(),
            ),
          ),
          child: const Icon(Icons.add),
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
