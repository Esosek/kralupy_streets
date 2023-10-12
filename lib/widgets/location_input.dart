import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key});

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  bool _isLoading = true;
  LocationData? locationData;

  void _getLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print('Service not enabled');
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print('Service not enabled');
        return;
      }
    }

    try {
      locationData = await location.getLocation();
    } catch (e) {
      print(e);
    }

    setState(() {
      _isLoading = false;
    });

    if (locationData == null ||
        locationData!.latitude == null ||
        locationData!.longitude == null) {
      return;
    }

    print(locationData!.latitude);
    print(locationData!.longitude);
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 80,
          backgroundColor: Colors.grey.shade300,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : const Text('Loaded'),
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
      ],
    );
  }
}
