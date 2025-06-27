import 'package:flutter/material.dart';

class IdleCallWidget extends StatelessWidget {
  const IdleCallWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Waiting for incoming call...',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
} 