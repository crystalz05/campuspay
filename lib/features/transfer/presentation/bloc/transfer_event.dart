import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class TransferEvent extends Equatable {
  const TransferEvent();

  @override
  List<Object?> get props => [];
}

class SearchRecipientEvent extends TransferEvent {
  final String query;

  const SearchRecipientEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectRecipientEvent extends TransferEvent {
  final UserEntity recipient;

  const SelectRecipientEvent(this.recipient);

  @override
  List<Object?> get props => [recipient];
}

class EnterAmountEvent extends TransferEvent {
  final double amount;
  final String? note;

  const EnterAmountEvent({required this.amount, this.note});

  @override
  List<Object?> get props => [amount, note];
}

class SubmitTransferEvent extends TransferEvent {
  final String pin;

  const SubmitTransferEvent(this.pin);

  @override
  List<Object?> get props => [pin];
}

class ResetTransferEvent extends TransferEvent {}
