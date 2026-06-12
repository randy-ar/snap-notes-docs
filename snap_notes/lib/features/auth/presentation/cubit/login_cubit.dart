import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snap_notes/core/usecase/usecase.dart';
import 'package:snap_notes/features/auth/domain/usecases/masuk.dart';
import 'package:snap_notes/features/auth/domain/usecases/masuk_dengan_google.dart';
import 'package:snap_notes/features/auth/presentation/cubit/login_state.dart';

/// Mengelola proses login — email/password dan Google OAuth.
class LoginCubit extends Cubit<LoginState> {
  final Masuk masukUseCase;
  final MasukDenganGoogle masukDenganGoogleUseCase;

  LoginCubit({
    required this.masukUseCase,
    required this.masukDenganGoogleUseCase,
  }) : super(const LoginInitial());

  /// Login dengan email dan password via NestJS backend.
  Future<void> login(String email, String password) async {
    emit(const LoginLoading());
    final result = await masukUseCase(MasukParams(email: email, password: password));
    result.fold(
      (failure) => emit(LoginError(failure.message)),
      (token) => emit(LoginSuccess(token)),
    );
  }

  /// Login dengan Google OAuth via Supabase.
  Future<void> loginDenganGoogle() async {
    emit(const LoginGoogleLoading());
    final result = await masukDenganGoogleUseCase(NoParams());
    result.fold(
      (failure) => emit(LoginError(failure.message)),
      (token) => emit(LoginSuccess(token)),
    );
  }

  void reset() => emit(const LoginInitial());
}
