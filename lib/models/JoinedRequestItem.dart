import 'dart:convert';

import 'package:nesysworks/models/request_item.dart';

class JoinedRequestItem extends RequestItem {
  final double distance;
  final bool isParticipating;
  final List<RequestItem> data;
  final List<RequestItem> requests;
  final String userId; // userId 추가

  JoinedRequestItem({
    required int id,
    required String vehicleNumber,
    required String situation,
    required String location,
    required String latitude,
    required String longitude,
    required int workers,
    required int joinedWorkers,
    required String progressStatus,
    required String startTime,
    required String createdAt,
    required String updatedAt,
    required bool isUserJoined,
    required List<Map<String, dynamic>> participantDetails,
    this.distance = 0.0,
    required this.isParticipating,
    required this.data,
    required this.requests,
    required this.userId, // userId 필수로 지정

  }) : super(
    id: id,
    vehicleNumber: vehicleNumber,
    situation: situation,
    location: location,
    latitude: latitude,
    longitude: longitude,
    workers: workers,
    joinedWorkers: joinedWorkers,
    progressStatus: progressStatus,
    startTime: startTime,
    createdAt: createdAt,
    updatedAt: updatedAt,
    isUserJoined: isUserJoined,
    isParticipating: isParticipating,
    requests: requests,
    userId:userId,

  );

  factory JoinedRequestItem.fromJson(Map<String, dynamic> json) {
    return JoinedRequestItem(
      id: json['id'] ?? json['request_id'] ?? -1,
      vehicleNumber: json['vehicle_number'] ?? '',
      situation: json['situation'] ?? '',
      location: json['location'] ?? '',
      latitude: json['latitude'] ?? '0.0',
      longitude: json['longitude'] ?? '0.0',
      workers: json['workers'] ?? 0,
      joinedWorkers: json['joined_workers'] ?? 0,
      progressStatus: json['progress_status'] ?? 'Pending',
      startTime: json['start_time'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      isUserJoined: json['is_user_joined'] ?? false,
      participantDetails: (json['joined_usernames'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList() ??
          [],
      isParticipating: json['is_participating'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => RequestItem.fromJson(item))
          .toList() ??
          [],
      requests: (json['data'] as List<dynamic>?)
          ?.map((item) => RequestItem.fromJson(item))
          .toList() ??
          [],
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0, userId: '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'is_participating': isParticipating,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }

}
