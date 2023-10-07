import 'package:flutter/material.dart';
import 'package:kralupy_streets/models/question.dart';

import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/screens/results_screen.dart';
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
  final List<bool> answers = [];

  int _currentQuestionIndex = 0;
  bool _isAnswered = false;
  bool? _isCorrect;

  void _submitAnswer(int streetId) {
    _isAnswered = true;
    if (streetId == questions[_currentQuestionIndex].correctAnswer.id) {
      answers.add(true);
      setState(() {
        _isCorrect = true;
      });
    } else {
      answers.add(false);
      setState(() {
        _isCorrect = false;
      });
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex == questions.length - 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
              streets: widget.streets, questions: questions, answers: answers),
        ),
      );
      return;
    }

    setState(() {
      _currentQuestionIndex++;
      _isAnswered = false;
      _isCorrect = null;
    });
  }

  @override
  void initState() {
    super.initState();
    quizGenerator = QuizGenerator(streets: widget.streets);
    questions = quizGenerator.generateQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('${_currentQuestionIndex + 1} z ${questions.length}'),
        ),
        floatingActionButton: _isAnswered
            ? FloatingActionButton(
                onPressed: _nextQuestion,
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
                    height: 300,
                    width: double.infinity,
                    color: Colors.grey.shade400,
                    child: Image.network(
                      questions[_currentQuestionIndex].correctAnswer.imageUrl,
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
                  if (_isAnswered && _isCorrect != null)
                    Positioned(
                      right: 15,
                      bottom: 15,
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: _isCorrect!
                            ? Colors.green
                            : Theme.of(context).colorScheme.error,
                        child: Icon(
                          size: 35,
                          _isCorrect!
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
                child: FittedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (Street option
                          in questions[_currentQuestionIndex].options)
                        GestureDetector(
                          onTap: _isAnswered
                              ? null
                              : () => _submitAnswer(option.id),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 7,
                                  color: _isAnswered &&
                                          option.id ==
                                              questions[_currentQuestionIndex]
                                                  .correctAnswer
                                                  .id
                                      ? Colors.green
                                      : Colors.transparent),
                            ),
                            child: StreetSign(option),
                          ),
                        ),
                    ],
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
