import 'dart:convert';

class RequestItem {
  final int id;
  final int requestid;
  final String vehicleNumber;
  final String situation;
  final String location;
  final double latitude;
  final double longitude;
  final int workers;
  final int joinedWorkers;
  final String progressStatus;
  final String startTime;
  final String createdAt;
  final String updatedAt;
  final bool isUserJoined;
  final bool isParticipating;
  final double distance;
  final String userId;
  final List<Map<String, dynamic>> joinedUsernames;
  final List<RequestItem> requests;

  RequestItem({
    required this.id,
    required this.requestid,
    required this.vehicleNumber,
    required this.situation,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.workers,
    required this.joinedWorkers,
    required this.progressStatus,
    required this.startTime,
    required this.createdAt,
    required this.updatedAt,
    required this.isUserJoined,
    required this.isParticipating,
    required this.distance,
    required this.userId,
    List<Map<String, dynamic>>? joinedUsernames,
    List<RequestItem>? requests,
  })  : joinedUsernames = joinedUsernames ?? [],
        requests = requests ?? [];

  /// **📌 JSON 데이터를 `RequestItem` 객체로 변환**
  factory RequestItem.fromJson(Map<String, dynamic> json) {
    return RequestItem(
      id: json['id'] ?? json['request_id'] ?? -1,
      requestid: json['request_id'] ?? -1,
      vehicleNumber: json['vehicle_number']?.toString() ?? '',
      situation: json['situation'] ?? '',
      location: json['location'] ?? '',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      workers: json['workers'] ?? 0,
      joinedWorkers: json['joined_workers'] ?? 0,
      progressStatus: json['progress_status'] ?? '',
      startTime: json['start_time'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      isUserJoined: json['is_user_joined'] ?? false,
      isParticipating: json['is_participating'] ?? false,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      userId: json['user_id']?.toString() ?? '',
      joinedUsernames: _parseJoinedUsernames(json['joined_usernames']),
      requests: (json['requests'] as List?)
          ?.map((item) => RequestItem.fromJson(Map<String, dynamic>.from(item)))
          .toList() ??
          [],
    );
  }

  /// **📌 JSON에서 `joinedUsernames` 변환**
  static List<Map<String, dynamic>> _parseJoinedUsernames(dynamic data) {
    if (data == null) return [];
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        }
      } catch (e) {
        print('[ERROR] joined_usernames JSON 변환 실패: $e');
      }
    }
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  /// **📌 `RequestItem`을 JSON 데이터로 변환**
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestid,
      'vehicle_number': vehicleNumber,
      'situation': situation,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'workers': workers,
      'joined_workers': joinedWorkers,
      'progress_status': progressStatus,
      'start_time': startTime,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_user_joined': isUserJoined,
      'is_participating': isParticipating,
      'distance': distance,
      'user_id': userId,
      'joined_usernames': jsonEncode(joinedUsernames),
      'requests': requests.map((item) => item.toJson()).toList(),
    };
  }

  /// **📌 기본값을 가지는 빈 `RequestItem` 생성**
  factory RequestItem.empty() {
    return RequestItem(
      id: -1,
      requestid: -1,
      vehicleNumber: '',
      situation: '',
      location: '',
      latitude: 0.0,
      longitude: 0.0,
      workers: 0,
      joinedWorkers: 0,
      progressStatus: '',
      startTime: '',
      createdAt: '',
      updatedAt: '',
      isUserJoined: false,
      isParticipating: false,
      distance: 0.0,
      userId: '',
      joinedUsernames: [],
      requests: [],
    );
  }
}