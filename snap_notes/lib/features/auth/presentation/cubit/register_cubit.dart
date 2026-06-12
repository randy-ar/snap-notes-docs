import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snap_notes/features/auth/domain/usecases/daftar.dart';
import 'package:snap_notes/features/auth/presentation/cubit/register_state.dart';

/// Mengelola proses registrasi akun baru.
class RegisterCubit extends Cubit<RegisterState> {
  final Daftar daftarUseCase;

  RegisterCubit({required this.daftarUseCase}) : super(const RegisterInitial());

  Future<void> daftar({
    required String email,
    required String password,
    required String namaLengkap,
  }) async {
    emit(const RegisterLoading());
    final result = await daftarUseCase(
      DaftarParams(email: email, password: password, namaLengkap: namaLengkap),
    );
    result.fold(
      (failure) => emit(RegisterError(failure.message)),
      (pengguna) => emit(RegisterSuccess(pengguna)),
    );
  }

  void reset() => emit(const RegisterInitial());
}
