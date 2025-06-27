import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../logging_service.dart';

class LogViewerDialog extends StatelessWidget {
  final List<OutputEvent> logs;

  const LogViewerDialog({super.key, required this.logs});

  String _stripAnsiColors(String text) {
    // Remove ANSI color codes
    return text.replaceAll(RegExp(r'\x1B\[[0-9;]*[a-zA-Z]'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Application Logs',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return ListTile(
                    title: Text(
                      log.lines.map(_stripAnsiColors).join('\n'),
                      style: TextStyle(color: _getColorForLevel(log.level)),
                    ),
                    leading: Icon(
                      _getIconForLevel(log.level),
                      color: _getColorForLevel(log.level),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForLevel(Level level) {
    switch (level) {
      case Level.debug:
        return Icons.bug_report;
      case Level.info:
        return Icons.info;
      case Level.warning:
        return Icons.warning;
      case Level.error:
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  Color _getColorForLevel(Level level) {
    switch (level) {
      case Level.debug:
        return Colors.blue;
      case Level.info:
        return Colors.green;
      case Level.warning:
        return Colors.orange;
      case Level.error:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static void show(BuildContext context) {
    final logger = context.read<LoggingService>();
    final logs = switch (logger) {
      LogManager logManager => logManager.logs,
      _ => <OutputEvent>[],
    };
    showDialog(
      context: context,
      builder: (context) => LogViewerDialog(logs: logs),
    );
  }
}
