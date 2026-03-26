class EventModel {
  final String id;
  final String title;
  final String description;
  final String eventDate;
  final String location;
  final int totalSlots;
  final int availableSlots;
  final String imageUrl;
  final String category;
  final String eventName;
  final String summary;
  final String startDateTime;
  final String mainGraphicUrl;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.location,
    required this.totalSlots,
    required this.availableSlots,
    required this.imageUrl,
    required this.category,
    required this.eventName,
    required this.summary,
    required this.startDateTime,
    required this.mainGraphicUrl,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      eventDate: json['eventDate']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      totalSlots: (json['totalSlots'] as num?)?.toInt() ?? 0,
      availableSlots: (json['availableSlots'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      eventName: json['eventName']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      startDateTime: json['startDateTime']?.toString() ?? '',
      mainGraphicUrl: json['mainGraphicUrl']?.toString() ?? '',
    );
  }
}

class EventResponse {
  final bool success;
  final String message;
  final EventModel data;

  EventResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory EventResponse.fromJson(Map<String, dynamic> json) {
    return EventResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: EventModel.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
    );
  }
}
