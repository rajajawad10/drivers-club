import 'package:flutter/material.dart';
import 'package:pitstop/features/communities/data/community_model.dart';
import 'package:pitstop/features/communities/data/community_repository.dart';

class CommunitiesProvider extends ChangeNotifier {
  final CommunityRepository _repository = CommunityRepository();

  List<CommunityModel> _allCommunities = [];
  List<CommunityModel> _myCommunities = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final Map<String, List<CommunityChatMessage>> _chatByCommunity = {};
  final Map<String, List<DirectChatMessage>> _directChatByUser = {};
  final Map<String, List<String>> _interestByCommunity = {};
  List<String> _selectedInterests = [];

  List<CommunityModel> get allCommunities => _filteredCommunities();
  List<CommunityModel> get myCommunities => _filteredMyCommunities();
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<String> get selectedInterests => List.unmodifiable(_selectedInterests);
  List<CommunityChatMessage> chatFor(String communityId) =>
      List.unmodifiable(_chatByCommunity[communityId] ?? []);
  List<DirectChatMessage> directChatFor(String userId) =>
      List.unmodifiable(_directChatByUser[userId] ?? []);
  List<String> interestFor(String communityId) =>
      List.unmodifiable(_interestByCommunity[communityId] ?? []);

  List<String> get categories {
    final cats = _allCommunities.map((c) => c.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  Future<void> loadAllCommunities() async {
    _setLoading(true);
    _error = null;
    try {
      _allCommunities = await _repository.getCommunities();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMyCommunities() async {
    _setLoading(true);
    _error = null;
    try {
      _myCommunities = await _repository.getMyCommunities();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> joinCommunity(String id) async {
    _optimisticJoin(id, true);
    try {
      await _repository.joinCommunity(id);
      await loadMyCommunities();
    } catch (e) {
      _optimisticJoin(id, false);
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> leaveCommunity(String id) async {
    _optimisticJoin(id, false);
    try {
      await _repository.leaveCommunity(id);
      await loadMyCommunities();
    } catch (e) {
      _optimisticJoin(id, true);
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> loadChat(String communityId) async {
    try {
      final messages = await _repository.getCommunityChat(communityId);
      _chatByCommunity[communityId] = messages;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> sendChatMessage(String communityId, String text) async {
    if (text.trim().isEmpty) return;
    final existing = _chatByCommunity[communityId] ?? [];
    final local = CommunityChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'me',
      senderName: 'You',
      message: text.trim(),
      createdAt: DateTime.now(),
      isMine: true,
    );
    _chatByCommunity[communityId] = [...existing, local];
    notifyListeners();
    try {
      await _repository.sendMessage(communityId, text.trim());
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> loadDirectChat(String userId) async {
    try {
      final messages = await _repository.getDirectChat(userId);
      _directChatByUser[userId] = messages;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> sendDirectMessage(String userId, String text) async {
    if (text.trim().isEmpty) return;
    final existing = _directChatByUser[userId] ?? [];
    final local = DirectChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'me',
      senderName: 'You',
      message: text.trim(),
      createdAt: DateTime.now(),
      isMine: true,
    );
    _directChatByUser[userId] = [...existing, local];
    notifyListeners();
    try {
      await _repository.sendDirectMessage(userId, text.trim());
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> updateInterestCategories(
      String communityId, List<String> interests) async {
    try {
      _interestByCommunity[communityId] = interests;
      notifyListeners();
      await _repository.updateMemberInterests(communityId, interests);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedInterests(List<String> interests) {
    _selectedInterests = interests;
    notifyListeners();
  }

  void clearSelectedInterests() {
    _selectedInterests = [];
    notifyListeners();
  }

  List<CommunityModel> _filteredCommunities() {
    var list = _allCommunities;
    if (_selectedCategory != 'All') {
      list = list.where((c) => c.category == _selectedCategory).toList();
    }
    if (_selectedInterests.isNotEmpty) {
      list = list
          .where((c) => _selectedInterests.contains(c.category))
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.description.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  List<CommunityModel> _filteredMyCommunities() {
    var list = _myCommunities.where((c) => c.isJoined).toList();
    if (_selectedCategory != 'All') {
      list = list.where((c) => c.category == _selectedCategory).toList();
    }
    if (_selectedInterests.isNotEmpty) {
      list = list
          .where((c) => _selectedInterests.contains(c.category))
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.description.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  void _optimisticJoin(String id, bool join) {
    _allCommunities = _allCommunities
        .map((c) => c.id == id ? c.copyWith(isJoined: join) : c)
        .toList();
    _myCommunities = join
        ? [
            ..._myCommunities,
            ..._allCommunities.where((c) => c.id == id && c.isJoined),
          ]
        : _myCommunities.where((c) => c.id != id).toList();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
