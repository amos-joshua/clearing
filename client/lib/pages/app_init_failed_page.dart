import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/logging/logging_service.dart';
import '../services/logging/widgets/log_viewer_button.dart';

class AppInitFailedPage extends StatelessWidget {
  final LoggingService logger;
  const AppInitFailedPage({super.key, required this.logger});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: logger,
      child: const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [Text("App initialization failed"), LogViewerButton()],
            ),
          ),
        ),
      ),
    );
  }
}
