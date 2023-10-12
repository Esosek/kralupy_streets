import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kralupy_streets/models/geolocation.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.geolocation});

  final Geolocation geolocation;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LatLng _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation =
        LatLng(widget.geolocation.latitude, widget.geolocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vybrat lokaci',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(
                Geolocation(
                  latitude: _selectedLocation.latitude,
                  longitude: _selectedLocation.longitude,
                ),
              );
            },
            child: Text(
              'ULOŽIT',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
      body: GoogleMap(
        onCameraMove: (position) {
          setState(() {
            _selectedLocation = position.target;
          });
        },
        onTap: (location) {
          setState(() {
            _selectedLocation = location;
          });
        },
        initialCameraPosition: CameraPosition(
          zoom: 17,
          target: LatLng(
            _selectedLocation.latitude,
            _selectedLocation.longitude,
          ),
        ),
        markers: {
          Marker(
            markerId: const MarkerId('m1'),
            position:
                LatLng(_selectedLocation.latitude, _selectedLocation.longitude),
          ),
        },
      ),
    );
  }
}
