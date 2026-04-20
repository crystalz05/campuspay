import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/auth/di/auth_injection.dart';
import 'features/dashboard/di/dashboard_injection.dart';
import 'features/fee_payment/di/fee_payment_injection.dart';
import 'features/fund_wallet/di/fund_wallet_injection.dart';
import 'features/data_bundle/di/data_bundle_injection.dart';
import 'features/airtime/di/airtime_injection.dart';
import 'features/transfer/di/transfer_injection.dart';
import 'features/notifications/di/notifications_injection.dart';
import 'features/history/di/history_injection.dart';
import 'features/settings/di/settings_injection.dart';


final sl = GetIt.instance;

Future<void> init() async {
  // --- External / Core (always first, features depend on these) ---
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Supabase.instance.client);

  // --- Features ---
  initAuthDependencies(sl);
  initDashboardDependencies(sl);
  initFeePaymentDependencies(sl);
  initFundWalletDependencies(sl);
  initDataBundleDependencies(sl);
  initAirtimeDependencies(sl);
  initTransfer();
  initNotificationsDependencies(sl);
  initHistoryDependencies(sl);
  initSettingsDependencies(sl);
}