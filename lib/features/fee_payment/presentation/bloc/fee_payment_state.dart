import 'package:equatable/equatable.dart';
import '../../../dashboard/domain/entities/transaction_entity.dart';
import '../../domain/entities/fee_payment_entity.dart';

abstract class FeePaymentState extends Equatable {
  const FeePaymentState();

  @override
  List<Object?> get props => [];
}

class FeePaymentInitial extends FeePaymentState {}

class FeePaymentValidating extends FeePaymentState {}

class FeePaymentValidated extends FeePaymentState {
  final FeePaymentEntity details;
  const FeePaymentValidated(this.details);

  @override
  List<Object?> get props => [details];
}

class FeePaymentProcessing extends FeePaymentState {}

class FeePaymentSuccess extends FeePaymentState {
  final TransactionEntity transaction;
  const FeePaymentSuccess(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class FeePaymentError extends FeePaymentState {
  final String message;
  const FeePaymentError(this.message);

  @override
  List<Object?> get props => [message];
}
