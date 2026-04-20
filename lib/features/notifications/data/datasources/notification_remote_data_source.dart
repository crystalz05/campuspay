import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import '../../../../core/error/exception.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final SupabaseClient client;

  NotificationRemoteDataSourceImpl(this.client);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw const AppAuthException('User not authenticated');
    }

    try {
      final response = await client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e, stack) {
      log('PostgrestException fetching notifications',
          name: 'NotificationRemoteDataSource', error: e, stackTrace: stack);
      throw ServerException(e.message);
    } catch (e, stack) {
      log('Unexpected error fetching notifications',
          name: 'NotificationRemoteDataSource', error: e, stackTrace: stack);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw const AppAuthException('User not authenticated');
    }

    try {
      await client
          .from('notifications')
          .update({'read': true})
          .eq('id', notificationId)
          .eq('user_id', user.id); // Guard for RLS and safety
    } on PostgrestException catch (e, stack) {
      log('PostgrestException marking notification as read',
          name: 'NotificationRemoteDataSource', error: e, stackTrace: stack);
      throw ServerException(e.message);
    } catch (e, stack) {
      log('Unexpected error marking notification as read',
          name: 'NotificationRemoteDataSource', error: e, stackTrace: stack);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw const AppAuthException('User not authenticated');
    }

    try {
      await client
          .from('notifications')
          .update({'read': true})
          .eq('user_id', user.id)
          .eq('read', false);
    } on PostgrestException catch (e, stack) {
      log('PostgrestException marking all notifications as read',
          name: 'NotificationRemoteDataSource', error: e, stackTrace: stack);
      throw ServerException(e.message);
    } catch (e, stack) {
      log('Unexpected error marking all notifications as read',
          name: 'NotificationRemoteDataSource', error: e, stackTrace: stack);
      throw ServerException(e.toString());
    }
  }
}
