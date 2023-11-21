import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/screens/street_detail_screen.dart';
import 'package:kralupy_streets/widgets/ui/street_image.dart';

class StreetListItem extends ConsumerWidget {
  const StreetListItem(this.street, {super.key});

  final Street street;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => StreetDetailScreen(street),
        ),
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        color: Theme.of(context).colorScheme.primaryContainer,
        child: SizedBox(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: StreetImage(
                  street,
                  height: 90,
                  condensedError: true,
                ),
              ),
              Positioned(
                bottom: 5,
                left: 5,
                right: 5,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    street.name,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
