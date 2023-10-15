import 'package:flutter/material.dart';

import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/screens/street_detail_screen.dart';

class StreetListItem extends StatelessWidget {
  const StreetListItem(this.street, {super.key});

  final Street street;

  @override
  Widget build(BuildContext context) {
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
                child: Image.network(
                  street.imageUrl,
                  fit: BoxFit.fill,
                  height: 90,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
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
