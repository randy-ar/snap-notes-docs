import 'package:equatable/equatable.dart';

abstract class NotifikasiFormState extends Equatable {
  const NotifikasiFormState();

  @override
  List<Object> get props => [];
}

class NotifikasiFormInitial extends NotifikasiFormState {}

class NotifikasiFormLoading extends NotifikasiFormState {}

class NotifikasiFormSuccess extends NotifikasiFormState {
  final String message;

  const NotifikasiFormSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class NotifikasiFormError extends NotifikasiFormState {
  final String message;

  const NotifikasiFormError(this.message);

  @override
  List<Object> get props => [message];
}
