import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/campaign_model.dart';
import '../models/email_event_model.dart';
import '../services/tracking_service.dart';
import '../config/environment.dart';

class UserStats {
  final int totalCampaigns;
  final int totalEmailsSent;
  final double averageSuccessRate;

  UserStats({
    required this.totalCampaigns,
    required this.totalEmailsSent,
    required this.averageSuccessRate,
  });
}

class TrackingProvider with ChangeNotifier {
  final TrackingService _trackingService = TrackingService();
  
  // Campaigns list
  List<Campaign> _campaigns = [];
  bool _isLoadingCampaigns = false;
  String? _campaignsError;

  // Selected campaign details
  CampaignDetails? _selectedCampaignDetails;
  List<EmailEvent> _campaignEvents = [];
  Map<String, dynamic>? _campaignStats;
  bool _isLoadingDetails = false;
  String? _detailsError;

  // Real-time progress
  EmailProgress? _currentProgress;
  bool _isSending = false;

  // WebSocket
  IO.Socket? _socket;
  String? _currentUserId;

  // Getters
  String? get currentUserId => _currentUserId;
  List<Campaign> get campaigns => _campaigns;
  bool get isLoadingCampaigns => _isLoadingCampaigns;
  String? get campaignsError => _campaignsError;

  CampaignDetails? get selectedCampaignDetails => _selectedCampaignDetails;
  List<EmailEvent> get campaignEvents => _campaignEvents;
  Map<String, dynamic>? get campaignStats => _campaignStats;
  bool get isLoadingDetails => _isLoadingDetails;
  String? get detailsError => _detailsError;

  EmailProgress? get currentProgress => _currentProgress;
  bool get isSending => _isSending;

  UserStats get userStats {
    if (_campaigns.isEmpty) {
      return UserStats(totalCampaigns: 0, totalEmailsSent: 0, averageSuccessRate: 0);
    }

    int totalSent = 0;
    int totalDelivered = 0;
    for (var campaign in _campaigns) {
      totalSent += campaign.sentCount;
      totalDelivered += campaign.deliveredCount;
    }

    double successRate = totalSent > 0 ? (totalDelivered / totalSent) * 100 : 0;

    return UserStats(
      totalCampaigns: _campaigns.length,
      totalEmailsSent: totalSent,
      averageSuccessRate: successRate,
    );
  }

  // Set current user ID
  void setUserId(String? userId) {
    _currentUserId = userId;
    if (userId != null) {
      loadCampaigns();
    } else {
      _campaigns = [];
      _selectedCampaignDetails = null;
      _campaignEvents = [];
      _campaignStats = null;
      notifyListeners();
    }
  }

  // Initialize WebSocket connection
  void initializeWebSocket() {
    if (_socket != null && _socket!.connected) {
      return;
    }

    _socket = IO.io(
      Environment.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.on('connect', (_) {
      if (kDebugMode) {
        print('📱 WebSocket connected');
      }
    });

    _socket!.on('disconnect', (_) {
      if (kDebugMode) {
        print('📱 WebSocket disconnected');
      }
    });

    _socket!.on('email-progress', (data) {
      _currentProgress = EmailProgress.fromJson(data);
      _isSending = true;
      notifyListeners();
    });

    _socket!.on('email-complete', (data) {
      _isSending = false;
      _currentProgress = null;
      notifyListeners();
      
      // Refresh campaigns list
      loadCampaigns();
    });

    _socket!.on('campaign-update', (data) {
      final campaignId = data['campaignId'];
      
      // Update campaign in the list if it exists
      final index = _campaigns.indexWhere((c) => c.id == campaignId);
      if (index != -1) {
        if (_selectedCampaignDetails != null && _selectedCampaignDetails!.campaign.id == campaignId) {
          loadCampaignDetails(campaignId, silent: true);
        } else {
          loadCampaigns(silent: true);
        }
      }
    });

    _socket!.on('email-open', (data) {
      // Potentially show a notification or update UI
      if (kDebugMode) {
        print('📧 Email opened: ${data['recipientEmail']}');
      }
    });

    _socket!.on('email-click', (data) {
      // Potentially show a notification or update UI
      if (kDebugMode) {
        print('🖱️ Link clicked: ${data['recipientEmail']}');
      }
    });
  }

  // Disconnect WebSocket
  void disconnectWebSocket() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // Subscribe to campaign updates
  void subscribeToCampaign(String campaignId) {
    _socket?.emit('subscribe-campaign', campaignId);
  }

  // Unsubscribe from campaign updates
  void unsubscribeFromCampaign(String campaignId) {
    _socket?.emit('unsubscribe-campaign', campaignId);
  }

  // Load all campaigns
  Future<void> loadCampaigns({bool silent = false}) async {
    if (_currentUserId == null) return;

    if (!silent) {
      _isLoadingCampaigns = true;
      _campaignsError = null;
      notifyListeners();
    }

    try {
      _campaigns = await _trackingService.getCampaigns(_currentUserId!);
      _isLoadingCampaigns = false;
      notifyListeners();
    } catch (e) {
      _campaignsError = e.toString();
      _isLoadingCampaigns = false;
      notifyListeners();
    }
  }

  // Load campaign details
  Future<void> loadCampaignDetails(String campaignId, {bool silent = false}) async {
    if (_currentUserId == null) return;

    if (!silent) {
      _isLoadingDetails = true;
      _detailsError = null;
      notifyListeners();
    }

    try {
      _selectedCampaignDetails = await _trackingService.getCampaignDetails(campaignId, _currentUserId!);
      _campaignEvents = await _trackingService.getCampaignEvents(campaignId, _currentUserId!);
      _campaignStats = await _trackingService.getCampaignStats(campaignId, _currentUserId!);
      _isLoadingDetails = false;
      notifyListeners();
    } catch (e) {
      _detailsError = e.toString();
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  // Load campaign events with filter
  Future<void> loadCampaignEvents(String campaignId, {String? status}) async {
    if (_currentUserId == null) return;

    try {
      _campaignEvents = await _trackingService.getCampaignEvents(
        campaignId,
        _currentUserId!,
        status: status,
      );
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading events: $e');
      }
    }
  }

  // Clear selected campaign
  void clearSelectedCampaign() {
    _selectedCampaignDetails = null;
    _campaignEvents = [];
    _campaignStats = null;
    _detailsError = null;
    notifyListeners();
  }

  // Reset progress
  void resetProgress() {
    _currentProgress = null;
    _isSending = false;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnectWebSocket();
    super.dispose();
  }
}
