import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  final AuthService _authService = AuthService();

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize - Check if user is logged in
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        _currentUser = User.fromJson(userMap);
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Signup - Send OTP
  Future<bool> signup({
    required String name,
    required String email,
    required String phone,
    required String dateOfBirth,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.signup(
        name: name,
        email: email,
        phone: phone,
        dateOfBirth: dateOfBirth,
      );

      _isLoading = false;
      
      if (result['success'] == true) {
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Failed to send OTP';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Verify Signup OTP
  Future<bool> verifySignupOtp({
    required String email,
    required String otp,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.verifySignupOtp(
        email: email,
        otp: otp,
      );

      _isLoading = false;

      if (result['success'] == true && result['user'] != null) {
        _currentUser = User.fromJson(result['user']);
        _isAuthenticated = true;
        
        // Save user to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(_currentUser!.toJson()));
        
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Failed to verify OTP';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login - Send OTP
  Future<bool> login({
    required String email,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(email: email);

      _isLoading = false;

      if (result['success'] == true) {
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Failed to send OTP';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Verify Login OTP
  Future<bool> verifyLoginOtp({
    required String email,
    required String otp,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.verifyLoginOtp(
        email: email,
        otp: otp,
      );

      _isLoading = false;

      if (result['success'] == true && result['user'] != null) {
        _currentUser = User.fromJson(result['user']);
        _isAuthenticated = true;
        
        // Save user to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(_currentUser!.toJson()));
        
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Failed to verify OTP';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update Profile
  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String dateOfBirth,
    String? savedEmail,
    String? savedPassword,
    String? savedProvider,
  }) async {
    if (_currentUser == null) {
      _error = 'No user logged in';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.updateProfile(
        email: _currentUser!.email,
        name: name,
        phone: phone,
        dateOfBirth: dateOfBirth,
        savedEmail: savedEmail,
        savedPassword: savedPassword,
        savedProvider: savedProvider,
      );

      _isLoading = false;

      if (result['success'] == true && result['user'] != null) {
        _currentUser = User.fromJson(result['user']);
        
        // Update local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(_currentUser!.toJson()));
        
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Failed to update profile';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    _error = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    
    notifyListeners();
  }
}
