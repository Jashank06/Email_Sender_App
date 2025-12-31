import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment.dart';

class ApiService {
  // ⚙️ DYNAMIC CONFIGURATION
  // Automatically switches between development and production
  static String get baseUrl => Environment.baseUrl;
  
  // Test email configuration
  Future<Map<String, dynamic>> testEmail({
    required String provider,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/test-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider': provider,
          'email': email,
          'password': password,
        }),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
  
  // Test Google Sheets connection
  Future<Map<String, dynamic>> testSheet({
    required String sheetId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/test-sheet'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sheetId': sheetId,
        }),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
  
  // Send bulk emails
  Future<Map<String, dynamic>> sendBulkEmails({
    required String provider,
    required String email,
    required String password,
    String? sheetId,
    List<Map<String, String>>? recipients,
    required String subject,
    required String template,
    String? senderName,
    int delayMs = 3000,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/send-emails'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider': provider,
          'email': email,
          'password': password,
          'sheetId': sheetId,
          'recipients': recipients,
          'subject': subject,
          'template': template,
          'senderName': senderName ?? '',
          'delayMs': delayMs,
        }),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
