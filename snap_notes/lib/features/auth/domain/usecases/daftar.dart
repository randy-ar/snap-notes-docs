import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:snap_notes/core/error/failures.dart';
import 'package:snap_notes/core/usecase/usecase.dart';
import 'package:snap_notes/features/auth/domain/entities/pengguna.dart';
import 'package:snap_notes/features/auth/domain/repositories/auth_repository.dart';

class Daftar implements UseCase<Pengguna, DaftarParams> {
  final AuthRepository repository;

  Daftar(this.repository);

  @override
  Future<Either<Failure, Pengguna>> call(DaftarParams params) {
    return repository.daftar(params.email, params.password, params.namaLengkap);
  }
}

class DaftarParams extends Equatable {
  final String email;
  final String password;
  final String namaLengkap;

  const DaftarParams({
    required this.email,
    required this.password,
    required this.namaLengkap,
  });

  @override
  List<Object> get props => [email, password, namaLengkap];
}
