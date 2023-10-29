import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/providers/image_provider.dart';

class StreetImage extends ConsumerWidget {
  const StreetImage(this.street, {this.height, super.key});

  final Street street;
  final double? height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePath = ref.read(imageProvider.notifier).getImagePath(street);
    final failContainer = Container(
      color: Colors.grey.shade200,
      height: 90,
      width: double.infinity,
      child: Center(
        child: Text(
          'Nahrávání obrázku selhalo',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
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