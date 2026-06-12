import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/preferensi_notifikasi.dart';
import '../repositories/notifikasi_repository.dart';

class UpdatePreferensi {
  final NotifikasiRepository repository;

  UpdatePreferensi(this.repository);

  Future<Either<Failure, PreferensiNotifikasi>> call(String id, PreferensiNotifikasi preferensi) {
    return repository.updatePreferensi(id, preferensi);
  }
}
