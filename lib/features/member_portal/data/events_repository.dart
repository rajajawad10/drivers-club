import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pitstop/core/network/api_constants.dart';
import 'package:pitstop/core/storage/secure_storage.dart';
import 'package:pitstop/features/member_portal/domain/models/event_model.dart';

class EventsRepository {
  Future<List<EventModel>> getEvents(String crmId) async {
    final token = await SecureStorage.getToken();
    final response = await http.get(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.getEvents(crmId)),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return _parseEventsList(data['data']);
    }

    final message = data['message']?.toString()
        ?? data['error']?.toString()
        ?? 'Failed to load events.';
    throw Exception(message);
  }

  Future<EventModel> getEventById(String crmId, String eventId) async {
    final token = await SecureStorage.getToken();
    final response = await http.get(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.getEventById(crmId, eventId)),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return EventModel.fromJson(data['data'] as Map<String, dynamic>? ?? {});
    }

    final message = data['message']?.toString()
        ?? data['error']?.toString()
        ?? 'Failed to load event.';
    throw Exception(message);
  }

  List<EventModel> _parseEventsList(dynamic rawData) {
    if (rawData is List) {
      return rawData
          .whereType<Map>()
          .map((item) => EventModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    if (rawData is Map<String, dynamic>) {
      final list = rawData['data'] ?? rawData['items'] ?? rawData['events'];
      if (list is List) {
        return list
            .whereType<Map>()
            .map((item) => EventModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    }
    return [];
  }
}
