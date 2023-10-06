import 'package:kralupy_streets/models/street.dart';

class Question {
  const Question({
    required this.options,
    required this.correctAnwser,
  });

  final List<Street> options;
  final Street correctAnwser;
}
