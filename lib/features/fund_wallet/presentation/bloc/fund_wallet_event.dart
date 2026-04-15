import 'package:equatable/equatable.dart';

abstract class FundWalletEvent extends Equatable {
  const FundWalletEvent();

  @override
  List<Object?> get props => [];
}

class SubmitFundWalletEvent extends FundWalletEvent {
  final double amount;
  final String paymentMethod;

  const SubmitFundWalletEvent({
    required this.amount,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [amount, paymentMethod];
}

class ResetFundWalletEvent extends FundWalletEvent {}
