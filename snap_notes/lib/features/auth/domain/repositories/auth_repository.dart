import 'package:dartz/dartz.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/features/auth/domain/entities/auth_token.dart';
import 'package:snap_notes/features/auth/domain/entities/pengguna.dart';

abstract class AuthRepository {
  /// Login dengan email dan password via NestJS backend
  Future<Either<Failure, AuthToken>> masuk(String email, String password);

  /// Login dengan Google via Supabase OAuth
  /// Mengembalikan AuthToken berisi Supabase JWT
  Future<Either<Failure, AuthToken>> masukDenganGoogle();

  /// Daftar akun baru via NestJS backend
  Future<Either<Failure, Pengguna>> daftar(
    String email,
    String password,
    String namaLengkap,
  );

  /// Logout — hapus token lokal dan invalidate Supabase session
  Future<Either<Failure, void>> keluar();

  /// Ambil profil pengguna dari NestJS backend
  Future<Either<Failure, Pengguna>> getProfil();

  /// Update profil pengguna
  Future<Either<Failure, Pengguna>> updateProfil({
    String? namaLengkap,
    String? fotoProfilUrl,
  });
}
