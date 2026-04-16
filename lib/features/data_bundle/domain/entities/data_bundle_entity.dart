import 'package:equatable/equatable.dart';

/// Mirrors the Supabase network_provider enum
enum NetworkProvider {
  mtn('MTN NG', 'MTN', 'assets/networks/mtn.png'),
  airtel('AIRTEL NG', 'Airtel', 'assets/networks/airtel.png'),
  glo('GLO NG', 'Glo', 'assets/networks/glo.png'),
  mobile9('9MOBILE NG', '9Mobile', 'assets/networks/9mobile.png'),
  smile('SMILE NG', 'Smile', 'assets/networks/smile.png'),
  swift('SWIFT NG', 'Swift', 'assets/networks/swift.png');

  final String dbValue;
  final String displayName;
  final String assetPath;

  const NetworkProvider(this.dbValue, this.displayName, this.assetPath);

  static NetworkProvider fromDbValue(String value) {
    return NetworkProvider.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => NetworkProvider.mtn,
    );
  }
}

class DataBundleEntity extends Equatable {
  final String id;
  final String name;
  final double sizeGb;
  final double price;
  final String validity;
  final NetworkProvider network;

  const DataBundleEntity({
    required this.id,
    required this.name,
    required this.sizeGb,
    required this.price,
    required this.validity,
    required this.network,
  });

  @override
  List<Object?> get props => [id, name, sizeGb, price, validity, network];
}
