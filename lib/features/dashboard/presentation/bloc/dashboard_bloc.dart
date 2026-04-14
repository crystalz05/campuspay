import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_recent_transactions_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetRecentTransactionsUseCase getRecentTransactionsUseCase;

  DashboardBloc({
    required this.getRecentTransactionsUseCase,
  }) : super(DashboardInitial()) {
    on<FetchDashboardDataEvent>(_onFetchDashboardData);
  }

  Future<void> _onFetchDashboardData(
    FetchDashboardDataEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    final result = await getRecentTransactionsUseCase(NoParams());
    
    result.fold(
      (failure) => emit(DashboardError(message: failure.message)),
      (transactions) => emit(DashboardLoaded(transactions: transactions)),
    );
  }
}
