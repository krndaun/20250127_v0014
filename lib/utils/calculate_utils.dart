import 'dart:math';

class CalculateUtils {
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    if (lat1.isNaN || lon1.isNaN || lat2.isNaN || lon2.isNaN ||
        lat1.isInfinite || lon1.isInfinite || lat2.isInfinite || lon2.isInfinite) {
      print('[ERROR] Invalid coordinates: lat1=$lat1, lon1=$lon1, lat2=$lat2, lon2=$lon2');
      return 0.0; // 유효하지 않은 경우 0.0 반환
    }

    const earthRadius = 6371; // 지구 반지름 (km)
    final dLat = _degreeToRadian(lat2 - lat1);
    final dLon = _degreeToRadian(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreeToRadian(lat1)) *
            cos(_degreeToRadian(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _degreeToRadian(double degree) => degree * pi / 180;
}