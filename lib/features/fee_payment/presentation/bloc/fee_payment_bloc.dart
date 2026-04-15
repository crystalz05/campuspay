import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/submit_fee_payment_usecase.dart';
import '../../domain/usecases/validate_rrr_usecase.dart';
import 'fee_payment_event.dart';
import 'fee_payment_state.dart';

class FeePaymentBloc extends Bloc<FeePaymentEvent, FeePaymentState> {
  final ValidateRrrUseCase validateRrrUseCase;
  final SubmitFeePaymentUseCase submitFeePaymentUseCase;

  FeePaymentBloc({
    required this.validateRrrUseCase,
    required this.submitFeePaymentUseCase,
  }) : super(FeePaymentInitial()) {
    on<ValidateRrrEvent>(_onValidateRrr);
    on<SubmitFeePaymentEvent>(_onSubmitPayment);
    on<ResetFeePaymentEvent>(_onReset);
  }

  Future<void> _onValidateRrr(
    ValidateRrrEvent event,
    Emitter<FeePaymentState> emit,
  ) async {
    emit(FeePaymentValidating());
    final result = await validateRrrUseCase(event.rrrNumber);
    result.fold(
      (failure) => emit(FeePaymentError(failure.message)),
      (details) => emit(FeePaymentValidated(details)),
    );
  }

  Future<void> _onSubmitPayment(
    SubmitFeePaymentEvent event,
    Emitter<FeePaymentState> emit,
  ) async {
    emit(FeePaymentProcessing());
    final result = await submitFeePaymentUseCase(event.details);
    result.fold(
      (failure) => emit(FeePaymentError(failure.message)),
      (transaction) => emit(FeePaymentSuccess(transaction)),
    );
  }

  void _onReset(ResetFeePaymentEvent event, Emitter<FeePaymentState> emit) {
    emit(FeePaymentInitial());
  }
}
