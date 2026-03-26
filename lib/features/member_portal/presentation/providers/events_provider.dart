import 'package:flutter/foundation.dart';
import 'package:pitstop/core/storage/secure_storage.dart';
import 'package:pitstop/features/member_portal/data/events_repository.dart';
import 'package:pitstop/features/member_portal/domain/models/event_model.dart';

class EventsProvider extends ChangeNotifier {
  final _repo = EventsRepository();

  bool _isLoading = false;
  String _error = '';
  List<EventModel> _events = [];
  String? _crmId;

  bool get isLoading => _isLoading;
  String get error => _error;
  List<EventModel> get events => List.unmodifiable(_events);
  String? get crmId => _crmId;

  Future<void> loadEvents() async {
    _setLoading(true);
    _error = '';

    _crmId = await SecureStorage.getCrmId();
    if (_crmId == null || _crmId!.isEmpty) {
      _events = [];
      _error = 'CRM ID missing. Please login again.';
      _setLoading(false);
      return;
    }

    try {
      _events = await _repo.getEvents(_crmId!);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
