import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/notifikasi_repository.dart';

class HapusPreferensi {
  final NotifikasiRepository repository;

  HapusPreferensi(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.hapusPreferensi(id);
  }
}
