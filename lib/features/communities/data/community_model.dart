class CommunityModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? coverImageUrl;
  final int memberCount;
  final DateTime createdAt;
  final bool isJoined;
  final String? lastActivity;

  CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.coverImageUrl,
    required this.memberCount,
    required this.createdAt,
    required this.isJoined,
    this.lastActivity,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      coverImageUrl: json['coverImageUrl']?.toString()
          ?? json['cover_image_url']?.toString(),
      memberCount: _parseInt(json['memberCount']) ?? 0,
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      isJoined: json['isJoined'] as bool? ?? false,
      lastActivity: json['lastActivity']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'coverImageUrl': coverImageUrl,
      'memberCount': memberCount,
      'createdAt': createdAt.toIso8601String(),
      'isJoined': isJoined,
      'lastActivity': lastActivity,
    };
  }

  CommunityModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? coverImageUrl,
    int? memberCount,
    DateTime? createdAt,
    bool? isJoined,
    String? lastActivity,
  }) {
    return CommunityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
      isJoined: isJoined ?? this.isJoined,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }
}

class CommunityMember {
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final DateTime joinedAt;
  final List<String> interestCategories;

  CommunityMember({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    required this.joinedAt,
    required this.interestCategories,
  });

  factory CommunityMember.fromJson(Map<String, dynamic> json) {
    final interestsRaw = json['interestCategories'] ?? json['interests'];
    final interests = <String>[];
    if (interestsRaw is List) {
      interests.addAll(
          interestsRaw.map((e) => e.toString()).where((e) => e.isNotEmpty));
    }
    return CommunityMember(
      userId: json['userId']?.toString()
          ?? json['user_id']?.toString()
          ?? '',
      fullName: json['fullName']?.toString()
          ?? json['name']?.toString()
          ?? '',
      avatarUrl: json['avatarUrl']?.toString()
          ?? json['avatar']?.toString(),
      joinedAt: _parseDate(json['joinedAt']) ?? DateTime.now(),
      interestCategories: interests,
    );
  }
}

class CommunityChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime createdAt;
  final bool isMine;

  CommunityChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.createdAt,
    required this.isMine,
  });

  CommunityChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? message,
    DateTime? createdAt,
    bool? isMine,
  }) {
    return CommunityChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isMine: isMine ?? this.isMine,
    );
  }
}

class DirectChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime createdAt;
  final bool isMine;

  DirectChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.createdAt,
    required this.isMine,
  });
}

int? _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

DateTime? _parseDate(dynamic value) {
  if (value is DateTime) return value;
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}
