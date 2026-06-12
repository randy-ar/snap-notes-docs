import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:snap_notes_mvvm/core/error/exceptions.dart';
import 'package:snap_notes_mvvm/features/notifikasi/models/preferensi_notifikasi.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service untuk notifikasi dan preferensi
class NotifikasiService {
  final Dio _dio;
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  NotifikasiService({
    required this._dio,
    required this._notificationsPlugin,
  });

  /// Init local notifications
  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);

    // Request notification permission (Android 13+)
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Request exact alarm permission (Android 12+)
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final canScheduleExact = await androidPlugin.canScheduleExactNotifications() ?? false;
      if (!canScheduleExact) {
        await androidPlugin.requestExactAlarmsPermission();
      }
    }
  }

  /// Get daftar preferensi notifikasi
  Future<List<PreferensiNotifikasi>> getPreferensiList() async {
    try {
      final response = await _dio.get('/api/notifikasi/preferensi');
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'] as List;
      return data.map((json) => PreferensiNotifikasi.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Terjadi kesalahan server');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Tambah preferensi notifikasi
  Future<PreferensiNotifikasi> createPreferensi(PreferensiNotifikasi preferensi) async {
    try {
      final response = await _dio.post(
        '/api/notifikasi/preferensi',
        data: preferensi.toJson(),
      );
      final envelope = response.data as Map<String, dynamic>;
      return PreferensiNotifikasi.fromJson(envelope['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Terjadi kesalahan server');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Update preferensi notifikasi
  Future<PreferensiNotifikasi> updatePreferensi(String id, PreferensiNotifikasi preferensi) async {
    try {
      final response = await _dio.patch(
        '/api/notifikasi/preferensi/$id',
        data: preferensi.toJson(),
      );
      final envelope = response.data as Map<String, dynamic>;
      return PreferensiNotifikasi.fromJson(envelope['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Terjadi kesalahan server');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Hapus preferensi notifikasi
  Future<void> deletePreferensi(String id) async {
    try {
      await _dio.delete('/api/notifikasi/preferensi/$id');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Terjadi kesalahan server');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Schedule notifications
  Future<void> scheduleNotifications(List<PreferensiNotifikasi> preferensiList) async {
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

        await _notificationsPlugin.zonedSchedule(
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

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
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
