import 'dart:convert';
import 'dart:io';
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
  
  // Send bulk emails with attachment support
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
    List<File>? attachments,
    String? userId,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/send-emails'),
      );

      // Add text fields
      request.fields['provider'] = provider;
      request.fields['email'] = email;
      request.fields['password'] = password;
      if (sheetId != null) request.fields['sheetId'] = sheetId;
      if (recipients != null) request.fields['recipients'] = jsonEncode(recipients);
      request.fields['subject'] = subject;
      request.fields['template'] = template;
      request.fields['senderName'] = senderName ?? '';
      request.fields['delayMs'] = delayMs.toString();
      if (userId != null) request.fields['userId'] = userId;

      // Add attachments if any
      if (attachments != null && attachments.isNotEmpty) {
        for (var file in attachments) {
          var stream = http.ByteStream(file.openRead());
          var length = await file.length();
          var multipartFile = http.MultipartFile(
            'attachments',
            stream,
            length,
            filename: file.path.split('/').last,
          );
          request.files.add(multipartFile);
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
