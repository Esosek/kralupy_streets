import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:kralupy_streets/utils/custom_logger.dart';
import 'package:path_provider/path_provider.dart';

import 'package:kralupy_streets/models/street.dart';

class ImageNotifier extends StateNotifier<Map<int, String>> {
  ImageNotifier() : super({});

  final log = CustomLogger('ImageProvider');

  Future<String> getImagePath(Street street) async {
    if (state[street.id] == null) {
      final filePath = await _downloadImage(street.id, street.imageUrl);
      if (filePath.isNotEmpty) {
        state = {...state, street.id: filePath};
      }
      return filePath;
    }
    return state[street.id]!;
  }

  // Returns image filepath or '' on failure
  Future<String> _downloadImage(int streetId, String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/street_$streetId.jpg';

        File imageFile = File(filePath);
        await imageFile.writeAsBytes(response.bodyBytes);

        log.trace('Image downloaded and saved at $filePath');
        return filePath;
      } else {
        log.warning(
            'Failed to download image. HTTP Status Code: ${response.statusCode}');
      }
    } catch (e) {
      log.error('Error downloading image: $e');
    }
    return '';
  }
}

final imageProvider = StateNotifierProvider<ImageNotifier, Map<int, String>>(
    (ref) => ImageNotifier());
