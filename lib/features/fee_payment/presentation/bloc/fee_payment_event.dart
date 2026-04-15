import 'package:equatable/equatable.dart';
import '../../domain/entities/fee_payment_entity.dart';

abstract class FeePaymentEvent extends Equatable {
  const FeePaymentEvent();

  @override
  List<Object?> get props => [];
}

class ValidateRrrEvent extends FeePaymentEvent {
  final String rrrNumber;
  const ValidateRrrEvent(this.rrrNumber);

  @override
  List<Object?> get props => [rrrNumber];
}

class SubmitFeePaymentEvent extends FeePaymentEvent {
  final FeePaymentEntity details;
  const SubmitFeePaymentEvent(this.details);

  @override
  List<Object?> get props => [details];
}

class ResetFeePaymentEvent extends FeePaymentEvent {}
