import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/purchase_airtime_usecase.dart';
import 'airtime_event.dart';
import 'airtime_state.dart';

class AirtimeBloc extends Bloc<AirtimeEvent, AirtimeState> {
  final PurchaseAirtimeUseCase purchaseAirtimeUseCase;

  AirtimeBloc({required this.purchaseAirtimeUseCase}) : super(AirtimeInitial()) {
    on<PurchaseAirtimeEvent>(_onPurchase);
  }

  Future<void> _onPurchase(
    PurchaseAirtimeEvent event,
    Emitter<AirtimeState> emit,
  ) async {
    emit(AirtimePurchasing());
    final result = await purchaseAirtimeUseCase(
      network: event.network,
      phoneNumber: event.phoneNumber,
      amount: event.amount,
    );
    result.fold(
      (failure) => emit(AirtimeError(failure.message)),
      (transaction) => emit(AirtimePurchaseSuccess(
        transaction: transaction,
        network: event.network,
        phoneNumber: event.phoneNumber,
        amount: event.amount,
      )),
    );
  }
}
