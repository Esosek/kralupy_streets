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
  HuntingStreet({
    required int id,
    required String name,
    required String imageUrl,
    required Geolocation geolocation,
    List<String>? descriptionParagraphs,
    String? keyword,
    this.found = false,
    this.foundDate,
    this.publicFinder,
  }) : super(
          id: id,
          name: name,
          imageUrl: imageUrl,
          geolocation: geolocation,
          descriptionParagraphs: descriptionParagraphs,
        ) {
    this.keyword = keyword ?? name;
  }

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
        keyword: keyword,
        found: found ?? this.found,
        foundDate: foundDate ?? this.foundDate,
        publicFinder: publicFinder ?? this.publicFinder);
  }

  /// Text recognition is looking for this
  /// If it's not povided => street name is assigned
  late String keyword;
  final bool found;
  final String? foundDate;
  final String? publicFinder;
}
