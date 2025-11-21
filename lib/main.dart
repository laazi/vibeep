
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Beeper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StopwatchScreen(),
    );
  }
}

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _topTimerDisplay = '00:00:00';
  String _bottomTimerDisplay = '00:00:00';
  int _buttonPressCount = 0;
  DateTime? _lastPressTime;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final elapsed = _stopwatch.elapsed;
      setState(() {
        _topTimerDisplay = _formatTime(elapsed);
      });

      if (_lastPressTime != null) {
        final difference = DateTime.now().difference(_lastPressTime!);
        if (difference.inSeconds >= 90) {
          _beep();
          _lastPressTime = null; // Prevent beeping again until next press
        }
      }
    });
  }

  String _formatTime(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void _handleButtonPress() {
    setState(() {
      _buttonPressCount++;
      if (!_stopwatch.isRunning) {
        _stopwatch.start();
        _startTimer();
      }
      _lastPressTime = DateTime.now();
      final targetTime = _stopwatch.elapsed + const Duration(seconds: 90);
      _bottomTimerDisplay = _formatTime(targetTime);
    });
  }

  Future<void> _beep() async {
    for (int i = 0; i < 10; i++) {
      await _audioPlayer.play(AssetSource('audio/beep.mp3'));
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Beeper'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTimerDisplay(_topTimerDisplay),
          _buildTimerDisplay(_bottomTimerDisplay),
          Text(
            '$_buttonPressCount',
            style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleButtonPress,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 48),
                textStyle: const TextStyle(fontSize: 24),
              ),
              child: const Text('TERAZ'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(String time) {
    return Text(
      time,
      style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
    );
  }
}
