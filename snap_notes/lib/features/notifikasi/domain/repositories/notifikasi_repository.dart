import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/preferensi_notifikasi.dart';

abstract class NotifikasiRepository {
  Future<Either<Failure, List<PreferensiNotifikasi>>> getPreferensiList();
  Future<Either<Failure, PreferensiNotifikasi>> tambahPreferensi(PreferensiNotifikasi preferensi);
  Future<Either<Failure, PreferensiNotifikasi>> updatePreferensi(String id, PreferensiNotifikasi preferensi);
  Future<Either<Failure, void>> hapusPreferensi(String id);
}
