import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 通知封装
/// author Shendi
class NotificationHelper {
  // 使用单例模式进行初始化
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  // FlutterLocalNotificationsPlugin是一个用于处理本地通知的插件，它提供了在Flutter应用程序中发送和接收本地通知的功能。
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // 初始化函数
  Future<void> initialize() async {
    // AndroidInitializationSettings是一个用于设置Android上的本地通知初始化的类
    // 使用了app_icon作为参数，这意味着在Android上，应用程序的图标将被用作本地通知的图标。
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    // 15.1是DarwinInitializationSettings，旧版本好像是IOSInitializationSettings（有些例子中就是这个）
    // const DarwinInitializationSettings initializationSettingsIOS =
    // DarwinInitializationSettings();
    // 初始化
    const InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid);
    // iOS: initializationSettingsIOS);
    await _notificationsPlugin.initialize(initializationSettings);
  }

//  显示通知
  Future<void> showNotification(
      {required String title, required String body}) async {
    // 安卓的通知
    // 'your channel id'：用于指定通知通道的ID。
    // 'your channel name'：用于指定通知通道的名称。
    // 'your channel description'：用于指定通知通道的描述。
    // Importance.max：用于指定通知的重要性，设置为最高级别。
    // Priority.high：用于指定通知的优先级，设置为高优先级。
    // 'ticker'：用于指定通知的提示文本，即通知出现在通知中心的文本内容。
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('your.channel.id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');

    // ios的通知
    // const String darwinNotificationCategoryPlain = 'plainCategory';
    // const DarwinNotificationDetails iosNotificationDetails =
    // DarwinNotificationDetails(
    //   categoryIdentifier: darwinNotificationCategoryPlain, // 通知分类
    // );
    // 创建跨平台通知
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidNotificationDetails);

    // 发起一个通知
    await _notificationsPlugin.show(
      1,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}

// void main() => runApp(MyApp());
void main() async {
  //用于确保Flutter的Widgets绑定已经初始化。
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化通知帮助类
  NotificationHelper notificationHelper = NotificationHelper();
  await notificationHelper.initialize();
  runApp(MyApp());
}

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

    // _timer = Timer.periodic(Duration(milliseconds: 100), (Timer t) {
    //   setState(() {
    //     final now = DateTime.now();
    //     if (_autoVibrateAtHour && (now.minute % 15 == 0) && now.second == 0 && now.millisecond < 100) {
    //       if (Vibration.hasVibrator() != null) {
    //         Vibration.vibrate(duration: _vibrationDuration);
    //         NotificationHelper._instance.showNotification(
    //           title: 'Hello',
    //           body: 'ming!',
    //         );
    //
    //       }
    //     }
    //   });
    // });

    bool _hasTriggered = false;

    _timer = Timer.periodic(Duration(milliseconds: 100), (Timer t) {
      setState(() {
        final now = DateTime.now();
        if (_autoVibrateAtHour && (now.minute % 15 == 0) && now.second == 0) {
          if (!_hasTriggered) {
            if (Vibration.hasVibrator() != null) {
              Vibration.vibrate(duration: _vibrationDuration);
              NotificationHelper._instance.showNotification(
                title: 'Hello',
                body: 'ming!',
              );
              _hasTriggered = true;
            }
          }
        } else {
          _hasTriggered = false;
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
