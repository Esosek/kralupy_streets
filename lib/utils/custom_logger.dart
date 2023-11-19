import 'package:kralupy_streets/utils/custom_log_printer.dart';
import 'package:logger/logger.dart';

class CustomLogger {
  CustomLogger(this.className)
      : _logger = Logger(
          printer: CustomLogPrinter(className),
        );

  final Logger _logger;
  final String className;

  // Detailed logs
  void trace(String message) => _logger.log(Level.trace, message);
  // Temporary dev helper logs
  void debug(String message) => _logger.log(Level.debug, message);
  // Information about flow
  void info(String message) => _logger.log(Level.info, message);
  // This might break something not critical
  void warning(String message) => _logger.log(Level.warning, message);
  // Key feature is broken
  void error(String message) => _logger.log(Level.error, message);
}
