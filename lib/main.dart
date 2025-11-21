
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'settings_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const MaterialColor primarySeedColor = Colors.deepPurple;

    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.oswald(
          fontSize: 72, fontWeight: FontWeight.bold, letterSpacing: 2),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14),
      labelLarge: GoogleFonts.roboto(
          fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5),
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle:
            GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle:
              GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        titleTextStyle:
            GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: primarySeedColor.shade200,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle:
              GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Time Beeper',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: const StopwatchScreen(),
        );
      },
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
  double _beepPeriodInSeconds = 90.0;

  final AudioPlayer _audioPlayer = AudioPlayer();

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final elapsed = _stopwatch.elapsed;
      setState(() {
        _topTimerDisplay = _formatTime(elapsed);
      });

      if (_lastPressTime != null) {
        final difference = DateTime.now().difference(_lastPressTime!);
        if (difference.inSeconds >= _beepPeriodInSeconds) {
          _beep();
          _lastPressTime = null; 
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
      final targetTime =
          _stopwatch.elapsed + Duration(seconds: _beepPeriodInSeconds.toInt());
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

  void _navigateToSettings() async {
    final newPeriod = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SettingsScreen(initialPeriod: _beepPeriodInSeconds),
      ),
    );

    if (newPeriod != null && newPeriod is double) {
      setState(() {
        _beepPeriodInSeconds = newPeriod;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Beeper'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTimerDisplay(_topTimerDisplay),
          _buildTimerDisplay(_bottomTimerDisplay),
          Text(
            '$_buttonPressCount',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleButtonPress,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 48),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text(
                'TERAZ',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(String time) {
    return Text(
      time,
      style: Theme.of(context).textTheme.displayLarge,
    );
  }
}
