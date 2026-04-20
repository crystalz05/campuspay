import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../dashboard/domain/usecases/get_transactions_usecase.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetTransactionsUseCase getTransactionsUseCase;

  HistoryBloc({required this.getTransactionsUseCase}) : super(HistoryInitial()) {
    on<FetchHistoryEvent>(_onFetchHistory);
    on<RefreshHistoryEvent>(_onRefreshHistory);
  }

  Future<void> _onFetchHistory(
    FetchHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    final result = await getTransactionsUseCase(type: event.type);

    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (transactions) => emit(HistoryLoaded(
        transactions: transactions,
        currentFilter: event.type,
      )),
    );
  }

  Future<void> _onRefreshHistory(
    RefreshHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await getTransactionsUseCase(type: event.type);

    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (transactions) => emit(HistoryLoaded(
        transactions: transactions,
        currentFilter: event.type,
      )),
    );
  }
}
