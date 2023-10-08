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
  bool _isCorrect = false;
  int? pickedAnswerIndex;

  @override
  void initState() {
    super.initState();
    quizGenerator = QuizGenerator(streets: widget.streets);
    questions = quizGenerator.generateQuestions();
  }

  void _submitAnswer(int streetId) {
    _isAnswered = true;
    pickedAnswerIndex = streetId;
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
      _isCorrect = false;
    });
  }

  Color highlightColor(int optionIndex) {
    if (_isAnswered) {
      if (optionIndex == questions[_currentQuestionIndex].correctAnswer.id) {
        return Colors.green;
      } else if (optionIndex == pickedAnswerIndex &&
          pickedAnswerIndex !=
              questions[_currentQuestionIndex].correctAnswer.id) {
        return Theme.of(context).colorScheme.primaryContainer;
      } else {
        return Colors.transparent;
      }
    }
    return Colors.transparent;
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
                      fit: BoxFit.cover,
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
                    right: 15,
                    bottom: 15,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      width: _isAnswered ? 60 : 0,
                      height: _isAnswered ? 60 : 0,
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: _isCorrect
                            ? Colors.green
                            : Theme.of(context).colorScheme.error,
                        child: Icon(
                          size: _isAnswered ? 35 : 0,
                          _isCorrect
                              ? Icons.check_rounded
                              : Icons.close_rounded,
                          color: Theme.of(context).colorScheme.onError,
                        ),
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
                            margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 7,
                                color: highlightColor(option.id),
                              ),
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
