import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:snap_notes_mvvm/core/error/exceptions.dart';
import 'package:snap_notes_mvvm/features/notifikasi/models/preferensi_notifikasi.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service untuk notifikasi dan preferensi
class NotifikasiService {
  final Dio _dio;
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  final FlutterSecureStorage _storage;

  static const _cacheKey = 'preferensi_notifikasi_cache';

  NotifikasiService({
    required this._dio,
    required this._notificationsPlugin,
    required this._storage,
  });

  /// Simpan daftar preferensi ke cache local
  Future<void> cachePreferensiList(List<PreferensiNotifikasi> list) async {
    try {
      final jsonList = list.map((item) => item.toJson()).toList();
      await _storage.write(key: _cacheKey, value: json.encode(jsonList));
    } catch (_) {
      // Abaikan error caching agar tidak mengganggu flow utama
    }
  }

  /// Ambil daftar preferensi dari cache local
  Future<List<PreferensiNotifikasi>> getCachedPreferensiList() async {
    try {
      final jsonStr = await _storage.read(key: _cacheKey);
      if (jsonStr == null || jsonStr.isEmpty) {
        return [];
      }
      final decoded = json.decode(jsonStr) as List;
      return decoded
          .map((item) => PreferensiNotifikasi.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Init local notifications
  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_stat_logo');

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
      final list = data.map((json) => PreferensiNotifikasi.fromJson(json)).toList();
      await cachePreferensiList(list);
      return list;
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
        data: preferensi.toRequestPayload(),
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
        data: preferensi.toRequestPayload(),
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

  /// Membatalkan semua pengiriman notifikasi
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
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
      icon: 'ic_stat_logo',
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

  /// Method trigger notifikasi dari schedule / background
  Future<void> onScheduledTimeReached(int notifikasiId) async {
    // Digunakan sebagai penanda saat background worker terpanggil (jika menggunakan workmanager/cron)
    // Di aplikasi ini, zonedSchedule dari flutter_local_notifications sudah handle secara native.
    // Metode ini merupakan representasi konseptual dari desain SKPL-F-021.
    final hasCatatan = await checkCatatanHariIni();
    if (!hasCatatan) {
      await showLocalNotification(
        id: notifikasiId,
        title: 'Waktunya Catat Keuangan!',
        body: 'Yuk catat pengeluaran atau pemasukan kamu hari ini agar keuangan tetap sehat.',
      );
    } else {
      await batalkanPengiriman(notifikasiId);
    }
  }

  /// Mengecek apakah ada catatan pemasukan/pengeluaran hari ini
  Future<bool> checkCatatanHariIni() async {
    try {
      final now = DateTime.now();
      // Contoh pemanggilan dummy ke API, diimplementasikan riil jika dibutuhkan endpoint khusus
      // Untuk implementasi MVVM yang bersih, endpoint khusus seperti /api/dashboard/status-hari-ini lebih ideal
      final response = await _dio.get('/api/dashboard/status-hari-ini', queryParameters: {
        'tanggal': now.toIso8601String(),
      });
      if (response.statusCode == 200) {
        return response.data['data']['hasCatatan'] as bool;
      }
      return false;
    } catch (e) {
      // Fallback: anggap belum ada catatan agar notifikasi tetap terkirim sebagai pengingat
      return false;
    }
  }

  /// Menampilkan notifikasi lokal
  Future<void> showLocalNotification({required int id, required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminder',
      channelDescription: 'Notifikasi pengingat pencatatan keuangan harian',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_stat_logo',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  /// Membatalkan pengiriman (tidak jadi mengirim / cancel spesifik ID)
  Future<void> batalkanPengiriman(int id) async {
    await _notificationsPlugin.cancel(id);
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
