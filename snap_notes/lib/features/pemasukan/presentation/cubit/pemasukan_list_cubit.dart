import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snap_notes/features/pemasukan/domain/entities/pemasukan.dart';
import 'package:snap_notes/features/pemasukan/domain/usecases/get_daftar_pemasukan_usecase.dart';

abstract class PemasukanListState extends Equatable {
  const PemasukanListState();

  @override
  List<Object?> get props => [];
}

class PemasukanListInitial extends PemasukanListState {}

class PemasukanListLoading extends PemasukanListState {}

class PemasukanListLoaded extends PemasukanListState {
  final List<Pemasukan> pemasukanList;
  final int? bulan;
  final int? tahun;

  const PemasukanListLoaded({
    required this.pemasukanList,
    this.bulan,
    this.tahun,
  });

  @override
  List<Object?> get props => [pemasukanList, bulan, tahun];
}

class PemasukanListError extends PemasukanListState {
  final String message;

  const PemasukanListError(this.message);

  @override
  List<Object?> get props => [message];
}

class PemasukanListCubit extends Cubit<PemasukanListState> {
  final GetDaftarPemasukanUseCase getDaftarPemasukanUseCase;

  PemasukanListCubit({
    required this.getDaftarPemasukanUseCase,
  }) : super(PemasukanListInitial());

  Future<void> fetchPemasukan({int? bulan, int? tahun}) async {
    emit(PemasukanListLoading());
    final result = await getDaftarPemasukanUseCase(
      bulan: bulan,
      tahun: tahun,
    );

    result.fold(
      (failure) => emit(PemasukanListError(failure.message)),
      (pemasukans) => emit(PemasukanListLoaded(
        pemasukanList: pemasukans,
        bulan: bulan,
        tahun: tahun,
      )),
    );
  }
}
