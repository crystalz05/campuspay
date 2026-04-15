import 'package:equatable/equatable.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';

abstract class FundWalletState extends Equatable {
  const FundWalletState();

  @override
  List<Object?> get props => [];
}

class FundWalletInitial extends FundWalletState {}

class FundWalletProcessing extends FundWalletState {}

class FundWalletSuccess extends FundWalletState {
  final TransactionEntity transaction;

  const FundWalletSuccess(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class FundWalletError extends FundWalletState {
  final String message;

  const FundWalletError(this.message);

  @override
  List<Object?> get props => [message];
}
