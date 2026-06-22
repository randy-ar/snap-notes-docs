import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snap_notes_mvvm/core/network/dio_client.dart';
import 'package:snap_notes_mvvm/features/auth/models/auth_service.dart';
import 'package:snap_notes_mvvm/features/pemasukan/models/pemasukan_service.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/models/pengeluaran_service.dart';
import 'package:snap_notes_mvvm/features/receipt/models/receipt_service.dart';
import 'package:snap_notes_mvvm/features/dashboard/models/dashboard_service.dart';
import 'package:snap_notes_mvvm/features/notifikasi/models/notifikasi_service.dart';
import 'package:snap_notes_mvvm/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:snap_notes_mvvm/features/auth/viewmodels/login_viewmodel.dart';
import 'package:snap_notes_mvvm/features/auth/viewmodels/register_viewmodel.dart';
import 'package:snap_notes_mvvm/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:snap_notes_mvvm/features/pemasukan/viewmodels/pemasukan_viewmodel.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/viewmodels/pengeluaran_viewmodel.dart';
import 'package:snap_notes_mvvm/features/receipt/viewmodels/receipt_viewmodel.dart';
import 'package:snap_notes_mvvm/features/notifikasi/viewmodels/notifikasi_viewmodel.dart';

final GetIt getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Inisialisasi lokalisasi tanggal Indonesia
  await initializeDateFormatting('id_ID', null);

  // External dependencies
  await dotenv.load(fileName: '.env');

  final supabase = await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  getIt.registerSingleton<SupabaseClient>(supabase.client);

  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);

  // Dio Client
  final dioClient = DioClient(storage: secureStorage);
  getIt.registerSingleton<Dio>(dioClient.dio);

  // Local Notifications
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  getIt.registerSingleton<FlutterLocalNotificationsPlugin>(flutterLocalNotificationsPlugin);

  // Services
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(
      dio: getIt(),
      storage: getIt(),
      supabaseClient: getIt(),
    ),
  );

  getIt.registerLazySingleton<PemasukanService>(
    () => PemasukanService(dio: getIt()),
  );

  getIt.registerLazySingleton<PengeluaranService>(
    () => PengeluaranService(dio: getIt()),
  );

  getIt.registerLazySingleton<ReceiptService>(
    () => ReceiptService(dio: getIt()),
  );

  getIt.registerLazySingleton<DashboardService>(
    () => DashboardService(dio: getIt()),
  );

  getIt.registerLazySingleton<NotifikasiService>(
    () => NotifikasiService(
      dio: getIt(),
      notificationsPlugin: getIt(),
    ),
  );

  // ViewModels
  getIt.registerFactory<AuthViewModel>(
    () => AuthViewModel(authService: getIt()),
  );

  getIt.registerFactory<LoginViewModel>(
    () => LoginViewModel(authService: getIt()),
  );

  getIt.registerFactory<RegisterViewModel>(
    () => RegisterViewModel(authService: getIt()),
  );

  getIt.registerFactory<DashboardViewModel>(
    () => DashboardViewModel(dashboardService: getIt()),
  );

  getIt.registerFactory<PemasukanViewModel>(
    () => PemasukanViewModel(pemasukanService: getIt()),
  );

  getIt.registerFactory<PengeluaranViewModel>(
    () => PengeluaranViewModel(pengeluaranService: getIt()),
  );

  getIt.registerFactory<ReceiptViewModel>(
    () => ReceiptViewModel(receiptService: getIt()),
  );

  getIt.registerFactory<NotifikasiViewModel>(
    () => NotifikasiViewModel(notifikasiService: getIt()),
  );
}

