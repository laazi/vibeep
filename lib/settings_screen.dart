
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final double initialPeriod;

  const SettingsScreen({super.key, required this.initialPeriod});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _controller;
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialPeriod;
    _controller = TextEditingController(text: _currentValue.toStringAsFixed(0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Beep Period (seconds)',
              ),
              onChanged: (value) {
                final newPeriod = double.tryParse(value);
                if (newPeriod != null && newPeriod >= 20 && newPeriod <= 300) {
                  setState(() {
                    _currentValue = newPeriod;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            Slider(
              value: _currentValue,
              min: 20,
              max: 300,
              divisions: 280,
              label: _currentValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentValue = value;
                  _controller.text = value.toStringAsFixed(0);
                });
              },
            ),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('20s'),
                Text('300s'),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _currentValue);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
