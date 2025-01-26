import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AddressWidget extends StatefulWidget {
  final void Function(String) onAddressUpdated;

  const AddressWidget({required this.onAddressUpdated, Key? key}) : super(key: key);

  @override
  _AddressWidgetState createState() => _AddressWidgetState();
}

class _AddressWidgetState extends State<AddressWidget> {
  String _address = '위치 정보를 가져오는 중...';

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  Future<void> _fetchUserLocation() async {
    try {
      // 위치 권한 확인 및 요청
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('위치 서비스가 비활성화되어 있습니다.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          throw Exception('위치 권한이 거부되었습니다.');
        }
      }

      // 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      String formattedAddress = await _getAddressFromCoordinates(position.latitude, position.longitude);

      // 주소 업데이트
      setState(() {
        _address = formattedAddress;
      });
      widget.onAddressUpdated(formattedAddress);
    } catch (e) {
      print('위치 가져오기 오류: $e');
      setState(() {
        _address = '위치 정보를 가져올 수 없습니다.';
      });
    }
  }

  Future<String> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.locality ?? ''} ${place.subLocality ?? ''} ${place.street ?? ''}';
      } else {
        return '주소를 찾을 수 없습니다.';
      }
    } catch (e) {
      print('주소 변환 실패: $e');
      return '주소 변환 실패';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // 한 줄 전체 너비
      color: Colors.blue[50], // 배경색
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Colors.blue), // 위치 아이콘
          const SizedBox(width: 8), // 아이콘과 텍스트 간격
          Expanded(
            child: Text(
              _address,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // 글자 초과 시 생략
            ),
          ),
        ],
      ),
    );
  }
}