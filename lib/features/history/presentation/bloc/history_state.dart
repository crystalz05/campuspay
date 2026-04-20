import 'package:equatable/equatable.dart';

import '../../../dashboard/domain/entities/transaction_entity.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<TransactionEntity> transactions;
  final TransactionType? currentFilter;

  const HistoryLoaded({
    required this.transactions,
    this.currentFilter,
  });

  @override
  List<Object?> get props => [transactions, currentFilter];
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
