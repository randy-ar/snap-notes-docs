import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snap_notes/features/pengeluaran/domain/entities/pengeluaran.dart';
import 'package:snap_notes/features/pengeluaran/domain/usecases/get_daftar_pengeluaran_usecase.dart';

abstract class PengeluaranListState extends Equatable {
  const PengeluaranListState();

  @override
  List<Object?> get props => [];
}

class PengeluaranListInitial extends PengeluaranListState {}

class PengeluaranListLoading extends PengeluaranListState {}

class PengeluaranListLoaded extends PengeluaranListState {
  final List<Pengeluaran> pengeluaranList;
  final int? bulan;
  final int? tahun;

  const PengeluaranListLoaded({
    required this.pengeluaranList,
    this.bulan,
    this.tahun,
  });

  @override
  List<Object?> get props => [pengeluaranList, bulan, tahun];
}

class PengeluaranListError extends PengeluaranListState {
  final String message;

  const PengeluaranListError(this.message);

  @override
  List<Object?> get props => [message];
}

class PengeluaranListCubit extends Cubit<PengeluaranListState> {
  final GetDaftarPengeluaranUseCase getDaftarPengeluaranUseCase;

  PengeluaranListCubit({
    required this.getDaftarPengeluaranUseCase,
  }) : super(PengeluaranListInitial());

  Future<void> fetchPengeluaran({int? bulan, int? tahun}) async {
    emit(PengeluaranListLoading());
    final result = await getDaftarPengeluaranUseCase(
      bulan: bulan,
      tahun: tahun,
    );

    result.fold(
      (failure) => emit(PengeluaranListError(failure.message)),
      (pengeluarans) => emit(PengeluaranListLoaded(
        pengeluaranList: pengeluarans,
        bulan: bulan,
        tahun: tahun,
      )),
    );
  }
}
