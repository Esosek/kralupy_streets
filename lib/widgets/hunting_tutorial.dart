import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:kralupy_streets/widgets/hunting_tutorial_page.dart';

class HuntingTutorial extends StatelessWidget {
  const HuntingTutorial({super.key, required this.onComplete});

  final void Function() onComplete;

  @override
  Widget build(BuildContext context) {
    return OnBoardingSlider(
      totalPage: 3,
      headerBackgroundColor: Theme.of(context).colorScheme.primary,
      finishButtonText: 'Jdu na to!',
      finishButtonTextStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
            color: Colors.white,
          ),
      controllerColor: Theme.of(context).colorScheme.primary,
      background: <Widget>[
        Container(),
        Container(),
        Container(),
      ],
      speed: 1.8,
      onFinish: onComplete,
      pageBodies: const [
        HuntingTutorialPage(
          title: 'Poznej!',
          body: 'Podívej se na obrázek a uhodni, o jakou ulici se jedná.',
          imagePath: 'assets/images/street_slider.png',
        ),
        HuntingTutorialPage(
          title: 'Vyfoť!',
          body:
              'Vydej se na místo a zachyť ulici na fotce tak, aby co nejpřesněji odpovídala obrázku.',
          imagePath: 'assets/images/female_taking_picture.png',
        ),
        HuntingTutorialPage(
          title: 'Ulov!',
          body:
              'Pokud tvůj snímek odpovídá, ulice se přidá do tvé sbírky. Jsi-li první, kdo ji objevil, zadej svou přezdívku a ukaž všem, že jsi to byl/a ty!',
          imagePath: 'assets/images/nickname_textfield.png',
        ),
      ],
    );
  }
}
