import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../logging_service.dart';
import 'log_viewer_dialog.dart';

class LogViewerButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;

  const LogViewerButton({
    super.key,
    this.icon = Icons.list_alt,
    this.tooltip = 'View Logs',
  });

  void _showLogs(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: () => LogViewerDialog.show(context),
      tooltip: tooltip,
    );
  }
}
