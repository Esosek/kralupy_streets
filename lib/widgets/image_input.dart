import 'package:flutter/material.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({super.key});

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey.shade300,
      child: Center(
        child: TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.camera_alt_rounded),
          label: Text(
            'Vyfoť ulici',
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 15,
                ),
          ),
        ),
      ),
    );
  }
}
