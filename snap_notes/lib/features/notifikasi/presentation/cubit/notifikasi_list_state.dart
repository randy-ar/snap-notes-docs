import 'package:equatable/equatable.dart';
import '../../domain/entities/preferensi_notifikasi.dart';

abstract class NotifikasiListState extends Equatable {
  const NotifikasiListState();

  @override
  List<Object> get props => [];
}

class NotifikasiListInitial extends NotifikasiListState {}

class NotifikasiListLoading extends NotifikasiListState {}

class NotifikasiListLoaded extends NotifikasiListState {
  final List<PreferensiNotifikasi> preferensiList;

  const NotifikasiListLoaded(this.preferensiList);

  @override
  List<Object> get props => [preferensiList];
}

class NotifikasiListError extends NotifikasiListState {
  final String message;

  const NotifikasiListError(this.message);

  @override
  List<Object> get props => [message];
}

class NotifikasiListActionSuccess extends NotifikasiListState {
  final String message;

  const NotifikasiListActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}
