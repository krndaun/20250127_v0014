class RequestItem {
  final int id;
  final String vehicleNumber;
  final String situation;
  final String location;
  final String latitude;
  final String longitude;
  final int workers;
  final int joinedWorkers;
  final String progressStatus;
  final String startTime;
  final String createdAt;
  final String updatedAt;
  final bool isUserJoined;
  final List<Map<String, dynamic>> participantDetails;
  final List<RequestItem> requests;
  final bool isParticipating;
  final double distance;
  final String userId; // userId 추가

  RequestItem({
    required this.id,
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
    this.participantDetails = const [],
    this.requests = const [],
    this.isParticipating = false,
    this.distance = 0.0,
    required this.userId, // userId 필수로 지정

  });

  /// 기본값 제공 메서드
  factory RequestItem.empty() {
    return RequestItem(
      id: -1,
      vehicleNumber: '',
      situation: '',
      location: '',
      latitude: '0.0',
      longitude: '0.0',
      workers: 0,
      joinedWorkers: 0,
      progressStatus: '',
      startTime: '',
      createdAt: '',
      updatedAt: '',
      isUserJoined: false,
      participantDetails: [],
      requests: [],
      isParticipating: false,
      distance: 0.0,
      userId: '',
    );
  }

  /// JSON 파싱 메서드
  factory RequestItem.fromJson(Map<String, dynamic> json) {
    try {
      return RequestItem(
        id: json['id'] ?? json['request_id'] ?? -1,
        vehicleNumber: json['vehicle_number'] ?? '',
        situation: json['situation'] ?? '',
        location: json['location'] ?? '',
        latitude: json['latitude']?.toString() ?? '0.0',
        longitude: json['longitude']?.toString() ?? '0.0',
        workers: json['workers'] ?? 0,
        joinedWorkers: json['joined_workers'] ?? 0,
        progressStatus: json['progress_status'] ?? '',
        startTime: json['start_time'] ?? '',
        createdAt: json['created_at'] ?? '',
        updatedAt: json['updated_at'] ?? '',
        isUserJoined: convertToBool(json['is_user_joined']),
        participantDetails: (json['joined_usernames'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList() ??
            [],
        requests: (json['data'] as List<dynamic>?)
            ?.map((item) => RequestItem.fromJson(item))
            .toList() ??
            [],
        isParticipating: convertToBool(json['is_participating']),
        distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
        userId: '',
      );
    } catch (e) {
      print('[ERROR] RequestItem.fromJson 오류: $e');
      return RequestItem.empty();
    }
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'id': id,
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
        'joined_usernames': participantDetails,
        'data': requests.map((e) => e.toJson()).toList(),
        'is_participating': isParticipating,
        'distance': distance,
      };
    } catch (e) {
      print('[ERROR] RequestItem.toJson 오류: $e');
      return {};
    }
  }
}

/// Boolean 변환 유틸리티
bool convertToBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final lowerValue = value.toLowerCase();
    return lowerValue == 'true' || lowerValue == '1';
  }
  return false;
}