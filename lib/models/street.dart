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
    Street street, {
    this.found = false,
    this.foundDate,
  }) : super(
          id: street.id,
          name: street.name,
          imageUrl: street.imageUrl,
          geolocation: street.geolocation,
          descriptionParagraphs: street.descriptionParagraphs,
        );

  final bool found;
  final DateTime? foundDate;
}
