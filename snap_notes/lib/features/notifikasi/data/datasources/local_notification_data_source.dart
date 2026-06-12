import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/preferensi_notifikasi_model.dart';

abstract class LocalNotificationDataSource {
  Future<void> init();
  Future<void> scheduleNotifications(List<PreferensiNotifikasiModel> preferensiList);
  Future<void> cancelAllNotifications();
}

class LocalNotificationDataSourceImpl implements LocalNotificationDataSource {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  LocalNotificationDataSourceImpl({required this.flutterLocalNotificationsPlugin});

  @override
  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  @override
  Future<void> scheduleNotifications(List<PreferensiNotifikasiModel> preferensiList) async {
    await cancelAllNotifications();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminder',
      channelDescription: 'Notifikasi pengingat pencatatan keuangan harian',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    int idCounter = 0;
    
    for (var preferensi in preferensiList) {
      if (!preferensi.aktif || preferensi.hariAktif.isEmpty) {
        continue;
      }

      final parts = preferensi.jamNotifikasi.split(':');
      if (parts.length != 2) continue;

      final int hour = int.tryParse(parts[0]) ?? 19;
      final int minute = int.tryParse(parts[1]) ?? 0;

      for (String dayString in preferensi.hariAktif) {
        final int day = int.tryParse(dayString) ?? 1;
        
        await flutterLocalNotificationsPlugin.zonedSchedule(
          idCounter++,
          'Waktunya Catat Keuangan!',
          'Yuk catat pengeluaran atau pemasukan kamu hari ini agar keuangan tetap sehat.',
          _nextInstanceOfDayAndTime(day, hour, minute),
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  @override
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfDayAndTime(int day, int hour, int minute) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
