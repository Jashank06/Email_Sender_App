import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/campaign_model.dart';
import '../models/email_event_model.dart';
import '../config/environment.dart';

class TrackingService {
  final String baseUrl;

  TrackingService({String? baseUrl})
      : baseUrl = baseUrl ?? Environment.baseUrl;

  // Get all campaigns
  Future<List<Campaign>> getCampaigns(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/campaigns?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final campaigns = (data['campaigns'] as List)
              .map((campaign) => Campaign.fromJson(campaign))
              .toList();
          return campaigns;
        } else {
          throw Exception(data['message'] ?? 'Failed to load campaigns');
        }
      } else {
        throw Exception('Failed to load campaigns: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading campaigns: $e');
    }
  }

  // Get campaign details with analytics
  Future<CampaignDetails> getCampaignDetails(String campaignId, String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/campaigns/$campaignId?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return CampaignDetails.fromJson(data);
        } else {
          throw Exception(data['message'] ?? 'Failed to load campaign details');
        }
      } else {
        throw Exception('Failed to load campaign details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading campaign details: $e');
    }
  }

  // Get events for a campaign
  Future<List<EmailEvent>> getCampaignEvents(
    String campaignId,
    String userId, {
    String? status,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (status != null) {
        queryParams['status'] = status;
      }

      queryParams['userId'] = userId;

      final uri = Uri.parse('$baseUrl/api/campaigns/$campaignId/events')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final events = (data['events'] as List)
              .map((event) => EmailEvent.fromJson(event))
              .toList();
          return events;
        } else {
          throw Exception(data['message'] ?? 'Failed to load events');
        }
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading events: $e');
    }
  }

  // Get aggregated statistics for a campaign
  Future<Map<String, dynamic>> getCampaignStats(String campaignId, String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/campaigns/$campaignId/stats?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'stats': data['stats'],
            'hourlyStats': data['hourlyStats'],
            'deviceStats': data['deviceStats'],
            'locationStats': data['locationStats'],
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to load statistics');
        }
      } else {
        throw Exception('Failed to load statistics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading statistics: $e');
    }
  }
}
