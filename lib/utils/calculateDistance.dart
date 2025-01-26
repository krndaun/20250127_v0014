import 'package:geolocator/geolocator.dart';

String calculateDistance(double userLat, double userLon, String requestLatStr, String requestLonStr) {
  try {
    // 요청지의 위도와 경도를 문자열에서 double로 변환
    final double requestLat = double.parse(requestLatStr);
    final double requestLon = double.parse(requestLonStr);

    // Geolocator를 사용하여 거리 계산 (단위: km)
    final double distance = Geolocator.distanceBetween(userLat, userLon, requestLat, requestLon) / 1000;

    // 0.5km 이내는 '인근 지역'으로 표시
    if (distance < 0.5) {
      return '인근 지역';
    } else {
      return '${distance.toStringAsFixed(1)}km';
    }
  } catch (e) {
    print('[ERROR] 거리 계산 오류: $e');
    return '거리 계산 실패';
  }
}