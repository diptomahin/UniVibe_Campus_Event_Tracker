import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AppUser? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isStaff => _currentUser?.isStaff ?? false;

  AuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _loadUserData(session.user.id);
      } else {
        _currentUser = null;
        _isAuthenticated = false;
        notifyListeners();
      }
    });
  }

  Future<void> signUpWithEmail(
    String email,
    String password,
    String fullName,
  ) async {
    _setLoading(true);
    try {
      final response = await _authService.signUpWithEmail(
        email,
        password,
        fullName,
      );
      _currentUser = response;
      _isAuthenticated = true;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      final response = await _authService.loginWithEmail(email, password);
      _currentUser = response;
      _isAuthenticated = true;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loginAsGuest() async {
    _setLoading(true);
    try {
      // Guest login creates a temporary session
      _currentUser = AppUser(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        email: 'guest@univibe.local',
        fullName: 'Guest User',
        userRole: 'student',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _isAuthenticated = false; // Guest is not fully authenticated
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _currentUser = null;
      _isAuthenticated = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile(String fullName, String? bio) async {
    _setLoading(true);
    try {
      final updated = await _authService.updateProfile(fullName, bio);
      _currentUser = updated;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserData(String userId) async {
    try {
      final user = await _authService.getUserData(userId);
      _currentUser = user;
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // Public method to refresh current user data from database
  Future<void> refreshCurrentUser() async {
    if (_currentUser != null) {
      await _loadUserData(_currentUser!.id);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
