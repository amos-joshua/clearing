import 'package:flutter/material.dart';

import '../utils/widgets/loading_handset_spinner.dart';

class SplashLoadingPage extends StatelessWidget {
  const SplashLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(body: Center(child: LoadingHandsetSpinner())),
    );
  }
}
