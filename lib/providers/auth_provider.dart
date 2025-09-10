import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:developer' as dev;

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _email;
  String? _userId;
  String? _userType;
  bool _isLoading = false;
  String? _error;

  // Getters
  String? get token => _token;
  String? get email => _email;
  String? get userId => _userId;
  String? get userType => _userType;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated {
    final result = _token != null && _token!.isNotEmpty;
    dev.log(
        'isAuthenticated getter called - token exists: ${_token != null}, result: $result');
    return result;
  }

  // Initialize auth state from SharedPreferences
  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('token');

      if (savedToken != null && savedToken.isNotEmpty) {
        await _setToken(savedToken);
      }
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
      dev.log('Auth initialization error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Set token and decode user info
  Future<void> _setToken(String token) async {
    try {
      if (JwtDecoder.isExpired(token)) {
        dev.log('Token is expired, logging out');
        await logout();
        return;
      }

      final decodedToken = JwtDecoder.decode(token);
      _token = token;
      _email = decodedToken['email'] as String?;
      _userId = decodedToken['_id'] as String?;
      _userType = decodedToken['userType'] as String?;

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Invalid token: $e');
      dev.log('Token decode error: $e');
    }
  }

  // Login method
  Future<bool> login(String token, String userType) async {
    _setLoading(true);
    try {
      // Check if token is expired first
      if (JwtDecoder.isExpired(token)) {
        _setError('Token has expired');
        _setLoading(false);
        return false;
      }

      // Decode token to get user info
      final decodedToken = JwtDecoder.decode(token);
      _token = token;
      _email = decodedToken['email'] as String?;
      _userId = decodedToken['_id'] as String?;
      _userType = userType; // Use the userType from API response

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      _clearError();

      // Set loading to false and notify listeners
      _setLoading(false);
      dev.log('Login successful, calling notifyListeners()');
      dev.log(
          'Current auth state - token: ${_token != null ? "exists" : "null"}, email: $_email, userType: $_userType');
      notifyListeners();
      dev.log('notifyListeners() called successfully');

      return true;
    } catch (e) {
      _setError('Login failed: $e');
      _setLoading(false);
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');

      _token = null;
      _email = null;
      _userId = null;
      _userType = null;
      _clearError();

      notifyListeners();
    } catch (e) {
      _setError('Logout failed: $e');
      dev.log('Logout error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Check if token is expired
  bool isTokenExpired() {
    if (_token == null) return true;
    return JwtDecoder.isExpired(_token!);
  }

  // Refresh token (placeholder for future implementation)
  Future<bool> refreshToken() async {
    // TODO: Implement token refresh logic
    return false;
  }

  // Helper methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Clear error manually
  void clearError() {
    _clearError();
    notifyListeners();
  }
}
