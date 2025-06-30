import 'package:flutter/material.dart';
import 'dart:math' as math;

class LoadingHandsetSpinner extends StatefulWidget {
  const LoadingHandsetSpinner({super.key});

  @override
  State<LoadingHandsetSpinner> createState() => _LoadingHandsetSpinnerState();
}

class _LoadingHandsetSpinnerState extends State<LoadingHandsetSpinner>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Create a custom curved animation that varies speed
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Start the animation and make it repeat
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            child: Image.asset(
              'assets/images/handset-80x40.png',
              width: 80,
              height: 40,
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}
