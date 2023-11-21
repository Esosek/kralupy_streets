import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/widgets/ui/street_image.dart';

class HuntingCarousel extends StatelessWidget {
  const HuntingCarousel(
    this.streets, {
    super.key,
    required this.currentIndex,
    required this.onPageChanged,
    this.scrollDirection = Axis.horizontal,
  });

  final List<HuntingStreet> streets;
  final int currentIndex;
  final Axis scrollDirection;
  final void Function(int index) onPageChanged;

  @override
  Widget build(BuildContext context) {
    List<Widget> carouselItemWidgets = streets
        .map((street) => StreetImage(
              street,
            ))
        .toList();
    final isHorizontalScroll = scrollDirection == Axis.horizontal;
    return Flex(
      direction: isHorizontalScroll ? Axis.vertical : Axis.horizontal,
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider(
          items: carouselItemWidgets,
          options: CarouselOptions(
            aspectRatio: isHorizontalScroll ? 16 / 9 : 14 / 9,
            scrollDirection: scrollDirection,
            viewportFraction: .9,
            enlargeFactor: .2,
            enableInfiniteScroll: true,
            initialPage: currentIndex,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) => onPageChanged(index),
          ),
        ),
        const SizedBox.square(
          dimension: 12,
        ),
        CircleAvatar(
          // Border
          radius: 26.5,
          backgroundColor: Colors.grey.shade600,
          child: CircleAvatar(
            radius: 25,
            backgroundColor: streets[currentIndex].found
                ? Colors.lightGreen.shade400
                : Theme.of(context).colorScheme.background,
            child: Text(
              '${currentIndex + 1}/${streets.length}',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
