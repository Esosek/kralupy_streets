import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import 'package:kralupy_streets/screens/map_screen.dart';
import 'package:kralupy_streets/models/geolocation.dart';
import 'package:kralupy_streets/utils/api_keys.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onLocationSet});

  final void Function(
      {required Geolocation geolocation,
      required String streetName}) onLocationSet;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  bool _isLoading = true;
  double? lat;
  double? lng;

  Future<void> _saveStreet() async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleApiKey');

    try {
      final response = await http.get(url);
      final resData = json.decode(response.body);

      final fetchedStreetName =
          resData['results'][0]['address_components'][2]['long_name'];

      setState(() {
        _isLoading = false;
      });

      widget.onLocationSet(
          geolocation: Geolocation(latitude: lat!, longitude: lng!),
          streetName: fetchedStreetName);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _getLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    try {
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      locationData = await location.getLocation();
    } catch (e) {
      // Handle errors
      setState(() => _isLoading = false);
      return;
    }
    if (locationData.latitude == null || locationData.longitude == null) {
      return;
    }

    setState(() {
      lat = locationData.latitude!;
      lng = locationData.longitude!;
    });

    _saveStreet();
  }

  void _getManualLocation() async {
    if (lat == null || lng == null) {
      return;
    }

    final newLocation = await Navigator.of(context).push<Geolocation>(
      MaterialPageRoute(
        builder: (context) => MapScreen(
          geolocation: Geolocation(latitude: lat!, longitude: lng!),
        ),
      ),
    );

    if (newLocation == null) {
      return;
    }

    setState(() {
      lat = newLocation.latitude;
      lng = newLocation.longitude;
    });

    _saveStreet();
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
          radius: 90,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: lat != null && lng != null
              ? NetworkImage(
                  'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=17&size=600x300&maptype=roadmap&markers=color:red%7C$lat,$lng&key=$googleApiKey',
                )
              : null,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : null,
        ),
        if (!_isLoading)
          TextButton.icon(
            onPressed: _getManualLocation,
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
