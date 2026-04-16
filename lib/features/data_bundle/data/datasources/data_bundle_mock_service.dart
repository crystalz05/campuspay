import '../../domain/entities/data_bundle_entity.dart';

/// Simulates a real-world data bundle provider API.
/// Returns realistic Nigerian data plans with 90% success rate on purchase.
class DataBundleMockService {
  static const _simulatedDelay = Duration(milliseconds: 1500);

  static final Map<NetworkProvider, List<Map<String, dynamic>>> _plans = {
    NetworkProvider.mtn: [
      {'id': 'mtn_100mb_1d', 'name': '100MB Daily', 'sizeGb': 0.1, 'price': 100.0, 'validity': '1 day'},
      {'id': 'mtn_500mb_7d', 'name': '500MB Weekly', 'sizeGb': 0.5, 'price': 200.0, 'validity': '7 days'},
      {'id': 'mtn_1gb_7d', 'name': '1GB 7-Day', 'sizeGb': 1.0, 'price': 300.0, 'validity': '7 days'},
      {'id': 'mtn_1gb_30d', 'name': '1GB Monthly', 'sizeGb': 1.0, 'price': 1000.0, 'validity': '30 days'},
      {'id': 'mtn_2gb_30d', 'name': '2GB Monthly', 'sizeGb': 2.0, 'price': 1200.0, 'validity': '30 days'},
      {'id': 'mtn_5gb_30d', 'name': '5GB Monthly', 'sizeGb': 5.0, 'price': 1500.0, 'validity': '30 days'},
      {'id': 'mtn_10gb_30d', 'name': '10GB Monthly', 'sizeGb': 10.0, 'price': 3000.0, 'validity': '30 days'},
      {'id': 'mtn_20gb_30d', 'name': '20GB Monthly', 'sizeGb': 20.0, 'price': 5000.0, 'validity': '30 days'},
    ],
    NetworkProvider.airtel: [
      {'id': 'airt_100mb_1d', 'name': '100MB Daily', 'sizeGb': 0.1, 'price': 100.0, 'validity': '1 day'},
      {'id': 'airt_750mb_7d', 'name': '750MB Weekly', 'sizeGb': 0.75, 'price': 200.0, 'validity': '7 days'},
      {'id': 'airt_1gb_7d', 'name': '1GB 7-Day', 'sizeGb': 1.0, 'price': 300.0, 'validity': '7 days'},
      {'id': 'airt_1_5gb_30d', 'name': '1.5GB Monthly', 'sizeGb': 1.5, 'price': 1000.0, 'validity': '30 days'},
      {'id': 'airt_3gb_30d', 'name': '3GB Monthly', 'sizeGb': 3.0, 'price': 1200.0, 'validity': '30 days'},
      {'id': 'airt_5gb_30d', 'name': '5GB Monthly', 'sizeGb': 5.0, 'price': 1500.0, 'validity': '30 days'},
      {'id': 'airt_12gb_30d', 'name': '12GB Monthly', 'sizeGb': 12.0, 'price': 3000.0, 'validity': '30 days'},
      {'id': 'airt_25gb_30d', 'name': '25GB Monthly', 'sizeGb': 25.0, 'price': 5000.0, 'validity': '30 days'},
    ],
    NetworkProvider.glo: [
      {'id': 'glo_100mb_1d', 'name': '100MB Daily', 'sizeGb': 0.1, 'price': 50.0, 'validity': '1 day'},
      {'id': 'glo_1gb_7d', 'name': '1GB Weekly', 'sizeGb': 1.0, 'price': 200.0, 'validity': '7 days'},
      {'id': 'glo_2gb_14d', 'name': '2GB Biweekly', 'sizeGb': 2.0, 'price': 500.0, 'validity': '14 days'},
      {'id': 'glo_2gb_30d', 'name': '2GB Monthly', 'sizeGb': 2.0, 'price': 1000.0, 'validity': '30 days'},
      {'id': 'glo_5gb_30d', 'name': '5GB Monthly', 'sizeGb': 5.0, 'price': 1500.0, 'validity': '30 days'},
      {'id': 'glo_10gb_30d', 'name': '10GB Monthly', 'sizeGb': 10.0, 'price': 2500.0, 'validity': '30 days'},
      {'id': 'glo_15gb_30d', 'name': '15GB Monthly', 'sizeGb': 15.0, 'price': 4000.0, 'validity': '30 days'},
      {'id': 'glo_30gb_30d', 'name': '30GB Monthly', 'sizeGb': 30.0, 'price': 6000.0, 'validity': '30 days'},
    ],
    NetworkProvider.mobile9: [
      {'id': '9mo_150mb_1d', 'name': '150MB Daily', 'sizeGb': 0.15, 'price': 100.0, 'validity': '1 day'},
      {'id': '9mo_1gb_7d', 'name': '1GB Weekly', 'sizeGb': 1.0, 'price': 300.0, 'validity': '7 days'},
      {'id': '9mo_1_5gb_30d', 'name': '1.5GB Monthly', 'sizeGb': 1.5, 'price': 1000.0, 'validity': '30 days'},
      {'id': '9mo_2gb_30d', 'name': '2GB Monthly', 'sizeGb': 2.0, 'price': 1200.0, 'validity': '30 days'},
      {'id': '9mo_4gb_30d', 'name': '4GB Monthly', 'sizeGb': 4.0, 'price': 1500.0, 'validity': '30 days'},
      {'id': '9mo_10gb_30d', 'name': '10GB Monthly', 'sizeGb': 10.0, 'price': 3000.0, 'validity': '30 days'},
    ],
    NetworkProvider.smile: [
      {'id': 'sml_1gb_7d', 'name': '1GB Weekly', 'sizeGb': 1.0, 'price': 350.0, 'validity': '7 days'},
      {'id': 'sml_5gb_30d', 'name': '5GB Monthly', 'sizeGb': 5.0, 'price': 2000.0, 'validity': '30 days'},
      {'id': 'sml_10gb_30d', 'name': '10GB Monthly', 'sizeGb': 10.0, 'price': 3500.0, 'validity': '30 days'},
      {'id': 'sml_20gb_30d', 'name': '20GB Monthly', 'sizeGb': 20.0, 'price': 6000.0, 'validity': '30 days'},
    ],
    NetworkProvider.swift: [
      {'id': 'swf_5gb_30d', 'name': '5GB Monthly', 'sizeGb': 5.0, 'price': 1800.0, 'validity': '30 days'},
      {'id': 'swf_10gb_30d', 'name': '10GB Monthly', 'sizeGb': 10.0, 'price': 3200.0, 'validity': '30 days'},
      {'id': 'swf_15gb_30d', 'name': '15GB Monthly', 'sizeGb': 15.0, 'price': 4500.0, 'validity': '30 days'},
      {'id': 'swf_30gb_30d', 'name': '30GB Monthly', 'sizeGb': 30.0, 'price': 7500.0, 'validity': '30 days'},
    ],
  };

  List<DataBundleEntity> getBundles(NetworkProvider network) {
    final raw = _plans[network] ?? [];
    return raw
        .map((m) => DataBundleEntity(
              id: m['id'] as String,
              name: m['name'] as String,
              sizeGb: (m['sizeGb'] as num).toDouble(),
              price: (m['price'] as num).toDouble(),
              validity: m['validity'] as String,
              network: network,
            ))
        .toList();
  }

  /// Simulates a mock purchase API call with 90% success rate.
  Future<Map<String, dynamic>> processPurchase({
    required NetworkProvider network,
    required String phoneNumber,
    required DataBundleEntity bundle,
  }) async {
    await Future.delayed(_simulatedDelay);

    // 90% success, 10% failure
    final isSuccess = DateTime.now().millisecondsSinceEpoch % 10 != 0;

    if (!isSuccess) {
      throw Exception('Network timeout. Please try again.');
    }

    return {
      'status': 'success',
      'provider': network.dbValue,
      'phone': phoneNumber,
      'bundle': bundle.name,
      'reference': 'DATA${DateTime.now().millisecondsSinceEpoch}',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
