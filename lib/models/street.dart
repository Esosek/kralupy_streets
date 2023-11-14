import 'package:kralupy_streets/models/geolocation.dart';

class Street {
  const Street({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.geolocation,
    this.descriptionParagraphs,
    this.finder,
  });

  final int id;
  final String name;
  final String imageUrl;
  final Geolocation geolocation;
  final List<String>? descriptionParagraphs;
  final String? finder;
}

class HuntingStreet extends Street {
  HuntingStreet({
    required int id,
    required String name,
    required String imageUrl,
    required Geolocation geolocation,
    List<String>? descriptionParagraphs,
    String? keyword,
    String? finder,
    this.found = false,
    this.foundDate,
  }) : super(
            id: id,
            name: name,
            imageUrl: imageUrl,
            geolocation: geolocation,
            descriptionParagraphs: descriptionParagraphs,
            finder: finder) {
    this.keyword = keyword ?? name;
  }

  HuntingStreet copyWith({
    bool? found,
    String? foundDate,
    String? finder,
  }) {
    return HuntingStreet(
        id: id,
        name: name,
        imageUrl: imageUrl,
        geolocation: geolocation,
        descriptionParagraphs: descriptionParagraphs,
        keyword: keyword,
        found: found ?? this.found,
        foundDate: foundDate ?? this.foundDate,
        finder: finder ?? this.finder);
  }

  /// Text recognition is looking for this
  /// If it's not povided => street name is assigned
  late String keyword;
  final bool found;
  final String? foundDate;
}
