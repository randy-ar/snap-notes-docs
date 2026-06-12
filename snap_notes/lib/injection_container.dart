import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:snap_notes/core/network/dio_client.dart';
import 'package:snap_notes/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:snap_notes/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:snap_notes/features/auth/data/datasources/auth_supabase_datasource.dart';
import 'package:snap_notes/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:snap_notes/features/auth/domain/repositories/auth_repository.dart';
import 'package:snap_notes/features/auth/domain/usecases/daftar.dart';
import 'package:snap_notes/features/auth/domain/usecases/get_profil.dart';
import 'package:snap_notes/features/auth/domain/usecases/keluar.dart';
import 'package:snap_notes/features/auth/domain/usecases/masuk.dart';
import 'package:snap_notes/features/auth/domain/usecases/masuk_dengan_google.dart';
import 'package:snap_notes/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:snap_notes/features/auth/presentation/cubit/login_cubit.dart';
import 'package:snap_notes/features/auth/presentation/cubit/register_cubit.dart';
import 'package:snap_notes/features/receipt/data/datasources/receipt_local_datasource.dart';
import 'package:snap_notes/features/receipt/data/datasources/receipt_remote_datasource.dart';
import 'package:snap_notes/features/receipt/data/repositories/receipt_repository_impl.dart';
import 'package:snap_notes/features/receipt/domain/repositories/receipt_repository.dart';
import 'package:snap_notes/features/receipt/domain/usecases/scan_receipt.dart';
import 'package:snap_notes/features/receipt/domain/usecases/get_receipts_usecase.dart';
import 'package:snap_notes/features/receipt/domain/usecases/get_receipt_detail_usecase.dart';
import 'package:snap_notes/features/receipt/presentation/bloc/receipt_bloc.dart';
import 'package:snap_notes/features/receipt/presentation/cubit/receipt_history_cubit.dart';
import 'package:snap_notes/features/receipt/presentation/cubit/receipt_detail_cubit.dart';
import 'package:snap_notes/features/pengeluaran/data/datasources/pengeluaran_remote_data_source.dart';
import 'package:snap_notes/features/pengeluaran/data/repositories/pengeluaran_repository_impl.dart';
import 'package:snap_notes/features/pengeluaran/domain/repositories/pengeluaran_repository.dart';
import 'package:snap_notes/features/pengeluaran/domain/usecases/tambah_pengeluaran_usecase.dart';
import 'package:snap_notes/features/pengeluaran/domain/usecases/get_daftar_pengeluaran_usecase.dart';
import 'package:snap_notes/features/pengeluaran/domain/usecases/get_pengeluaran_detail_usecase.dart';
import 'package:snap_notes/features/pengeluaran/domain/usecases/update_pengeluaran_usecase.dart';
import 'package:snap_notes/features/pengeluaran/domain/usecases/hapus_pengeluaran_usecase.dart';
import 'package:snap_notes/features/pengeluaran/presentation/cubit/pengeluaran_list_cubit.dart';

import 'package:snap_notes/features/pemasukan/data/datasources/pemasukan_remote_data_source.dart';
import 'package:snap_notes/features/pemasukan/data/repositories/pemasukan_repository_impl.dart';
import 'package:snap_notes/features/pemasukan/domain/repositories/pemasukan_repository.dart';
import 'package:snap_notes/features/pemasukan/domain/usecases/get_daftar_pemasukan_usecase.dart';
import 'package:snap_notes/features/pemasukan/domain/usecases/get_pemasukan_detail_usecase.dart';
import 'package:snap_notes/features/pemasukan/domain/usecases/hapus_pemasukan_usecase.dart';
import 'package:snap_notes/features/pemasukan/domain/usecases/tambah_pemasukan_usecase.dart';
import 'package:snap_notes/features/pemasukan/domain/usecases/update_pemasukan_usecase.dart';
import 'package:snap_notes/features/pemasukan/presentation/cubit/pemasukan_detail_cubit.dart';
import 'package:snap_notes/features/pemasukan/presentation/cubit/pemasukan_form_cubit.dart';
import 'package:snap_notes/features/pemasukan/presentation/cubit/pemasukan_list_cubit.dart';

import 'package:snap_notes/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:snap_notes/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:snap_notes/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:snap_notes/features/dashboard/domain/usecases/get_ringkasan_dashboard_usecase.dart';
import 'package:snap_notes/features/dashboard/presentation/cubit/dashboard_cubit.dart';


import 'package:snap_notes/features/pengeluaran/presentation/cubit/pengeluaran_detail_cubit.dart';
import 'package:snap_notes/features/pengeluaran/presentation/cubit/pengeluaran_form_cubit.dart';

import 'package:snap_notes/features/notifikasi/data/datasources/local_notification_data_source.dart';
import 'package:snap_notes/features/notifikasi/data/datasources/notifikasi_remote_data_source.dart';
import 'package:snap_notes/features/notifikasi/data/repositories/notifikasi_repository_impl.dart';
import 'package:snap_notes/features/notifikasi/domain/repositories/notifikasi_repository.dart';
import 'package:snap_notes/features/notifikasi/domain/usecases/get_preferensi_list.dart';
import 'package:snap_notes/features/notifikasi/domain/usecases/tambah_preferensi.dart';
import 'package:snap_notes/features/notifikasi/domain/usecases/update_preferensi.dart';
import 'package:snap_notes/features/notifikasi/domain/usecases/hapus_preferensi.dart';
import 'package:snap_notes/features/notifikasi/presentation/cubit/notifikasi_list_cubit.dart';
import 'package:snap_notes/features/notifikasi/presentation/cubit/notifikasi_form_cubit.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ---- Auth Feature ----

  // Cubits (factory: instance baru tiap kali dipanggil)
  sl.registerFactory(
    () => AuthCubit(getProfilUseCase: sl(), keluarUseCase: sl()),
  );
  sl.registerFactory(
    () => LoginCubit(masukUseCase: sl(), masukDenganGoogleUseCase: sl()),
  );
  sl.registerFactory(
    () => RegisterCubit(daftarUseCase: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => Masuk(sl()));
  sl.registerLazySingleton(() => MasukDenganGoogle(sl()));
  sl.registerLazySingleton(() => Daftar(sl()));
  sl.registerLazySingleton(() => Keluar(sl()));
  sl.registerLazySingleton(() => GetProfil(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      supabaseDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(storage: sl()),
  );
  sl.registerLazySingleton<AuthSupabaseDataSource>(
    () => AuthSupabaseDataSourceImpl(supabaseClient: sl()),
  );

  // ---- Receipt Feature ----

  // Cubits / Blocs
  sl.registerFactory(() => ReceiptBloc(
    scanReceipt: sl(),
    localDataSource: sl(),
    remoteDataSource: sl(),
  ));
  sl.registerFactory(() => ReceiptHistoryCubit(
    getReceiptsUseCase: sl(),
  ));
  sl.registerFactory(() => ReceiptDetailCubit(
    getReceiptDetailUseCase: sl(),
  ));

  // Use cases
  sl.registerLazySingleton(() => ScanReceiptUseCase(sl()));
  sl.registerLazySingleton(() => GetReceiptsUseCase(sl()));
  sl.registerLazySingleton(() => GetReceiptDetailUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ReceiptRepository>(
    () => ReceiptRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ReceiptLocalDataSource>(
    () => ReceiptLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<ReceiptRemoteDataSource>(
    () => ReceiptRemoteDataSourceImpl(dio: sl()),
  );

  // ---- Pengeluaran Feature ----
  
  // Cubits
  sl.registerFactory(() => PengeluaranFormCubit(
        tambahPengeluaranUseCase: sl(),
        updatePengeluaranUseCase: sl(),
      ));
  sl.registerFactory(() => PengeluaranListCubit(
    getDaftarPengeluaranUseCase: sl(),
  ));
  sl.registerFactory(() => PengeluaranDetailCubit(
    getPengeluaranDetailUseCase: sl(),
    hapusPengeluaranUseCase: sl(),
  ));

  // Use cases
  sl.registerLazySingleton(() => TambahPengeluaranUseCase(sl()));
  sl.registerLazySingleton(() => GetDaftarPengeluaranUseCase(sl()));
  sl.registerLazySingleton(() => GetPengeluaranDetailUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePengeluaranUseCase(sl()));
  sl.registerLazySingleton(() => HapusPengeluaranUseCase(sl()));

  // Repository
  sl.registerLazySingleton<PengeluaranRepository>(
    () => PengeluaranRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<PengeluaranRemoteDataSource>(
    () => PengeluaranRemoteDataSourceImpl(
      dio: sl(),
    ),
  );


  // ---- Pemasukan Feature ----

  // Cubits
  sl.registerFactory(() => PemasukanFormCubit(
        tambahPemasukanUseCase: sl(),
        updatePemasukanUseCase: sl(),
      ));
  sl.registerFactory(() => PemasukanListCubit(
    getDaftarPemasukanUseCase: sl(),
  ));
  sl.registerFactory(() => PemasukanDetailCubit(
    getPemasukanDetailUseCase: sl(),
    hapusPemasukanUseCase: sl(),
  ));

  // Use Cases
  sl.registerLazySingleton(() => TambahPemasukanUseCase(sl()));
  sl.registerLazySingleton(() => GetDaftarPemasukanUseCase(sl()));
  sl.registerLazySingleton(() => GetPemasukanDetailUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePemasukanUseCase(sl()));
  sl.registerLazySingleton(() => HapusPemasukanUseCase(sl()));

  // Repository
  sl.registerLazySingleton<PemasukanRepository>(
    () => PemasukanRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<PemasukanRemoteDataSource>(
    () => PemasukanRemoteDataSourceImpl(
      dio: sl(),
    ),
  );


  // ---- Dashboard Feature ----

  // Cubits
  sl.registerFactory(() => DashboardCubit(
    getRingkasanDashboardUseCase: sl(),
  ));

  // Use Cases
  sl.registerLazySingleton(() => GetRingkasanDashboardUseCase(sl()));

  // Repository
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(
      dio: sl(),
    ),
  );

  // ---- Notifikasi Feature ----

  // Cubits
  sl.registerFactory(() => NotifikasiListCubit(
    getPreferensiList: sl(),
    hapusPreferensi: sl(),
    updatePreferensi: sl(),
  ));
  sl.registerFactory(() => NotifikasiFormCubit(
    tambahPreferensi: sl(),
    updatePreferensi: sl(),
  ));

  // Use Cases
  sl.registerLazySingleton(() => GetPreferensiList(sl()));
  sl.registerLazySingleton(() => TambahPreferensi(sl()));
  sl.registerLazySingleton(() => UpdatePreferensi(sl()));
  sl.registerLazySingleton(() => HapusPreferensi(sl()));

  // Repository
  sl.registerLazySingleton<NotifikasiRepository>(
    () => NotifikasiRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<NotifikasiRemoteDataSource>(
    () => NotifikasiRemoteDataSourceImpl(
      dio: sl(),
    ),
  );
  sl.registerLazySingleton<LocalNotificationDataSource>(
    () => LocalNotificationDataSourceImpl(
      flutterLocalNotificationsPlugin: sl(),
    ),
  );

  // ---- Core / External ----



  // Dio dengan AuthInterceptor untuk inject Bearer token otomatis
  sl.registerLazySingleton(() => DioClient(storage: sl()).dio);

  // FlutterSecureStorage
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // FlutterLocalNotificationsPlugin
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());

  // Supabase client
  sl.registerLazySingleton(() => Supabase.instance.client);
}
