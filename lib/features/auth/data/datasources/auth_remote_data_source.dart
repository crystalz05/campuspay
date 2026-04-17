import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../core/utils/hash_util.dart';
import '../models/user_model.dart';
import '../../../../core/error/exception.dart' as app;

abstract class AuthRemoteDataSource {
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<UserModel> completeProfile({
    required String matricNumber,
    required String institution,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserModel?> getCurrentUser();

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({required String newPassword});

  Future<void> setTransactionPin({required String pin});

  Future<void> resendVerificationEmail({required String email});

  Stream<supabase.User?> get onAuthStateChanged;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final supabase.SupabaseClient client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      final user = response.user;
      if (user == null) {
        throw const app.AppAuthException('Registration failed: User not created');
      }

      // Try to fetch the public user record (synced by Supabase trigger)
      try {
        final publicUserResponse = await client
            .from('users')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (publicUserResponse != null) {
          return UserModel.fromJson(publicUserResponse);
        }
      } catch (e, stack) {
        log('Warning: Failed to fetch public user record after registration', name: 'AuthRemoteDataSource', error: e, stackTrace: stack);
        // Fallback or ignore if RLS prevents selection before verification
      }

      // Return a partial model if DB record isn't accessible yet
      return UserModel(
        id: user.id,
        email: email,
        fullName: fullName,
        walletBalance: 0.0,
        isPinSet: false,
        createdAt: DateTime.now(),
      );
    } on supabase.AuthException catch (e, stack) {
      log('Supabase AuthException during register', name: 'AuthRemoteDataSource', error: e, stackTrace: stack);
      throw app.ServerException(e.message);
    } catch (e, stack) {
      log('Unexpected error during register', name: 'AuthRemoteDataSource', error: e, stackTrace: stack);
      throw app.ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> completeProfile({
    required String matricNumber,
    required String institution,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw const app.AppAuthException('Not authenticated');

    try {
      final publicUserResponse = await client.from('users').update({
        'matric_number': matricNumber,
        'institution': institution,
      }).eq('id', user.id).select().single();

      return UserModel.fromJson(publicUserResponse);
    } catch (e, stack) {
      log('Error during completeProfile', name: 'AuthRemoteDataSource', error: e, stackTrace: stack);
      throw app.ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const app.AppAuthException('Login failed: User not found');
      }

      final publicUserResponse = await client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(publicUserResponse);
    } on supabase.AuthException catch (e, stack) {
      log('Supabase AuthException during login', name: 'AuthRemoteDataSource', error: e, stackTrace: stack);
      throw app.ServerException(e.message);
    } catch (e, stack) {
      log('Unexpected error during login', name: 'AuthRemoteDataSource', error: e, stackTrace: stack);
      throw app.ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final session = client.auth.currentSession;
    if (session == null) return null;

    try {
      final publicUserResponse = await client
          .from('users')
          .select()
          .eq('id', session.user.id)
          .maybeSingle();

      if (publicUserResponse == null) return null;
      return UserModel.fromJson(publicUserResponse);
    } catch (e, stack) {
      log('Error fetching current user profile', name: 'AuthRemoteDataSource', error: e, stackTrace: stack);
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await client.auth.signOut();
    } catch (e, stack) {
      log('Error during logout', name: 'AuthRemoteDataSource', error: e, stackTrace: stack);
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      log('Requesting password reset for email: $email', name: 'AuthRemoteDataSource');
      await client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'campuspay://reset-password',
      );
      log('Password reset requested successfully', name: 'AuthRemoteDataSource');
    } on supabase.AuthException catch (e, stack) {
      log('Supabase AuthException during forgotPassword', name: 'AuthRemoteDataSource', error: e, stackTrace: stack);
      throw app.ServerException(e.message);
    } catch (e, stack) {
      log('Unexpected error during forgotPassword', name: 'AuthRemoteDataSource', error: e, stackTrace: stack);
      throw app.ServerException(e.toString());
    }
  }

  @override
  Future<void> resetPassword({required String newPassword}) async {
    try {
      await client.auth.updateUser(
        supabase.UserAttributes(password: newPassword),
      );
      log('Password reset successfully updated', name: 'AuthRemoteDataSource');
    } on supabase.AuthException catch (e, stack) {
      log('Supabase AuthException during resetPassword update', name: 'AuthRemoteDataSource', error: e, stackTrace: stack);
      throw app.ServerException(e.message);
    } catch (e, stack) {
      log('Unexpected error during resetPassword update', name: 'AuthRemoteDataSource', error: e, stackTrace: stack);
      throw app.ServerException(e.toString());
    }
  }

  @override
  Future<void> setTransactionPin({required String pin}) async {
    final user = client.auth.currentUser;
    if (user == null) {
      log('setTransactionPin called but user is null', name: 'AuthRemoteDataSource');
      throw const app.AppAuthException('Not authenticated');
    }

    try {
      // Hash the PIN before saving
      final hashedPin = HashUtil.hashString(pin);
      
      await client.from('users').update({
        'transaction_pin': hashedPin,
      }).eq('id', user.id);
    } catch (e, stack) {
      log('Error updating transaction PIN', name: 'AuthRemoteDataSource', error: e, stackTrace: stack);
      throw app.ServerException(e.toString());
    }
  }

  @override
  Future<void> resendVerificationEmail({required String email}) async {
    try {
      log('Requesting resend verification for email: $email', name: 'AuthRemoteDataSource');
      await client.auth.resend(
        type: supabase.OtpType.signup,
        email: email.trim(),
        emailRedirectTo: 'campuspay://login-callback',
      );
      log('Resend verification requested successfully', name: 'AuthRemoteDataSource');
    } on supabase.AuthException catch (e, stack) {
      log('Supabase AuthException during resendVerificationEmail', name: 'AuthRemoteDataSource', error: e, stackTrace: stack);
      throw app.ServerException(e.message);
    } catch (e, stack) {
      log('Unexpected error during resendVerificationEmail', name: 'AuthRemoteDataSource', error: e, stackTrace: stack);
      throw app.ServerException(e.toString());
    }
  }

  @override
  Stream<supabase.User?> get onAuthStateChanged => client.auth.onAuthStateChange.map((event) => event.session?.user);
}
