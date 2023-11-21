import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kralupy_streets/providers/street_provider.dart';
import 'package:kralupy_streets/screens/add_street.dart';
import 'package:kralupy_streets/widgets/streets_screen/street_list_item.dart';

class StreetScreen extends ConsumerWidget {
  const StreetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streets = ref.watch(enrichedStreetProvider);
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final sortedStreets = List.of(streets);
    sortedStreets.sort(
      (a, b) => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
    );
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Ulice (${streets.length})'),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddStreet(),
                ),
              ),
              icon: const Icon(Icons.add),
            ),
            // IconButton(
            //   onPressed: () {},
            //   icon: const Icon(Icons.filter_alt_rounded),
            // ),
          ],
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: streets.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isLandscape ? 5 : 3,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            mainAxisExtent: 125,
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
