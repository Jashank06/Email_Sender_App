class EmailEvent {
  final String id;
  final String trackingId;
  final String recipientEmail;
  final String recipientName;
  final String status;
  final int openCount;
  final int clickCount;
  final DateTime? firstOpenedAt;
  final DateTime? lastOpenedAt;
  final EventMetadata? metadata;
  final List<Event> events;
  final DateTime createdAt;

  EmailEvent({
    required this.id,
    required this.trackingId,
    required this.recipientEmail,
    required this.recipientName,
    required this.status,
    required this.openCount,
    required this.clickCount,
    this.firstOpenedAt,
    this.lastOpenedAt,
    this.metadata,
    required this.events,
    required this.createdAt,
  });

  factory EmailEvent.fromJson(Map<String, dynamic> json) {
    return EmailEvent(
      id: json['id'] ?? '',
      trackingId: json['trackingId'] ?? '',
      recipientEmail: json['recipientEmail'] ?? '',
      recipientName: json['recipientName'] ?? '',
      status: json['status'] ?? 'sent',
      openCount: json['openCount'] ?? 0,
      clickCount: json['clickCount'] ?? 0,
      firstOpenedAt: json['firstOpenedAt'] != null
          ? DateTime.parse(json['firstOpenedAt'])
          : null,
      lastOpenedAt: json['lastOpenedAt'] != null
          ? DateTime.parse(json['lastOpenedAt'])
          : null,
      metadata: json['metadata'] != null
          ? EventMetadata.fromJson(json['metadata'])
          : null,
      events: (json['events'] as List?)
              ?.map((event) => Event.fromJson(event))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String get statusIcon {
    switch (status) {
      case 'sent':
        return '📤';
      case 'delivered':
        return '✅';
      case 'opened':
        return '👁️';
      case 'clicked':
        return '🖱️';
      case 'failed':
        return '❌';
      case 'bounced':
        return '⚠️';
      default:
        return '📧';
    }
  }

  String get statusLabel {
    return status.toUpperCase();
  }
}

class Event {
  final String type;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  Event({
    required this.type,
    required this.timestamp,
    this.metadata,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      type: json['type'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'],
    );
  }
}

class EventMetadata {
  final String? userAgent;
  final String? ipAddress;
  final String? device;
  final String? location;
  final List<ClickedLink>? clickedLinks;

  EventMetadata({
    this.userAgent,
    this.ipAddress,
    this.device,
    this.location,
    this.clickedLinks,
  });

  factory EventMetadata.fromJson(Map<String, dynamic> json) {
    return EventMetadata(
      userAgent: json['userAgent'],
      ipAddress: json['ipAddress'],
      device: json['device'],
      location: json['location'],
      clickedLinks: (json['clickedLinks'] as List?)
          ?.map((link) => ClickedLink.fromJson(link))
          .toList(),
    );
  }
}

class ClickedLink {
  final String url;
  final DateTime timestamp;

  ClickedLink({
    required this.url,
    required this.timestamp,
  });

  factory ClickedLink.fromJson(Map<String, dynamic> json) {
    return ClickedLink(
      url: json['url'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class EmailProgress {
  final String campaignId;
  final int total;
  final int sent;
  final int failed;
  final double percentage;
  final String? currentEmail;
  final int? elapsedTime;
  final int? estimatedTimeRemaining;
  final String? error;

  EmailProgress({
    required this.campaignId,
    required this.total,
    required this.sent,
    required this.failed,
    required this.percentage,
    this.currentEmail,
    this.elapsedTime,
    this.estimatedTimeRemaining,
    this.error,
  });

  factory EmailProgress.fromJson(Map<String, dynamic> json) {
    return EmailProgress(
      campaignId: json['campaignId'] ?? '',
      total: json['total'] ?? 0,
      sent: json['sent'] ?? 0,
      failed: json['failed'] ?? 0,
      percentage: double.tryParse(json['percentage']?.toString() ?? '0') ?? 0.0,
      currentEmail: json['currentEmail'],
      elapsedTime: json['elapsedTime'],
      estimatedTimeRemaining: json['estimatedTimeRemaining'],
      error: json['error'],
    );
  }

  String get formattedElapsedTime {
    if (elapsedTime == null) return '0s';
    final seconds = (elapsedTime! / 1000).round();
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    }
    return '${seconds}s';
  }

  String get formattedEstimatedTime {
    if (estimatedTimeRemaining == null) return '0s';
    final seconds = (estimatedTimeRemaining! / 1000).round();
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    }
    return '${seconds}s';
  }

  double get emailsPerMinute {
    if (elapsedTime == null || elapsedTime == 0) return 0;
    final minutes = elapsedTime! / 60000;
    return sent / minutes;
  }
}
