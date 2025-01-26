import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nesysworks/models/JoinedRequestItem.dart';
import 'package:nesysworks/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nesysworks/utils/routes.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isFetching = false; // 중복 호출 방지 플래그
  bool _isInitialized = false; // 앱 초기화 상태 플래그
  IO.Socket? _socket;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('id');
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id'); // 사용자 ID 삭제
    print('[DEBUG] 로그아웃 완료. 로그인 페이지로 이동.');
    Navigator.pushReplacementNamed(context, Routes.login);
  }

  Future<void> _checkUserStatus() async {
    if (_isFetching) return; // 중복 호출 방지
    _isFetching = true;

    try {
      final userId = await _getUserId();

      if (userId == null || userId.isEmpty) {
        print('[DEBUG] 로그인 정보 없음. 로그인 페이지로 이동.');
        Navigator.pushReplacementNamed(context, Routes.login);
        return;
      }

      print('[DEBUG] 로그인된 사용자: userId=$userId');
      final response = await ApiService.fetchJoinedRequests(userId);

      if (response != null && response.isParticipating) {
        print('[DEBUG] 참여 중인 요청 발견.');
        Navigator.pushReplacementNamed(
          context,
          Routes.joinedRequest,
          arguments: response,
        );
      } else {
        print('[DEBUG] 참여 요청 없음. 모든 요청 데이터 불러오기.');
        final allRequests = await ApiService.fetchRequests(userId);

        if (allRequests.isNotEmpty) {
          Navigator.pushReplacementNamed(
            context,
            Routes.requestList,
            arguments: allRequests,
          );
        } else {
          print('[DEBUG] 요청 리스트가 비어 있음.');
          Navigator.pushReplacementNamed(context, Routes.requestList);
        }
      }
    } catch (e) {
      print('[ERROR] 사용자 상태 확인 중 오류 발생: $e');
      Navigator.pushReplacementNamed(context, Routes.login);
    } finally {
      _isFetching = false; // 항상 플래그 해제
    }
  }

  Future<void> _initializeApp() async {
    if (_isInitialized) return; // 이미 초기화된 경우 중단
    _isInitialized = true;

    try {
      await _requestLocationPermission();
      await _fetchUserLocation();
      _initializeSocket();
      await _checkUserStatus();
    } catch (e) {
      print('[ERROR] 앱 초기화 중 오류 발생: $e');
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  void _initializeSocket() {
    if (_socket != null && _socket!.connected) {
      print('[DEBUG] 소켓이 이미 연결되어 있습니다.');
      return;
    }

    _socket = IO.io('http://your-socket-url', <String, dynamic>{
      'transports': ['websocket'],
    });

    _socket!.on('connect', (_) => print('[DEBUG] 소켓 연결 성공'));
  }

  Future<void> _requestLocationPermission() async {
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
  }

  Future<void> _fetchUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('latitude', position.latitude);
      await prefs.setDouble('longitude', position.longitude);

      print('[DEBUG] 위치 정보 저장: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('[ERROR] 위치 정보 가져오기 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Text(
          'NesysWorks',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}