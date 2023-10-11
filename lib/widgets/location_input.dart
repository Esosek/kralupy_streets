import 'package:flutter/material.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key});

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  void _getLocation() {}
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CircleAvatar(
        radius: 80,
        backgroundColor: Colors.grey.shade300,
      ),
      TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.location_on),
        label: Text(
          'Změnit umístění',
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 15,
              ),
        ),
      ),
    ]);
  }
}
