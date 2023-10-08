import 'package:flutter/material.dart';

import 'package:kralupy_streets/models/question.dart';
import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/screens/game_screen.dart';
import 'package:kralupy_streets/screens/street_detail_screen.dart';
import 'package:kralupy_streets/widgets/street_sign.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen(
      {super.key,
      required this.streets,
      required this.questions,
      required this.answers});

  final List<Street> streets;
  final List<Question> questions;
  final List<bool> answers;

  int get correctAnswersCount {
    return answers.where((answer) => answer == true).toList().length;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Výsledek'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.shade700,
                radius: 30,
                child: Text(
                  '$correctAnswersCount',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => StreetDetailScreen(
                                questions[index].correctAnswer),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            StreetSign(
                              questions[index].correctAnswer,
                              size: 130,
                            ),
                            SizedBox(
                              width: 60,
                              child: Text(
                                answers[index] ? 'Správně' : 'Špatně',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        color: answers[index]
                                            ? Colors.green.shade700
                                            : Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          width: 2,
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 6),
                      child: Text(
                        'Zpět',
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                      ),
                    ),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => GameScreen(streets: streets),
                        ),
                      );
                    },
                    child: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
