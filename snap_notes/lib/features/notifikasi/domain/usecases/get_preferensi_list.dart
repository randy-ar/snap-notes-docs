import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/preferensi_notifikasi.dart';
import '../repositories/notifikasi_repository.dart';

class GetPreferensiList {
  final NotifikasiRepository repository;

  GetPreferensiList(this.repository);

  Future<Either<Failure, List<PreferensiNotifikasi>>> call() {
    return repository.getPreferensiList();
  }
}
