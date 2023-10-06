import 'package:flutter/material.dart';
import 'package:kralupy_streets/models/question.dart';

import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/utils/quiz_generator.dart';
import 'package:kralupy_streets/widgets/street_sign.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.streets});

  final List<Street> streets;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late QuizGenerator quizGenerator;
  late List<Question> questions;

  int _currentQuestion = 0;
  bool isAnswered = false;
  bool? isCorrect;

  @override
  void initState() {
    super.initState();
    quizGenerator = QuizGenerator(streets: widget.streets);
    questions = quizGenerator.generateQuestions();
  }

  @override
  Widget build(BuildContext context) {
    isAnswered = true;
    isCorrect = false;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('${_currentQuestion + 1} z ${questions.length}'),
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
                  Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey.shade400,
                    child: Image.network(
                      questions[_currentQuestion].correctAnswer.imageUrl,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      fit: BoxFit.cover,
                    ),
                  ),
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
                    for (Street option in questions[_currentQuestion].options)
                      StreetSign(option),
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
