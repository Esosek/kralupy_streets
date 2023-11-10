import 'package:logger/logger.dart';

class CustomLogPrinter extends LogPrinter {
  CustomLogPrinter(this.className);

  final String className;

  final _prettyPrinter = PrettyPrinter(
      errorMethodCount: 3,
      methodCount: 0,
      lineLength: 50,
      levelColors: PrettyPrinter.defaultLevelColors,
      levelEmojis: {
        ...PrettyPrinter.defaultLevelEmojis,
        Level.trace: '',
        Level.debug: '🌱',
        Level.info: '🔹',
        Level.warning: '🔸',
        Level.error: '🔥',
      });

  @override
  List<String> log(LogEvent event) {
    var color = _prettyPrinter.levelColors![event.level];
    var emoji = _prettyPrinter.levelEmojis![event.level];
    return [(color!('$emoji $className: ${event.message}'))];
  }
}
