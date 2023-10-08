import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';
import 'package:vibration/vibration.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibration Control Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Timer _timer;
  bool _isVibrating = false;
  bool _autoVibrateAtHour = true;
  int _vibrationDuration = 5000; // 默认5秒
  TextEditingController _durationController = TextEditingController(text: "5000");

  @override
  void initState() {
    super.initState();

    Wakelock.enable();

    _timer = Timer.periodic(Duration(milliseconds: 100), (Timer t) {
      setState(() {
        final now = DateTime.now();
        if (_autoVibrateAtHour && (now.minute == 0 || now.minute == 30) && now.second == 0 && now.millisecond < 100) {
          if (Vibration.hasVibrator() != null) {
            Vibration.vibrate(duration: _vibrationDuration);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final milliseconds = (now.millisecond / 100).floor();
    final timeString = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.$milliseconds";

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(timeString, style: TextStyle(fontSize: 40)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_isVibrating) {
                  Vibration.cancel();
                } else {
                  Vibration.vibrate(duration: _vibrationDuration);
                }
                setState(() {
                  _isVibrating = !_isVibrating;
                });
              },
              child: Text(_isVibrating ? '停止震动' : '开始震动'),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('整点或半点震动'),
                Switch(
                  value: _autoVibrateAtHour,
                  onChanged: (value) {
                    setState(() {
                      _autoVibrateAtHour = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '震动时长 (毫秒)',
                suffixIcon: IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    final duration = int.tryParse(_durationController.text);
                    if (duration != null) {
                      setState(() {
                        _vibrationDuration = duration;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
