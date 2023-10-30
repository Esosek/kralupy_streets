import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kralupy_streets/models/question.dart';
import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/providers/street_provider.dart';
import 'package:kralupy_streets/screens/results_screen.dart';
import 'package:kralupy_streets/utils/quiz_generator.dart';
import 'package:kralupy_streets/widgets/street_image.dart';
import 'package:kralupy_streets/widgets/street_sign.dart';

final analytics = FirebaseAnalytics.instance;

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late List<Street> streets;
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
    streets = ref.read(streetProvider);
    quizGenerator = QuizGenerator(streets: streets, questionsCount: 10);
    questions = quizGenerator.generateQuestions();
  }

  void _submitAnswer(Street pickedStreet) {
    _isAnswered = true;
    pickedAnswerIndex = pickedStreet.id;
    final correctAnswer = questions[_currentQuestionIndex].correctAnswer;
    if (pickedAnswerIndex == correctAnswer.id) {
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
    analytics.logEvent(
      name: 'street_answered',
      parameters: {
        'correct_street_name': correctAnswer.name,
        'chosen_street_name': pickedStreet.name,
        'value': pickedAnswerIndex == correctAnswer.id ? 1 : 0,
      },
    );
  }

  void _nextQuestion() async {
    if (_currentQuestionIndex == questions.length - 1) {
      int correctAnswerCount = answers.where((answer) => answer == true).length;
      await analytics.logEvent(
        name: 'quiz_completed',
        parameters: {
          'correct_answer_count': correctAnswerCount,
        },
      );
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                ResultsScreen(questions: questions, answers: answers),
          ),
        );
        return;
      }
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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          return await (showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Opravdu chcete kvíz ukončit?'),
                  content:
                      const Text('Všechny zodpovězené otázky budou ztraceny.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Ne'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Ano'),
                    ),
                  ],
                ),
              )) ??
              false;
        },
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
            child: Flex(
              direction: isLandscape ? Axis.horizontal : Axis.vertical,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: Colors.grey.shade300,
                        child: StreetImage(
                          questions[_currentQuestionIndex].correctAnswer,
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
                                : () => _submitAnswer(option),
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
      ),
    );
  }
}
