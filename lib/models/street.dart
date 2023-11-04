import 'package:kralupy_streets/models/geolocation.dart';

class Street {
  const Street({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.geolocation,
    this.descriptionParagraphs,
  });

  final int id;
  final String name;
  final String imageUrl;
  final Geolocation geolocation;
  final List<String>? descriptionParagraphs;
}

class HuntingStreet extends Street {
  HuntingStreet(
      {required super.id,
      required super.name,
      required super.imageUrl,
      required super.geolocation,
      required super.descriptionParagraphs,
      this.found = false,
      this.foundDate,
      this.publicFinder});

  HuntingStreet copyWith({
    bool? found,
    String? foundDate,
    String? publicFinder,
  }) {
    return HuntingStreet(
        id: id,
        name: name,
        imageUrl: imageUrl,
        geolocation: geolocation,
        descriptionParagraphs: descriptionParagraphs,
        found: found ?? this.found,
        foundDate: foundDate ?? this.foundDate,
        publicFinder: publicFinder ?? this.publicFinder);
  }

  final bool found;
  final String? foundDate;
  final String? publicFinder;
}
