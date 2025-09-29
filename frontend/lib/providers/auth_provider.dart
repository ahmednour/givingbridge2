import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/user.dart';

enum AuthState { loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.loading;
  User? _user;
  String? _errorMessage;

  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated =>
      _state == AuthState.authenticated && _user != null;
  bool get isLoading => _state == AuthState.loading;
  bool get hasError => _state == AuthState.error;

  String? get userRole => _user?.role;

  // Initialize auth state by checking for existing token
  Future<void> initialize() async {
    _setState(AuthState.loading);

    try {
      if (await ApiService.hasToken()) {
        final response = await ApiService.getProfile();
        if (response.success && response.data != null) {
          _user = response.data;
          _setState(AuthState.authenticated);
        } else {
          await ApiService.logout();
          _setState(AuthState.unauthenticated);
        }
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Failed to initialize auth: ${e.toString()}');
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setState(AuthState.loading);

    try {
      final response = await ApiService.login(email, password);

      if (response.success && response.data != null) {
        _user = response.data!.user;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.error ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('Login error: ${e.toString()}');
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? location,
  }) async {
    _setState(AuthState.loading);

    try {
      final response = await ApiService.register(
        name: name,
        email: email,
        password: password,
        role: role,
        phone: phone,
        location: location,
      );

      if (response.success && response.data != null) {
        _user = response.data!.user;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.error ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Registration error: ${e.toString()}');
      return false;
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? location,
    String? avatarUrl,
  }) async {
    if (_user == null) return false;

    try {
      final response = await ApiService.updateProfile(
        userId: _user!.id.toString(),
        name: name,
        phone: phone,
        location: location,
        avatarUrl: avatarUrl,
      );

      if (response.success && response.data != null) {
        _user = response.data;
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to update profile');
        return false;
      }
    } catch (e) {
      _setError('Update profile error: ${e.toString()}');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await ApiService.logout();
    _user = null;
    _setState(AuthState.unauthenticated);
  }

  // Clear error
  void clearError() {
    if (_state == AuthState.error) {
      _setState(AuthState.unauthenticated);
    }
  }

  // Private helper methods
  void _setState(AuthState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String error) {
    _state = AuthState.error;
    _errorMessage = error;
    notifyListeners();
  }
}
