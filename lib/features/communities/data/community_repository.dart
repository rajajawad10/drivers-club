import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pitstop/core/network/api_constants.dart';
import 'package:pitstop/core/storage/secure_storage.dart';
import 'package:pitstop/features/communities/data/community_model.dart';

class CommunityRepository {
  bool useMock = true;

  static final List<Map<String, dynamic>> _mockCommunities = [
    {
      'id': '1',
      'name': 'Track Day Enthusiasts',
      'description':
          'For members passionate about track days and motorsport performance.',
      'category': 'Racing',
      'coverImageUrl':
          'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=1200&q=80',
      'memberCount': 48,
      'isJoined': true,
      'createdAt': '2024-03-01',
      'lastActivity': '2 hours ago',
    },
    {
      'id': '2',
      'name': 'Golf Members',
      'description': 'Connect with fellow golf enthusiasts and organize outings.',
      'category': 'Sports',
      'coverImageUrl':
          'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=1200&q=80',
      'memberCount': 31,
      'isJoined': false,
      'createdAt': '2024-04-15',
      'lastActivity': '1 day ago',
    },
    {
      'id': '3',
      'name': 'Wine & Dine Club',
      'description': 'Exclusive dining experiences and wine tastings.',
      'category': 'Dining',
      'coverImageUrl':
          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=1200&q=80',
      'memberCount': 22,
      'isJoined': false,
      'createdAt': '2024-05-20',
      'lastActivity': '3 days ago',
    },
    {
      'id': '4',
      'name': 'Classic Car Owners',
      'description': 'A community for collectors and classic car enthusiasts.',
      'category': 'Collector',
      'coverImageUrl':
          'https://images.unsplash.com/photo-1502877338535-766e1452684a?w=1200&q=80',
      'memberCount': 15,
      'isJoined': false,
      'createdAt': '2024-06-10',
      'lastActivity': '1 week ago',
    },
    {
      'id': '5',
      'name': 'Business Leaders Network',
      'description': 'Executive networking, strategy, and growth.',
      'category': 'Business',
      'coverImageUrl':
          'https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=1200&q=80',
      'memberCount': 58,
      'isJoined': true,
      'createdAt': '2024-02-12',
      'lastActivity': '6 hours ago',
    },
    {
      'id': '6',
      'name': 'Design Collective',
      'description': 'Share ideas, critique, and inspiration for creators.',
      'category': 'Design',
      'coverImageUrl':
          'https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=1200&q=80',
      'memberCount': 42,
      'isJoined': false,
      'createdAt': '2024-01-18',
      'lastActivity': '5 days ago',
    },
  ];

  Future<List<CommunityModel>> getCommunities() async {
    if (useMock) {
      return _mockCommunities
          .map((e) => CommunityModel.fromJson(e))
          .toList();
    }
    final response = await _get(ApiConstants.communities);
    return _parseCommunityList(response);
  }

  Future<CommunityModel> getCommunityById(String id) async {
    if (useMock) {
      final found =
          _mockCommunities.firstWhere((c) => c['id']?.toString() == id);
      return CommunityModel.fromJson(found);
    }
    final response = await _get(ApiConstants.communityById(id));
    return _parseCommunity(response);
  }

  Future<void> joinCommunity(String communityId) async {
    if (useMock) {
      _setMockJoinStatus(communityId, true);
      return;
    }
    await _post(ApiConstants.joinCommunity(communityId));
  }

  Future<void> leaveCommunity(String communityId) async {
    if (useMock) {
      _setMockJoinStatus(communityId, false);
      return;
    }
    await _delete(ApiConstants.leaveCommunity(communityId));
  }

  Future<List<CommunityMember>> getCommunityMembers(String communityId) async {
    if (useMock) {
      return [
        CommunityMember(
          userId: 'u1',
          fullName: 'Ahmed K.',
          avatarUrl:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&q=80',
          joinedAt: DateTime.now().subtract(const Duration(days: 60)),
          interestCategories: ['Racing', 'Events'],
        ),
        CommunityMember(
          userId: 'u2',
          fullName: 'Sara M.',
          avatarUrl:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop&q=80',
          joinedAt: DateTime.now().subtract(const Duration(days: 90)),
          interestCategories: ['Dining'],
        ),
        CommunityMember(
          userId: 'u3',
          fullName: 'Omar T.',
          avatarUrl:
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop&q=80',
          joinedAt: DateTime.now().subtract(const Duration(days: 30)),
          interestCategories: ['Sports', 'Collector'],
        ),
        CommunityMember(
          userId: 'u4',
          fullName: 'Noor A.',
          avatarUrl:
              'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&h=200&fit=crop&q=80',
          joinedAt: DateTime.now().subtract(const Duration(days: 18)),
          interestCategories: ['Business', 'Design'],
        ),
        CommunityMember(
          userId: 'u5',
          fullName: 'Bilal R.',
          avatarUrl:
              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&q=80',
          joinedAt: DateTime.now().subtract(const Duration(days: 12)),
          interestCategories: ['Racing', 'Sports'],
        ),
        CommunityMember(
          userId: 'u6',
          fullName: 'Maha S.',
          avatarUrl:
              'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&h=200&fit=crop&q=80',
          joinedAt: DateTime.now().subtract(const Duration(days: 8)),
          interestCategories: ['Wine', 'Dining'],
        ),
        CommunityMember(
          userId: 'u7',
          fullName: 'Faisal H.',
          avatarUrl:
              'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&h=200&fit=crop&q=80',
          joinedAt: DateTime.now().subtract(const Duration(days: 6)),
          interestCategories: ['Business', 'Collector'],
        ),
      ];
    }
    final response = await _get(ApiConstants.communityMembers(communityId));
    return _parseCommunityMembers(response);
  }

  Future<List<CommunityChatMessage>> getCommunityChat(String communityId) async {
    if (useMock) {
      return [
        CommunityChatMessage(
          id: 'm1',
          senderId: 'u1',
          senderName: 'Ahmed K.',
          message: 'Anyone joining the next track day?',
          createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
          isMine: false,
        ),
        CommunityChatMessage(
          id: 'm1b',
          senderId: 'u2',
          senderName: 'Sara M.',
          message: 'I will join! Which time slot is best?',
          createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
          isMine: false,
        ),
        CommunityChatMessage(
          id: 'm2',
          senderId: 'me',
          senderName: 'You',
          message: 'Yes, count me in!',
          createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
          isMine: true,
        ),
        CommunityChatMessage(
          id: 'm3',
          senderId: 'u2',
          senderName: 'Sara M.',
          message: 'What time are we meeting?',
          createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
          isMine: false,
        ),
        CommunityChatMessage(
          id: 'm4',
          senderId: 'me',
          senderName: 'You',
          message: 'Let’s finalize a schedule tonight.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          isMine: true,
        ),
      ];
    }
    final response = await _get(
        '${ApiConstants.communityById(communityId)}/chat');
    final raw = response['data'] ?? response['messages'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => CommunityChatMessage(
                id: e['id']?.toString() ?? '',
                senderId: e['senderId']?.toString() ?? '',
                senderName: e['senderName']?.toString() ?? '',
                message: e['message']?.toString() ?? '',
                createdAt:
                    _parseDate(e['createdAt']) ?? DateTime.now(),
                isMine: e['isMine'] as bool? ?? false,
              ))
          .toList();
    }
    return [];
  }

  Future<void> sendMessage(String communityId, String text) async {
    if (useMock) return;
    await _post(
      '${ApiConstants.communityById(communityId)}/chat',
      body: {'message': text},
    );
  }

  Future<List<DirectChatMessage>> getDirectChat(String userId) async {
    if (useMock) {
      return [
        DirectChatMessage(
          id: 'dm1',
          senderId: userId,
          senderName: 'Member',
          message: 'Hi! Happy to connect.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
          isMine: false,
        ),
        DirectChatMessage(
          id: 'dm2',
          senderId: 'me',
          senderName: 'You',
          message: 'Thanks! Let’s chat.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          isMine: true,
        ),
      ];
    }
    final response = await _get('${ApiConstants.communities}/dm/$userId');
    final raw = response['data'] ?? response['messages'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => DirectChatMessage(
                id: e['id']?.toString() ?? '',
                senderId: e['senderId']?.toString() ?? '',
                senderName: e['senderName']?.toString() ?? '',
                message: e['message']?.toString() ?? '',
                createdAt: _parseDate(e['createdAt']) ?? DateTime.now(),
                isMine: e['isMine'] as bool? ?? false,
              ))
          .toList();
    }
    return [];
  }

  Future<void> sendDirectMessage(String userId, String text) async {
    if (useMock) return;
    await _post(
      '${ApiConstants.communities}/dm/$userId',
      body: {'message': text},
    );
  }

  Future<void> updateMemberInterests(
      String communityId, List<String> interests) async {
    if (useMock) return;
    await _post(
      '${ApiConstants.communityById(communityId)}/interest',
      body: {'interestCategories': interests},
    );
  }

  Future<List<CommunityModel>> getMyCommunities() async {
    if (useMock) {
      return _mockCommunities
          .where((c) => c['isJoined'] == true)
          .map((e) => CommunityModel.fromJson(e))
          .toList();
    }
    final response = await _get(ApiConstants.myCommunities);
    return _parseCommunityList(response);
  }

  Future<void> notifyCommunityMembers(String communityId, String message) async {
    if (useMock) return;
    await _post(ApiConstants.notifyCommunity(communityId),
        body: {'message': message});
  }

  void _setMockJoinStatus(String communityId, bool joined) {
    final index = _mockCommunities
        .indexWhere((c) => c['id']?.toString() == communityId);
    if (index == -1) return;
    _mockCommunities[index] = {
      ..._mockCommunities[index],
      'isJoined': joined,
    };
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final token = await SecureStorage.getToken();
    final response = await http
        .get(
          Uri.parse(ApiConstants.baseUrl + path),
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        )
        .timeout(ApiConstants.timeout);
    return _handleResponse(response, 'Failed to load communities.');
  }

  Future<void> _post(String path, {Map<String, dynamic>? body}) async {
    final token = await SecureStorage.getToken();
    final response = await http
        .post(
          Uri.parse(ApiConstants.baseUrl + path),
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body ?? {}),
        )
        .timeout(ApiConstants.timeout);
    _handleResponse(response, 'Request failed.');
  }

  Future<void> _delete(String path) async {
    final token = await SecureStorage.getToken();
    final response = await http
        .delete(
          Uri.parse(ApiConstants.baseUrl + path),
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        )
        .timeout(ApiConstants.timeout);
    _handleResponse(response, 'Request failed.');
  }

  Map<String, dynamic> _handleResponse(
      http.Response response, String fallback) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    final message = data['message']?.toString()
        ?? data['error']?.toString()
        ?? fallback;
    throw Exception(message);
  }

  List<CommunityModel> _parseCommunityList(Map<String, dynamic> data) {
    final raw = data['data'] ?? data['items'] ?? data['communities'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => CommunityModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  CommunityModel _parseCommunity(Map<String, dynamic> data) {
    final raw = data['data'] ?? data['community'] ?? data;
    if (raw is Map) {
      return CommunityModel.fromJson(Map<String, dynamic>.from(raw));
    }
    return CommunityModel.fromJson({});
  }

  List<CommunityMember> _parseCommunityMembers(Map<String, dynamic> data) {
    final raw = data['data'] ?? data['items'] ?? data['members'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => CommunityMember.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }
}

DateTime? _parseDate(dynamic value) {
  if (value is DateTime) return value;
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}
