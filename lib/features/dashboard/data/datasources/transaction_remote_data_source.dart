import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';
import '../../../../core/error/exception.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getRecentTransactions();
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final SupabaseClient client;

  TransactionRemoteDataSourceImpl(this.client);

  @override
  Future<List<TransactionModel>> getRecentTransactions() async {
    final user = client.auth.currentUser;
    if (user == null) {
      log('getRecentTransactions called but user is null', name: 'TransactionRemoteDataSource');
      throw const AppAuthException('User not authenticated');
    }

    try {
      final response = await client
          .from('transactions')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(5);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => TransactionModel.fromJson(json as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e, stack) {
      log('Supabase PostgrestException fetching transactions', name: 'TransactionRemoteDataSource', error: e, stackTrace: stack);
      throw ServerException(e.message);
    } catch (e, stack) {
      log('Unexpected error fetching transactions', name: 'TransactionRemoteDataSource', error: e, stackTrace: stack);
      throw ServerException(e.toString());
    }
  }
}
