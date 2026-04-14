import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<TransactionEntity> transactions;

  const DashboardLoaded({required this.transactions});

  @override
  List<Object?> get props => [transactions];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
