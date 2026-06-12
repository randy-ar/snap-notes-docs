import re

with open('lib/injection_container.dart', 'r') as f:
    content = f.read()

pemasukan_imports = """
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
"""

# add imports near pengeluaran imports
if 'import \'package:snap_notes/features/pemasukan' not in content:
    content = content.replace(
        "import 'package:snap_notes/features/pengeluaran/presentation/cubit/pengeluaran_list_cubit.dart';",
        "import 'package:snap_notes/features/pengeluaran/presentation/cubit/pengeluaran_list_cubit.dart';\n" + pemasukan_imports
    )

pemasukan_di = """

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
      secureStorage: sl(),
    ),
  );
"""

# add DI config below pengeluaran config
if 'Pemasukan Feature' not in content:
    content = content.replace(
        "      secureStorage: sl(),\n    ),\n  );",
        "      secureStorage: sl(),\n    ),\n  );" + pemasukan_di
    )

with open('lib/injection_container.dart', 'w') as f:
    f.write(content)
print("Pemasukan injected")
