import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.onPickImage});

  final Function(File selectedPicture) onPickImage;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? selectedPicture;

  void _takePicture() async {
    final imagePicker = ImagePicker();
    final takenPicture = await imagePicker.pickImage(
        source: ImageSource.camera, maxWidth: 600, imageQuality: 50);

    if (takenPicture == null) {
      return;
    }

    setState(() {
      selectedPicture = File(takenPicture.path);
    });

    widget.onPickImage(selectedPicture!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 290,
      width: double.infinity,
      color: Colors.grey.shade300,
      child: Center(
        child: selectedPicture == null
            ? TextButton.icon(
                onPressed: _takePicture,
                icon: const Icon(Icons.camera_alt_rounded),
                label: Text(
                  'Vyfoť ulici',
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 15,
                      ),
                ),
              )
            : GestureDetector(
                onTap: _takePicture,
                child: Image.file(
                  selectedPicture!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
      ),
    );
  }
}
