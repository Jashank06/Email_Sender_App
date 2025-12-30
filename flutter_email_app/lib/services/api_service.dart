import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚙️ PRODUCTION CONFIGURATION
  // Backend running on Hostinger VPS
  static const String baseUrl = 'http://148.135.136.17:3002';
  
  // 📝 For different environments:
  // - Development (Chrome/macOS): http://localhost:3000
  // - Android Emulator: http://10.0.2.2:3000
  // - iOS Simulator: http://localhost:3000
  // - Physical Device (Same WiFi): http://YOUR_MAC_IP:3000
  // - Production APK: https://yourdomain.com (Your Hostinger URL)
  
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
    required String sheetId,
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
