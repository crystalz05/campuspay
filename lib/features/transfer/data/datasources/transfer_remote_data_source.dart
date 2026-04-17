import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../core/error/exception.dart';
import '../../../../core/utils/hash_util.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class TransferRemoteDataSource {
  Future<UserModel> searchRecipient(String query);
  
  Future<String> processTransfer({
    required String receiverId,
    required double amount,
    String? note,
    required String pin,
  });
}

class TransferRemoteDataSourceImpl implements TransferRemoteDataSource {
  final supabase.SupabaseClient client;

  TransferRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> searchRecipient(String query) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw const AppAuthException('User not authenticated');
      }

      final response = await client
          .from('users')
          .select()
          .or('email.eq.$query,matric_number.eq.$query')
          .neq('id', currentUser.id) // Exclude self
          .maybeSingle();

      if (response == null) {
        throw const ServerException('Recipient not found');
      }

      return UserModel.fromJson(response);
    } catch (e, stack) {
      log('Error during searchRecipient', name: 'TransferRemoteDataSource', error: e, stackTrace: stack);
      if (e is ServerException || e is AppAuthException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> processTransfer({
    required String receiverId,
    required double amount,
    String? note,
    required String pin,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw const AppAuthException('User not authenticated');
      }

      // Verify PIN
      final userResponse = await client
          .from('users')
          .select('transaction_pin')
          .eq('id', currentUser.id)
          .single();

      final storedHashedPin = userResponse['transaction_pin'] as String?;
      final inputHashedPin = HashUtil.hashString(pin);

      if (storedHashedPin != inputHashedPin) {
        throw const ServerException('Invalid transaction PIN');
      }

      // Execute atomic transfer RPC
      final response = await client.rpc('process_transfer', params: {
        'p_sender_id': currentUser.id,
        'p_receiver_id': receiverId,
        'p_amount': amount,
        'p_note': note,
      });

      return response as String;
    } catch (e, stack) {
      log('Error during processTransfer', name: 'TransferRemoteDataSource', error: e, stackTrace: stack);
      if (e is ServerException || e is AppAuthException) rethrow;
      
      // Supabase RPC throws PostgrestException if raise exception occurs
      if (e is supabase.PostgrestException) {
        throw ServerException(e.message);
      }
      
      throw ServerException('Transfer failed: ${e.toString()}');
    }
  }
}
