import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snap_notes/core/usecase/usecase.dart';
import 'package:snap_notes/features/auth/domain/usecases/get_profil.dart';
import 'package:snap_notes/features/auth/domain/usecases/keluar.dart';
import 'package:snap_notes/features/auth/presentation/cubit/auth_state.dart';

/// Mengelola status autentikasi global (apakah user sudah login atau belum).
class AuthCubit extends Cubit<AuthState> {
  final GetProfil getProfilUseCase;
  final Keluar keluarUseCase;

  AuthCubit({
    required this.getProfilUseCase,
    required this.keluarUseCase,
  }) : super(const AuthInitial());

  /// Cek apakah user sudah terautentikasi dengan mengambil profil dari server.
  Future<void> checkAuth() async {
    emit(const AuthLoading());
    final result = await getProfilUseCase(NoParams());
    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (pengguna) => emit(AuthAuthenticated(pengguna)),
    );
  }

  /// Logout pengguna dari semua sesi.
  Future<void> logout() async {
    emit(const AuthLoading());
    final result = await keluarUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  /// Update data pengguna setelah profil berhasil di-update.
  void updateUser(dynamic pengguna) {
    if (pengguna != null) {
      emit(AuthAuthenticated(pengguna));
    }
  }
}
