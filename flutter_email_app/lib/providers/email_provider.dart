import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/email_config.dart';

class EmailProvider extends ChangeNotifier {
  EmailConfig? _emailConfig;
  String _sheetId = '';
  String _subject = '';
  String _template = '';
  String _senderName = '';
  List<Map<String, String>> _recipients = [];
  bool _useManualRecipients = false;
  
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  Map<String, dynamic>? _sendResult;
  
  // Getters
  EmailConfig? get emailConfig => _emailConfig;
  String get sheetId => _sheetId;
  String get subject => _subject;
  String get template => _template;
  String get senderName => _senderName;
  List<Map<String, String>> get recipients => _recipients;
  bool get useManualRecipients => _useManualRecipients;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  Map<String, dynamic>? get sendResult => _sendResult;
  
  final ApiService _apiService = ApiService();
  
  // Set email configuration
  void setEmailConfig(EmailConfig config) {
    _emailConfig = config;
    notifyListeners();
  }
  
  // Set sheet ID
  void setSheetId(String id) {
    _sheetId = id;
    notifyListeners();
  }
  
  // Set email subject
  void setSubject(String subj) {
    _subject = subj;
    notifyListeners();
  }
  
  // Set email template
  void setTemplate(String tmpl) {
    _template = tmpl;
    notifyListeners();
  }
  
  // Set sender name
  void setSenderName(String name) {
    _senderName = name;
    notifyListeners();
  }

  // Set recipients
  void setRecipients(List<Map<String, String>> list) {
    _recipients = list;
    notifyListeners();
  }

  // Set use manual recipients
  void setUseManualRecipients(bool use) {
    _useManualRecipients = use;
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Test email configuration
  Future<bool> testEmailConfig(EmailConfig config) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _apiService.testEmail(
        provider: config.provider,
        email: config.email,
        password: config.password,
      );
      
      if (result['success'] == true) {
        _emailConfig = config;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Failed to verify email configuration';
        _isLoading = false;
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
  
  // Test Google Sheets connection
  Future<Map<String, dynamic>?> testSheetConnection(String sheetId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _apiService.testSheet(sheetId: sheetId);
      
      if (result['success'] == true) {
        _sheetId = sheetId;
        _isLoading = false;
        notifyListeners();
        return result;
      } else {
        _error = result['message'] ?? 'Failed to connect to Google Sheets';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  // Send bulk emails
  Future<bool> sendBulkEmails() async {
    if (_emailConfig == null || _subject.isEmpty || _template.isEmpty || 
        (!_useManualRecipients && _sheetId.isEmpty) || 
        (_useManualRecipients && _recipients.isEmpty)) {
      _error = 'Please configure all required fields';
      notifyListeners();
      return false;
    }
    
    _isSending = true;
    _error = null;
    _sendResult = null;
    notifyListeners();
    
    try {
      final result = await _apiService.sendBulkEmails(
        provider: _emailConfig!.provider,
        email: _emailConfig!.email,
        password: _emailConfig!.password,
        sheetId: _useManualRecipients ? null : _sheetId,
        recipients: _useManualRecipients ? _recipients : null,
        subject: _subject,
        template: _template,
        senderName: _senderName,
      );
      
      if (result['success'] == true) {
        _sendResult = result;
        _isSending = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Failed to send emails';
        _isSending = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isSending = false;
      notifyListeners();
      return false;
    }
  }
  
  // Reset all data
  void reset() {
    _emailConfig = null;
    _sheetId = '';
    _subject = '';
    _template = '';
    _senderName = '';
    _recipients = [];
    _useManualRecipients = false;
    _error = null;
    _sendResult = null;
    notifyListeners();
  }
}
