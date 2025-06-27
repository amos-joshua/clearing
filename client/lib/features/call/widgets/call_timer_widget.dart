import 'package:flutter/material.dart';

class CallTimerWidget extends StatefulWidget {
  final DateTime startedAt;

  const CallTimerWidget({super.key, required this.startedAt});

  @override
  State<CallTimerWidget> createState() => _CallTimerWidgetState();
}

class _CallTimerWidgetState extends State<CallTimerWidget> {
  late String _timerText;
  late DateTime _lastUpdate;

  @override
  void initState() {
    super.initState();
    _lastUpdate = DateTime.now();
    _updateTimer();
  }

  void _updateTimer() {
    final now = DateTime.now();
    final difference = now.difference(widget.startedAt);
    final minutes = difference.inMinutes;
    final seconds = difference.inSeconds % 60;
    _timerText =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    _lastUpdate = now;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        _updateTimer();
        return Text(
          _timerText,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}
