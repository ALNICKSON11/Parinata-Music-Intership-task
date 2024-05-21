import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  // Initialize time zone data
  tz.initializeTimeZones();
  runApp(const InternshipTask());
}

class InternshipTask extends StatelessWidget {
  const InternshipTask({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Reminder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.blue, // Dark blue
          secondary: Colors.blue[300], // Light blue
        ),
        scaffoldBackgroundColor: Colors.blue[50], // Light background color
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue, // Dark blue
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.blue, // Dark blue
          textTheme: ButtonTextTheme.primary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Dark blue
            foregroundColor: Colors.white, // Text color
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.blue),
          bodyMedium: TextStyle(color: Colors.blue),
        ),
        dropdownMenuTheme: const DropdownMenuThemeData(
          textStyle: TextStyle(color: Colors.blue), // Dark text color
        ),
      ),
      home: ReminderPage(),
    );
  }
}

class ReminderPage extends StatefulWidget {
  @override
  ReminderPageState createState() => ReminderPageState();
}

class ReminderPageState extends State<ReminderPage> {
  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  final List<String> activities = [
    'Wake up',
    'Go to gym',
    'Breakfast',
    'Meetings',
    'Lunch',
    'Quick nap',
    'Go to library',
    'Dinner',
    'Go to sleep'
  ];
  String? selectedDay;
  String? selectedActivity;
  DateTime selectedTime = DateTime.now();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    
    _createNotificationChannel();
  }

  void _createNotificationChannel() {
    var androidNotificationChannel = const AndroidNotificationChannel(
      'reminder_channel_id', // id
      'Reminder Notifications', // name
      description: 'Channel for Reminder notifications', // description
      importance: Importance.high,
    );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  Future<void> scheduleNotification() async {
    var scheduledNotificationDateTime = tz.TZDateTime.from(
      DateTime(
        selectedTime.year,
        selectedTime.month,
        selectedTime.day,
        selectedTime.hour,
        selectedTime.minute,
      ),
      tz.local,
    );
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'reminder_channel_id',  // channelId
      'Reminder Notifications',  // channelName
      channelDescription: 'Channel for Reminder notifications',  // channelDescription
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound('chime'),
    );
    var iOSPlatformChannelSpecifics = const IOSNotificationDetails(
      sound: 'chime.aiff',
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Reminder',
      '$selectedActivity time!',
      scheduledNotificationDateTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Reminder',
        style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: const Text('Select Day'),
              value: selectedDay,
              onChanged: (String? newValue) {
                setState(() {
                  selectedDay = newValue;
                });
              },
              items: daysOfWeek.map<DropdownMenuItem<String>>((String day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TimePickerSpinner(
              is24HourMode: false,
              normalTextStyle: const TextStyle(fontSize: 24, color: Colors.black54),
              highlightedTextStyle: const TextStyle(fontSize: 24, color: Colors.black),
              spacing: 50,
              itemHeight: 60,
              isForce2Digits: true,
              onTimeChange: (time) {
                setState(() {
                  selectedTime = time;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              hint: const Text('Select Activity'),
              value: selectedActivity,
              onChanged: (String? newValue) {
                setState(() {
                  selectedActivity = newValue;
                });
              },
              items: activities.map<DropdownMenuItem<String>>((String activity) {
                return DropdownMenuItem<String>(
                  value: activity,
                  child: Text(activity),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (selectedDay != null && selectedActivity != null) {
                  scheduleNotification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reminder set for $selectedActivity on $selectedDay at ${DateFormat('hh:mm a').format(selectedTime)}')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select day, time and activity')),
                  );
                }
              },
              child: const Text('Set Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}





