import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_interview/user.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import 'package:timezone/data/latest_all.dart' as ltz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  ltz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
  Hive.registerAdapter(UserAdapter());
  final document = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(document.path);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var scheduledTime;
  // FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  static final FlutterLocalNotificationsPlugin
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  Dio dio = Dio();

  Future callApi() async {
    String url = "https://www.jsonkeeper.com/b/3J3S";
    try {
      final response = await dio.get(url);
      final box = await Hive.openBox<List<User>>('userBox');
      List<User> getData = [];
      getData.addAll(List<User>.from(
          json.decode(response.data).map((x) => User.fromJson(x))));
      box.put('userBox', getData);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future fetchResultIsolates() async {
    await compute((message) => callApi, "");
  }

  @override
  void initState() {
    initLocalNotification();
    callApi();

    super.initState();
  }

  Future initLocalNotification() async {
    const ios = DarwinInitializationSettings();
    var androidInitilize =
        const AndroidInitializationSettings('@drawable/ic_launcher');
    var iOSinitilize = const DarwinInitializationSettings();
    var initilizationsSettings =
        InitializationSettings(android: androidInitilize, iOS: iOSinitilize);
    await flutterLocalNotificationsPlugin.initialize(initilizationsSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  ShowNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin!.show(
        0, 'plain title', 'plain body', notificationDetails,
        payload: 'item x');
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
    await Navigator.push(
        context, MaterialPageRoute<void>(builder: (context) => const MyApp()));
  }

 
 

  notificationShedule(DateTime time) async {
    tz.TZDateTime scheduledTime= tz.TZDateTime.from(time, tz.local);
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Alarm',
        'Alarm name',
        // tz.TZDateTime.from(time, tz.local),
        scheduledTime,
        const NotificationDetails(
            android: AndroidNotificationDetails('Alarm_sch', 'Alarm sch name',
                channelDescription:
                    'Flutter local notification package example',
                importance: Importance.max,
                priority: Priority.high,
                ticker: 'ticker')),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Set time for alarm:',
            ),
            ElevatedButton(
                onPressed: () async {
                   
                  
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    // Create a DateTime object from the picked time
                    final now = DateTime.now();
                    scheduledTime = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );

                  notificationShedule(scheduledTime);

                  }
                },
                child: const Text("Set Alarm"))
          ],
        ),
      ),
    );
  }
}
