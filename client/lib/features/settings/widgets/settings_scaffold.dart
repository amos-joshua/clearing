import 'package:flutter/material.dart';

class SettingsScaffold extends StatelessWidget {
  final Widget body;
  final String title;

  const SettingsScaffold({required this.body, required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: body,
    );
  }
}
