import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/fund_wallet_usecase.dart';
import 'fund_wallet_event.dart';
import 'fund_wallet_state.dart';

class FundWalletBloc extends Bloc<FundWalletEvent, FundWalletState> {
  final FundWalletUseCase fundWalletUseCase;

  FundWalletBloc({required this.fundWalletUseCase}) : super(FundWalletInitial()) {
    on<SubmitFundWalletEvent>(_onSubmit);
    on<ResetFundWalletEvent>((event, emit) => emit(FundWalletInitial()));
  }

  Future<void> _onSubmit(
    SubmitFundWalletEvent event,
    Emitter<FundWalletState> emit,
  ) async {
    emit(FundWalletProcessing());
    final result = await fundWalletUseCase(FundWalletParams(
      amount: event.amount,
      paymentMethod: event.paymentMethod,
    ));

    result.fold(
      (failure) => emit(FundWalletError(failure.message)),
      (transaction) => emit(FundWalletSuccess(transaction)),
    );
  }
}
