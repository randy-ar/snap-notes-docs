import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snap_notes/features/pengeluaran/domain/entities/pengeluaran.dart';
import 'package:snap_notes/features/pengeluaran/domain/usecases/get_pengeluaran_detail_usecase.dart';
import 'package:snap_notes/features/pengeluaran/domain/usecases/hapus_pengeluaran_usecase.dart';

abstract class PengeluaranDetailState extends Equatable {
  const PengeluaranDetailState();

  @override
  List<Object?> get props => [];
}

class PengeluaranDetailInitial extends PengeluaranDetailState {}

class PengeluaranDetailLoading extends PengeluaranDetailState {}

class PengeluaranDetailLoaded extends PengeluaranDetailState {
  final Pengeluaran pengeluaran;

  const PengeluaranDetailLoaded(this.pengeluaran);

  @override
  List<Object?> get props => [pengeluaran];
}

class PengeluaranDetailError extends PengeluaranDetailState {
  final String message;

  const PengeluaranDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class PengeluaranDetailDeleted extends PengeluaranDetailState {}

class PengeluaranDetailCubit extends Cubit<PengeluaranDetailState> {
  final GetPengeluaranDetailUseCase getPengeluaranDetailUseCase;
  final HapusPengeluaranUseCase hapusPengeluaranUseCase;

  PengeluaranDetailCubit({
    required this.getPengeluaranDetailUseCase,
    required this.hapusPengeluaranUseCase,
  }) : super(PengeluaranDetailInitial());

  Future<void> fetchPengeluaranDetail(String id) async {
    emit(PengeluaranDetailLoading());
    final result = await getPengeluaranDetailUseCase(id);

    result.fold(
      (failure) => emit(PengeluaranDetailError(failure.message)),
      (pengeluaran) => emit(PengeluaranDetailLoaded(pengeluaran)),
    );
  }

  Future<void> deletePengeluaran(String id) async {
    emit(PengeluaranDetailLoading());
    final result = await hapusPengeluaranUseCase(id);

    result.fold(
      (failure) => emit(PengeluaranDetailError(failure.message)),
      (_) => emit(PengeluaranDetailDeleted()),
    );
  }
}
