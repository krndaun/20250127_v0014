import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nesysworks/services/location_service.dart';

class LocationWidget extends StatefulWidget {
  final void Function(Position, String) onLocationUpdated; // 위치 및 주소 업데이트 콜백

  const LocationWidget({required this.onLocationUpdated, Key? key}) : super(key: key);

  @override
  _LocationWidgetState createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  final LocationService _locationService = LocationService();
  String _address = '위치 정보를 가져오는 중...';

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _address = address;
      });

      // 부모 위젯에 위치 및 주소 전달
      widget.onLocationUpdated(position, address);
    } catch (e) {
      print('위치 정보를 가져오는 중 오류 발생: $e');
      setState(() {
        _address = '위치 정보를 가져올 수 없습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey.shade200,
      child: Row(
        children: [
          Icon(Icons.location_on, color: Colors.red),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _address,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}