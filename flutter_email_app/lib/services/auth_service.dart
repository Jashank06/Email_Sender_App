import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../config/environment.dart';

class AuthService {
  // ⚙️ DYNAMIC CONFIGURATION
  // Automatically switches between development and production
  static String get baseUrl => Environment.baseUrl;

  // Signup - Send OTP
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String phone,
    required String dateOfBirth,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'dateOfBirth': dateOfBirth,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Verify OTP for Signup
  Future<Map<String, dynamic>> verifySignupOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Login - Send OTP
  Future<Map<String, dynamic>> login({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Verify OTP for Login
  Future<Map<String, dynamic>> verifyLoginOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/verify-login-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get User Profile
  Future<Map<String, dynamic>> getProfile(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/profile/$email'),
        headers: {'Content-Type': 'application/json'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Update User Profile
  Future<Map<String, dynamic>> updateProfile({
    required String email,
    required String name,
    required String phone,
    required String dateOfBirth,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/auth/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'name': name,
          'phone': phone,
          'dateOfBirth': dateOfBirth,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
