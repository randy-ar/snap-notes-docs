import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snap_notes/features/pemasukan/domain/entities/pemasukan.dart';
import 'package:snap_notes/features/pemasukan/domain/usecases/get_pemasukan_detail_usecase.dart';
import 'package:snap_notes/features/pemasukan/domain/usecases/hapus_pemasukan_usecase.dart';

abstract class PemasukanDetailState extends Equatable {
  const PemasukanDetailState();

  @override
  List<Object?> get props => [];
}

class PemasukanDetailInitial extends PemasukanDetailState {}

class PemasukanDetailLoading extends PemasukanDetailState {}

class PemasukanDetailLoaded extends PemasukanDetailState {
  final Pemasukan pemasukan;

  const PemasukanDetailLoaded(this.pemasukan);

  @override
  List<Object?> get props => [pemasukan];
}

class PemasukanDetailError extends PemasukanDetailState {
  final String message;

  const PemasukanDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class PemasukanDetailDeleted extends PemasukanDetailState {}

class PemasukanDetailCubit extends Cubit<PemasukanDetailState> {
  final GetPemasukanDetailUseCase getPemasukanDetailUseCase;
  final HapusPemasukanUseCase hapusPemasukanUseCase;

  PemasukanDetailCubit({
    required this.getPemasukanDetailUseCase,
    required this.hapusPemasukanUseCase,
  }) : super(PemasukanDetailInitial());

  Future<void> fetchPemasukanDetail(String id) async {
    emit(PemasukanDetailLoading());
    final result = await getPemasukanDetailUseCase(id);

    result.fold(
      (failure) => emit(PemasukanDetailError(failure.message)),
      (pemasukan) => emit(PemasukanDetailLoaded(pemasukan)),
    );
  }

  Future<void> deletePemasukan(String id) async {
    emit(PemasukanDetailLoading());
    final result = await hapusPemasukanUseCase(id);

    result.fold(
      (failure) => emit(PemasukanDetailError(failure.message)),
      (_) => emit(PemasukanDetailDeleted()),
    );
  }
}
