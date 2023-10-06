import 'dart:math';

import 'package:kralupy_streets/models/question.dart';
import 'package:kralupy_streets/models/street.dart';

final random = Random();

class QuizGenerator {
  const QuizGenerator({required this.streets, this.questionsCount = 5});

  final List<Street> streets;
  final int questionsCount;

  List<Question> generateQuestions() {
    final List<Street> streetsCopy = List.of(streets);
    final List<Question> questions = [];

    for (var i = 0; i < questionsCount; i++) {
      final List<Street> options = [];

      final randomStreetId = random.nextInt(streetsCopy.length);
      final pickedStreet = streetsCopy[randomStreetId];

      options.add(pickedStreet);

      // Remove it to avoid duplicate street questions
      streetsCopy.remove(pickedStreet);

      // Avoid duplicate options
      final secondOption = _generateOption(usedIds: [pickedStreet.id]);
      options.add(secondOption);
      options.add(_generateOption(usedIds: [pickedStreet.id, secondOption.id]));

      options.shuffle();

      questions.add(Question(options: options, correctAnswer: pickedStreet));
    }
    //_logQuestions(questions);
    return questions;
  }

  Street _generateOption({required List<int> usedIds}) {
    final availableStreets =
        streets.where((street) => !usedIds.contains(street.id)).toList();

    final randomStreetId = random.nextInt(availableStreets.length);
    return availableStreets[randomStreetId];
  }

  // void _logQuestions(List<Question> questions) {
  //   for (var question in questions) {
  //     final List<String> streetNames = [];
  //     for (var street in question.options) {
  //       streetNames.add(street.name);
  //     }
  //     print(streetNames);
  //     print(question.correctAnswer.name);
  //     print('___');
  //   }
  // }
}
