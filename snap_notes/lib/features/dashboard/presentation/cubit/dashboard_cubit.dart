import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:snap_notes/features/dashboard/domain/entities/ringkasan.dart';
import 'package:snap_notes/features/dashboard/domain/usecases/get_ringkasan_dashboard_usecase.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetRingkasanDashboardUseCase getRingkasanDashboardUseCase;

  DashboardCubit({required this.getRingkasanDashboardUseCase}) : super(DashboardInitial());

  Future<void> fetchRingkasan({int? bulan, int? tahun}) async {
    emit(DashboardLoading());
    final result = await getRingkasanDashboardUseCase(bulan: bulan, tahun: tahun);
    
    result.fold(
      (failure) {
        if (!isClosed) emit(DashboardError(failure.message));
      },
      (ringkasan) {
        if (!isClosed) emit(DashboardLoaded(ringkasan));
      },
    );
  }
}
