import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/preferensi_notifikasi.dart';
import '../repositories/notifikasi_repository.dart';

class TambahPreferensi {
  final NotifikasiRepository repository;

  TambahPreferensi(this.repository);

  Future<Either<Failure, PreferensiNotifikasi>> call(PreferensiNotifikasi preferensi) {
    return repository.tambahPreferensi(preferensi);
  }
}
