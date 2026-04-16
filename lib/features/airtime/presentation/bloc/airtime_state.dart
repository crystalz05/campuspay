import 'package:equatable/equatable.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';
import '../../../data_bundle/domain/entities/data_bundle_entity.dart';

abstract class AirtimeState extends Equatable {
  const AirtimeState();

  @override
  List<Object?> get props => [];
}

class AirtimeInitial extends AirtimeState {}

class AirtimePurchasing extends AirtimeState {}

class AirtimePurchaseSuccess extends AirtimeState {
  final TransactionEntity transaction;
  final NetworkProvider network;
  final String phoneNumber;
  final double amount;

  const AirtimePurchaseSuccess({
    required this.transaction,
    required this.network,
    required this.phoneNumber,
    required this.amount,
  });

  @override
  List<Object?> get props => [transaction, network, phoneNumber, amount];
}

class AirtimeError extends AirtimeState {
  final String message;

  const AirtimeError(this.message);

  @override
  List<Object?> get props => [message];
}
