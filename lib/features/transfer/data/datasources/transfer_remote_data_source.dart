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

      final trimmedQuery = query.trim().toLowerCase();

      final response = await client
          .from('users')
          .select()
          .or('email.ilike.$trimmedQuery,matric_number.ilike.$trimmedQuery')
          .neq('id', currentUser.id)
          .maybeSingle();

      log('searchRecipient query response: $response', name: 'TransferRemoteDataSource');

      // DEBUG: fetch all emails visible to this user to diagnose RLS / query issues
      try {
        final allUsers = await client.from('users').select('email, matric_number');
        final emails = (allUsers as List).map((u) => '${u['email']} | ${u['matric_number']}').toList();
        log('[DEBUG] All visible users (${emails.length}): ${emails.join(', ')}', name: 'TransferRemoteDataSource');
      } catch (debugErr) {
        log('[DEBUG] Could not fetch all users: $debugErr', name: 'TransferRemoteDataSource');
      }

      if (response == null) {
        throw const ServerException('No user found with that email or matric number.');
      }

      return UserModel.fromJson(response);
    } on supabase.PostgrestException catch (e, stack) {
      log('PostgrestException in searchRecipient: ${e.message} | code: ${e.code} | details: ${e.details}',
          name: 'TransferRemoteDataSource', error: e, stackTrace: stack);
      throw ServerException('Search failed: ${e.message}');
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

      if (response == null) {
        throw const ServerException('Transfer returned no transaction ID');
      }

      return response.toString();
    } catch (e, stack) {
      log('Error during processTransfer', name: 'TransferRemoteDataSource', error: e, stackTrace: stack);
      if (e is ServerException || e is AppAuthException) rethrow;

      // Supabase RPC throws PostgrestException on raise exception
      if (e is supabase.PostgrestException) {
        final msg = e.message.toLowerCase();
        if (msg.contains('insufficient balance')) {
          throw const ServerException('Insufficient wallet balance to complete this transfer.');
        }
        throw ServerException(e.message);
      }

      throw ServerException('Transfer failed: ${e.toString()}');
    }
  }
}
