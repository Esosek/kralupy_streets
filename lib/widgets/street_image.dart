import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/providers/image_provider.dart';

class StreetImage extends ConsumerWidget {
  const StreetImage(this.street,
      {this.height, this.condensed = false, super.key});

  final Street street;
  final double? height;
  final bool condensed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePath = ref.read(imageProvider.notifier).getImagePath(street);
    final failContainer = Container(
      color: Colors.grey.shade200,
      height: 90,
      width: double.infinity,
      child: Center(
        child: condensed
            ? const Center(
                child: Icon(
                  Icons.error_outline_rounded,
                  color: Colors.grey,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Nahrávání obrázku selhalo. Zkontrolujte prosím své připojení.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
      ),
    );
    return FutureBuilder(
      future: imagePath,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return failContainer;
        } else {
          if (snapshot.hasData) {
            final imagePath = snapshot.data;
            if (imagePath!.isNotEmpty) {
              return Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                height: height,
                width: double.infinity,
              );
            } else {
              return failContainer;
            }
          } else {
            return failContainer;
          }
        }
      },
    );
  }
}
