class SocietyEventModel {
  final String? id;
  final String title;
  final String description;
  final String date;
  final String registrationLink;
  final String imageUrl;

  SocietyEventModel({
    this.id,
    required this.title,
    this.description = '',
    this.date = '',
    this.registrationLink = '',
    this.imageUrl = '',
  });

  factory SocietyEventModel.fromJson(Map<String, dynamic> json) {
    return SocietyEventModel(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      registrationLink: json['registrationLink'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'date': date,
      'registrationLink': registrationLink,
      'imageUrl': imageUrl,
    };
  }
}

class SocietyModel {
  final String id;
  final String name;
  final String department;
  final String description;
  final String logoUrl;
  final String websiteLink;
  final String registrationLink;
  final List<String> domains;
  final List<SocietyEventModel> recentEvents;
  final List<SocietyEventModel> upcomingEvents;
  final String category;
  final String status;
  final bool isApproved;
  final String createdByName;
  final DateTime? createdAt;

  SocietyModel({
    required this.id,
    required this.name,
    required this.department,
    required this.description,
    this.logoUrl = '',
    this.websiteLink = '',
    this.registrationLink = '',
    this.domains = const [],
    this.recentEvents = const [],
    this.upcomingEvents = const [],
    this.category = 'Technical',
    this.status = 'pending',
    this.isApproved = false,
    this.createdByName = 'Society Member',
    this.createdAt,
  });

  factory SocietyModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedDomains = [];
    if (json['domains'] is List) {
      parsedDomains = (json['domains'] as List).map((d) => d.toString()).toList();
    }

    List<SocietyEventModel> parsedRecent = [];
    if (json['recentEvents'] is List) {
      parsedRecent = (json['recentEvents'] as List)
          .map((e) => SocietyEventModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<SocietyEventModel> parsedUpcoming = [];
    if (json['upcomingEvents'] is List) {
      parsedUpcoming = (json['upcomingEvents'] as List)
          .map((e) => SocietyEventModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final statusVal = json['status'] ?? (json['isApproved'] == true ? 'approved' : 'pending');
    final isApprovedVal = json['isApproved'] == true || statusVal == 'approved';

    return SocietyModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      department: json['department'] ?? '',
      description: json['description'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      websiteLink: json['websiteLink'] ?? '',
      registrationLink: json['registrationLink'] ?? '',
      domains: parsedDomains,
      recentEvents: parsedRecent,
      upcomingEvents: parsedUpcoming,
      category: json['category'] ?? 'Technical',
      status: statusVal,
      isApproved: isApprovedVal,
      createdByName: json['createdByName'] ?? 'Society Member',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'description': description,
      'logoUrl': logoUrl,
      'websiteLink': websiteLink,
      'registrationLink': registrationLink,
      'domains': domains,
      'recentEvents': recentEvents.map((e) => e.toJson()).toList(),
      'upcomingEvents': upcomingEvents.map((e) => e.toJson()).toList(),
      'category': category,
      'status': status,
      'isApproved': isApproved,
      'createdByName': createdByName,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
