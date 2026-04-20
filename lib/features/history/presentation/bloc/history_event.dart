import 'package:equatable/equatable.dart';

import '../../../dashboard/domain/entities/transaction_entity.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class FetchHistoryEvent extends HistoryEvent {
  final TransactionType? type;

  const FetchHistoryEvent({this.type});

  @override
  List<Object?> get props => [type];
}

class RefreshHistoryEvent extends HistoryEvent {
  final TransactionType? type;

  const RefreshHistoryEvent({this.type});

  @override
  List<Object?> get props => [type];
}
