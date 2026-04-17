import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/process_transfer_usecase.dart';
import '../../domain/usecases/search_recipient_usecase.dart';
import 'package:campuspay/features/transfer/presentation/bloc/transfer_event.dart';
import 'package:campuspay/features/transfer/presentation/bloc/transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final SearchRecipientUseCase _searchRecipientUseCase;
  final ProcessTransferUseCase _processTransferUseCase;

  TransferBloc({
    required SearchRecipientUseCase searchRecipientUseCase,
    required ProcessTransferUseCase processTransferUseCase,
  })  : _searchRecipientUseCase = searchRecipientUseCase,
        _processTransferUseCase = processTransferUseCase,
        super(TransferInitial()) {
    on<SearchRecipientEvent>(_onSearchRecipient);
    on<SelectRecipientEvent>(_onSelectRecipient);
    on<EnterAmountEvent>(_onEnterAmount);
    on<SubmitTransferEvent>(_onSubmitTransfer);
    on<ResetTransferEvent>(_onResetTransfer);
  }

  Future<void> _onSearchRecipient(SearchRecipientEvent event, Emitter<TransferState> emit) async {
    emit(RecipientSearching());
    
    final result = await _searchRecipientUseCase(event.query);
    
    result.fold(
      (failure) => emit(RecipientSearchError(failure.message)),
      (recipient) => emit(RecipientFound(recipient)),
    );
  }

  void _onSelectRecipient(SelectRecipientEvent event, Emitter<TransferState> emit) {
    emit(RecipientFound(event.recipient));
  }

  void _onEnterAmount(EnterAmountEvent event, Emitter<TransferState> emit) {
    if (state is RecipientFound) {
      final currentState = state as RecipientFound;
      emit(AmountEntered(
        recipient: currentState.recipient,
        amount: event.amount,
        note: event.note,
      ));
    } else if (state is AmountEntered) {
      final currentState = state as AmountEntered;
      emit(AmountEntered(
        recipient: currentState.recipient,
        amount: event.amount,
        note: event.note,
      ));
    } else if (state is TransferError) {
      final currentState = state as TransferError;
      emit(AmountEntered(
        recipient: currentState.recipient,
        amount: event.amount,
        note: event.note,
      ));
    }
  }

  Future<void> _onSubmitTransfer(SubmitTransferEvent event, Emitter<TransferState> emit) async {
    if (state is AmountEntered) {
      final currentState = state as AmountEntered;
      emit(TransferProcessing(
        recipient: currentState.recipient,
        amount: currentState.amount,
        note: currentState.note,
      ));

      final result = await _processTransferUseCase(
        ProcessTransferParams(
          receiverId: currentState.recipient.id,
          amount: currentState.amount,
          note: currentState.note,
          pin: event.pin,
        ),
      );

      result.fold(
        (failure) => emit(TransferError(
          message: failure.message,
          recipient: currentState.recipient,
          amount: currentState.amount,
          note: currentState.note,
        )),
        (transactionId) => emit(TransferSuccess(
          transactionId: transactionId,
          recipient: currentState.recipient,
          amount: currentState.amount,
        )),
      );
    }
  }

  void _onResetTransfer(ResetTransferEvent event, Emitter<TransferState> emit) {
    emit(TransferInitial());
  }
}
