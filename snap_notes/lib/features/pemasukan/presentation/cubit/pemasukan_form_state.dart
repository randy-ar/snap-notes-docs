import 'package:equatable/equatable.dart';
import 'package:snap_notes/features/pemasukan/domain/entities/pemasukan.dart';

abstract class PemasukanFormState extends Equatable {
  const PemasukanFormState();

  @override
  List<Object> get props => [];
}

class PemasukanFormInitial extends PemasukanFormState {}

class PemasukanFormLoading extends PemasukanFormState {}

class PemasukanFormSuccess extends PemasukanFormState {
  final Pemasukan pemasukan;

  const PemasukanFormSuccess(this.pemasukan);

  @override
  List<Object> get props => [pemasukan];
}

class PemasukanFormError extends PemasukanFormState {
  final String message;

  const PemasukanFormError(this.message);

  @override
  List<Object> get props => [message];
}
