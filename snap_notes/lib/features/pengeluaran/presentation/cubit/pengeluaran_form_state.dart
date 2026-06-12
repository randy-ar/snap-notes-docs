import 'package:equatable/equatable.dart';
import 'package:snap_notes/features/pengeluaran/domain/entities/pengeluaran.dart';

abstract class PengeluaranFormState extends Equatable {
  const PengeluaranFormState();

  @override
  List<Object> get props => [];
}

class PengeluaranFormInitial extends PengeluaranFormState {}

class PengeluaranFormLoading extends PengeluaranFormState {}

class PengeluaranFormSuccess extends PengeluaranFormState {
  final Pengeluaran pengeluaran;

  const PengeluaranFormSuccess(this.pengeluaran);

  @override
  List<Object> get props => [pengeluaran];
}

class PengeluaranFormError extends PengeluaranFormState {
  final String message;

  const PengeluaranFormError(this.message);

  @override
  List<Object> get props => [message];
}
