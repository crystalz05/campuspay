import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class TransferState extends Equatable {
  const TransferState();

  @override
  List<Object?> get props => [];
}

class TransferInitial extends TransferState {}

class RecipientSearching extends TransferState {}

class RecipientFound extends TransferState {
  final UserEntity recipient;

  const RecipientFound(this.recipient);

  @override
  List<Object?> get props => [recipient];
}

class RecipientSearchError extends TransferState {
  final String message;

  const RecipientSearchError(this.message);

  @override
  List<Object?> get props => [message];
}

class AmountEntered extends TransferState {
  final UserEntity recipient;
  final double amount;
  final String? note;

  const AmountEntered({
    required this.recipient,
    required this.amount,
    this.note,
  });

  @override
  List<Object?> get props => [recipient, amount, note];
}

class TransferProcessing extends TransferState {
  final UserEntity recipient;
  final double amount;
  final String? note;

  const TransferProcessing({
    required this.recipient,
    required this.amount,
    this.note,
  });

  @override
  List<Object?> get props => [recipient, amount, note];
}

class TransferSuccess extends TransferState {
  final String transactionId;
  final UserEntity recipient;
  final double amount;

  const TransferSuccess({
    required this.transactionId,
    required this.recipient,
    required this.amount,
  });

  @override
  List<Object?> get props => [transactionId, recipient, amount];
}

class TransferError extends TransferState {
  final String message;
  final UserEntity recipient;
  final double amount;
  final String? note;

  const TransferError({
    required this.message,
    required this.recipient,
    required this.amount,
    this.note,
  });

  @override
  List<Object?> get props => [message, recipient, amount, note];
}
