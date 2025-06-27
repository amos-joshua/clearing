import 'package:logger/logger.dart';

abstract class LoggingService {
  void debug(String message, [dynamic error, StackTrace? stackTrace]);
  void info(String message, [dynamic error, StackTrace? stackTrace]);
  void warning(String message, [dynamic error, StackTrace? stackTrace]);
  void error(String message, [dynamic error, StackTrace? stackTrace]);
}

class MockLoggingService implements LoggingService {
  final List<String> logs = [];

  @override
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    logs.add('DEBUG: $message');
  }

  @override
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    logs.add('INFO: $message');
  }

  @override
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    logs.add('WARNING: $message');
  }

  @override
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    logs.add('ERROR: $message');
  }
}

class LogManager implements LoggingService {
  late final Logger _logger;
  late final MemoryOutput _memoryOutput;

  LogManager() {
    _memoryOutput = MemoryOutput();
    _logger = Logger(
      printer: SimplePrinter(printTime: true),
      output: MultiOutput([ConsoleOutput(), _memoryOutput]),
    );
  }

  List<OutputEvent> get logs => List.unmodifiable(_memoryOutput.logs);

  @override
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  @override
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  @override
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  @override
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void clear() {
    _memoryOutput.clear();
  }
}

class MemoryOutput extends LogOutput {
  final List<OutputEvent> logs = [];

  MemoryOutput() {
    print("hey");
  }

  @override
  void output(OutputEvent event) {
    logs.add(event);
  }

  void clear() {
    logs.clear();
  }
}
