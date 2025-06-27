import 'package:flutter/material.dart';

import '../features/auth/widgets/logout_button.dart';
import '../services/logging/widgets/log_viewer_button.dart';
import 'diagnostic/call_page.dart';

class RootPage extends StatelessWidget {
  final bool diagnosticCallWithoutContacts;

  const RootPage({
    super.key,
    required this.title,
    this.diagnosticCallWithoutContacts = false,
  });
  final String title;

  @override
  Widget build(BuildContext context) {
    final page = switch (diagnosticCallWithoutContacts) {
      true => const DiagnosticCallPage(),
      false => throw UnimplementedError(), //const CallPage(title: 'Call Demo'),
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        actions: const [LogViewerButton(), LogoutButton()],
      ),
      body: page,
    );
  }
}
