import 'package:flutter/material.dart';
import 'package:kralupy_streets/data/dummy_streets.dart';
import 'package:kralupy_streets/widgets/street_sign.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _currentQuestion = 1;
  bool isAnswered = false;
  bool? isCorrect;

  @override
  Widget build(BuildContext context) {
    isAnswered = true;
    isCorrect = false;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('$_currentQuestion z 5'),
        ),
        floatingActionButton: isAnswered
            ? FloatingActionButton(
                onPressed: () {},
                child: const Icon(
                  Icons.navigate_next_rounded,
                  size: 35,
                ),
              )
            : null,
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Stack(
                children: [
                  Image.network(
                      'https://firebasestorage.googleapis.com/v0/b/kralupy-streets.appspot.com/o/street_images%2Fnadrazni.jpg?alt=media&token=ca0e68e5-1531-44f4-a8fd-06aca30d159d&_gl=1*1aji2yr*_ga*ODgyMzc0OTUuMTY4NDkzNjkzNQ..*_ga_CW55HF8NVT*MTY5NjU5NTIxOS4zOS4xLjE2OTY1OTYyMDYuNTguMC4w'),
                  if (isAnswered && isCorrect != null)
                    Positioned(
                      right: 15,
                      bottom: 15,
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: isCorrect!
                            ? Colors.green
                            : Theme.of(context).colorScheme.error,
                        child: Icon(
                          size: 35,
                          isCorrect!
                              ? Icons.check_rounded
                              : Icons.close_rounded,
                          color: Theme.of(context).colorScheme.onError,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    StreetSign(dummyStreet[0]),
                    StreetSign(dummyStreet[1]),
                    StreetSign(dummyStreet[2]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
