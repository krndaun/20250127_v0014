import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// 현재 위치 가져오기
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('위치 서비스가 비활성화되어 있습니다.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 영구적으로 거부되었습니다.');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  /// 좌표로부터 주소 가져오기
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.locality ?? ''} ${place.subLocality ?? ''} ${place.street ?? ''}';
      }
      return '주소를 찾을 수 없습니다.';
    } catch (e) {
      print('주소 변환 오류: $e');
      return '주소 변환 실패';
    }
  }

  /// 서버에 위치 정보 업데이트
  Future<void> updateLocationOnServer(String userId, Position position) async {
    // 서버 업데이트 로직 추가
    print('사용자 위치 서버에 업데이트: $userId, ${position.latitude}, ${position.longitude}');
  }
}