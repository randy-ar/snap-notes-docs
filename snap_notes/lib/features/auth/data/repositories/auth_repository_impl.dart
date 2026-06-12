import 'package:dartz/dartz.dart';
import 'package:snap_notes/core/error/exceptions.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:snap_notes/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:snap_notes/features/auth/data/datasources/auth_supabase_datasource.dart';
import 'package:snap_notes/features/auth/domain/entities/auth_token.dart';
import 'package:snap_notes/features/auth/domain/entities/pengguna.dart';
import 'package:flutter/foundation.dart';
import 'package:snap_notes/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final AuthSupabaseDataSource supabaseDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.supabaseDataSource,
  });

  @override
  Future<Either<Failure, AuthToken>> masuk(String email, String password) async {
    try {
      final tokenModel = await remoteDataSource.masuk(email, password);
      await localDataSource.saveToken(tokenModel);
      return Right(tokenModel.toEntity());
    } on UnauthorizedException catch (e, stackTrace) {
      debugPrint('UnauthorizedException in masuk: $e\n$stackTrace');
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e, stackTrace) {
      debugPrint('ServerException in masuk: $e\n$stackTrace');
      return Left(ServerFailure(e.message));
    } on LocalException catch (e, stackTrace) {
      debugPrint('LocalException in masuk: $e\n$stackTrace');
      return Left(LocalFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> masukDenganGoogle() async {
    try {
      final tokenModel = await supabaseDataSource.signInWithGoogle();
      await localDataSource.saveToken(tokenModel);
      return Right(tokenModel.toEntity());
    } on OAuthException catch (e, stackTrace) {
      debugPrint('OAuthException in masukDenganGoogle: $e\n$stackTrace');
      return Left(OAuthFailure(e.message));
    } on LocalException catch (e, stackTrace) {
      debugPrint('LocalException in masukDenganGoogle: $e\n$stackTrace');
      return Left(LocalFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Pengguna>> daftar(
    String email,
    String password,
    String namaLengkap,
  ) async {
    try {
      final penggunaModel = await remoteDataSource.daftar(email, password, namaLengkap);
      return Right(penggunaModel.toEntity());
    } on ServerException catch (e, stackTrace) {
      debugPrint('ServerException in daftar: $e\n$stackTrace');
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> keluar() async {
    try {
      final tokenModel = await localDataSource.getToken();
      if (tokenModel != null) {
        // Invalidate di server jika ada token
        try {
          await remoteDataSource.keluar(tokenModel.refreshToken);
        } catch (_) {
          // Lanjutkan logout lokal meskipun server error
        }
      }
      // Logout dari Supabase session
      try {
        await supabaseDataSource.signOut();
      } catch (_) {
        // Lanjutkan hapus token lokal
      }
      await localDataSource.deleteToken();
      return const Right(null);
    } on LocalException catch (e, stackTrace) {
      debugPrint('LocalException in keluar: $e\n$stackTrace');
      return Left(LocalFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Pengguna>> getProfil() async {
    try {
      final penggunaModel = await remoteDataSource.getProfil();
      return Right(penggunaModel.toEntity());
    } on UnauthorizedException catch (e, stackTrace) {
      debugPrint('UnauthorizedException in getProfil: $e\n$stackTrace');
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e, stackTrace) {
      debugPrint('ServerException in getProfil: $e\n$stackTrace');
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Pengguna>> updateProfil({
    String? namaLengkap,
    String? fotoProfilUrl,
  }) async {
    try {
      final penggunaModel = await remoteDataSource.updateProfil(
        namaLengkap: namaLengkap,
        fotoProfilUrl: fotoProfilUrl,
      );
      return Right(penggunaModel.toEntity());
    } on UnauthorizedException catch (e, stackTrace) {
      debugPrint('UnauthorizedException in updateProfil: $e\n$stackTrace');
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e, stackTrace) {
      debugPrint('ServerException in updateProfil: $e\n$stackTrace');
      return Left(ServerFailure(e.message));
    }
  }
}
