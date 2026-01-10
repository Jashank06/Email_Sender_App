class Campaign {
  final String id;
  final String subject;
  final String senderEmail;
  final String senderName;
  final int totalEmails;
  final int sentCount;
  final int deliveredCount;
  final int openedCount;
  final int clickedCount;
  final int failedCount;
  final String status;
  final double openRate;
  final double clickRate;
  final double deliveryRate;
  final double failureRate;
  final DateTime createdAt;
  final DateTime? completedAt;

  Campaign({
    required this.id,
    required this.subject,
    required this.senderEmail,
    required this.senderName,
    required this.totalEmails,
    required this.sentCount,
    required this.deliveredCount,
    required this.openedCount,
    required this.clickedCount,
    required this.failedCount,
    required this.status,
    required this.openRate,
    required this.clickRate,
    required this.deliveryRate,
    required this.failureRate,
    required this.createdAt,
    this.completedAt,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] ?? '',
      subject: json['subject'] ?? '',
      senderEmail: json['senderEmail'] ?? '',
      senderName: json['senderName'] ?? '',
      totalEmails: json['totalEmails'] ?? 0,
      sentCount: json['sentCount'] ?? 0,
      deliveredCount: json['deliveredCount'] ?? 0,
      openedCount: json['openedCount'] ?? 0,
      clickedCount: json['clickedCount'] ?? 0,
      failedCount: json['failedCount'] ?? 0,
      status: json['status'] ?? 'pending',
      openRate: double.tryParse(json['openRate']?.toString() ?? '0') ?? 0.0,
      clickRate: double.tryParse(json['clickRate']?.toString() ?? '0') ?? 0.0,
      deliveryRate: double.tryParse(json['deliveryRate']?.toString() ?? '0') ?? 0.0,
      failureRate: double.tryParse(json['failureRate']?.toString() ?? '0') ?? 0.0,
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'senderEmail': senderEmail,
      'senderName': senderName,
      'totalEmails': totalEmails,
      'sentCount': sentCount,
      'deliveredCount': deliveredCount,
      'openedCount': openedCount,
      'clickedCount': clickedCount,
      'failedCount': failedCount,
      'status': status,
      'openRate': openRate,
      'clickRate': clickRate,
      'deliveryRate': deliveryRate,
      'failureRate': failureRate,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

class CampaignDetails {
  final Campaign campaign;
  final CampaignStats stats;
  final int eventCount;

  CampaignDetails({
    required this.campaign,
    required this.stats,
    required this.eventCount,
  });

  factory CampaignDetails.fromJson(Map<String, dynamic> json) {
    return CampaignDetails(
      campaign: Campaign.fromJson(json['campaign']),
      stats: CampaignStats.fromJson(json['stats']),
      eventCount: json['eventCount'] ?? 0,
    );
  }
}

class CampaignStats {
  final int total;
  final int sent;
  final int delivered;
  final int opened;
  final int clicked;
  final int failed;
  final double openRate;
  final double clickRate;
  final double deliveryRate;
  final double failureRate;
  final int uniqueOpens;
  final int uniqueClicks;
  final int totalClicks;
  final List<TopLink> topLinks;

  CampaignStats({
    required this.total,
    required this.sent,
    required this.delivered,
    required this.opened,
    required this.clicked,
    required this.failed,
    required this.openRate,
    required this.clickRate,
    required this.deliveryRate,
    required this.failureRate,
    required this.uniqueOpens,
    required this.uniqueClicks,
    required this.totalClicks,
    required this.topLinks,
  });

  factory CampaignStats.fromJson(Map<String, dynamic> json) {
    return CampaignStats(
      total: json['total'] ?? 0,
      sent: json['sent'] ?? 0,
      delivered: json['delivered'] ?? 0,
      opened: json['opened'] ?? 0,
      clicked: json['clicked'] ?? 0,
      failed: json['failed'] ?? 0,
      openRate: double.tryParse(json['openRate']?.toString() ?? '0') ?? 0.0,
      clickRate: double.tryParse(json['clickRate']?.toString() ?? '0') ?? 0.0,
      deliveryRate: double.tryParse(json['deliveryRate']?.toString() ?? '0') ?? 0.0,
      failureRate: double.tryParse(json['failureRate']?.toString() ?? '0') ?? 0.0,
      uniqueOpens: json['uniqueOpens'] ?? 0,
      uniqueClicks: json['uniqueClicks'] ?? 0,
      totalClicks: json['totalClicks'] ?? 0,
      topLinks: (json['topLinks'] as List?)
              ?.map((link) => TopLink.fromJson(link))
              .toList() ??
          [],
    );
  }
}

class TopLink {
  final String url;
  final int clicks;

  TopLink({
    required this.url,
    required this.clicks,
  });

  factory TopLink.fromJson(Map<String, dynamic> json) {
    return TopLink(
      url: json['url'] ?? '',
      clicks: json['clicks'] ?? 0,
    );
  }
}
