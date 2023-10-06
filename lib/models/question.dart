import 'package:kralupy_streets/models/street.dart';

class Question {
  const Question({
    required this.options,
    required this.correctAnswer,
  });

  final List<Street> options;
  final Street correctAnswer;
}
