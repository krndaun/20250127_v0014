class JoinedUser {
  final int userId;
  final String name;
  final double latitude;
  final double longitude;
  final double? distance;
  final String status;
  final String taskStatus;

  JoinedUser({
    required this.userId,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.distance,
    required this.status,
    required this.taskStatus,
  });

  factory JoinedUser.fromJson(Map<String, dynamic> json) {
    return JoinedUser(
      userId: json['user_id'] ?? -1,
      name: json['name'] ?? 'Unknown',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      distance: (json['distance'] != null) ? json['distance'].toDouble() : null,
      status: json['status'] ?? 'unknown',
      taskStatus: json['task_status'] ?? 'notStarted',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'status': status,
      'task_status': taskStatus,
    };
  }
}