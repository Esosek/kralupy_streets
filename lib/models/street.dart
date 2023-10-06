import 'package:kralupy_streets/models/location.dart';

class Street {
  const Street({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.location,
  });

  final int id;
  final String name;
  final String imageUrl;
  final Location location;
}
