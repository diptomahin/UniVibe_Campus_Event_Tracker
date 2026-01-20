import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<AppUser> signUpWithEmail(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign up failed');
      }

      // Create user profile
      await _supabase.from(DatabaseTables.users).insert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'user_role': 'student',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      return AppUser(
        id: response.user!.id,
        email: email,
        fullName: fullName,
        userRole: 'student',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Sign up error: $e');
    }
  }

  Future<AppUser> loginWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed');
      }

      return getUserData(response.user!.id);
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<AppUser> getUserData(String userId) async {
    try {
      final response = await _supabase
          .from(DatabaseTables.users)
          .select()
          .eq('id', userId)
          .single();

      return AppUser.fromJson(response);
    } catch (e) {
      throw Exception('Get user data error: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Logout error: $e');
    }
  }

  Future<AppUser> updateProfile(String fullName, String? bio) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('No authenticated user');
      }

      await _supabase
          .from(DatabaseTables.users)
          .update({
            'full_name': fullName,
            'bio': bio,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      return getUserData(userId);
    } catch (e) {
      throw Exception('Update profile error: $e');
    }
  }

  Future<void> updateNotificationSettings(
    bool enabled,
    String preferredTime,
    String timezone,
  ) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('No authenticated user');
      }

      await _supabase
          .from(DatabaseTables.users)
          .update({
            'notifications_enabled': enabled,
            'preferred_reminder_time': preferredTime,
            'timezone': timezone,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw Exception('Update notification settings error: $e');
    }
  }
}
