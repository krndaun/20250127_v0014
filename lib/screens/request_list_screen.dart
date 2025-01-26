import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nesysworks/models/request_item.dart';
import 'package:nesysworks/utils/routes.dart';
import 'package:nesysworks/widgets/menu_widget.dart';
import 'package:nesysworks/widgets/request_list_item.dart';
import 'package:nesysworks/widgets/address_widget.dart';
import 'package:nesysworks/widgets/distance_settings_dialog.dart';
import 'package:nesysworks/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestListScreen extends StatefulWidget {
  final double userLatitude;
  final double userLongitude;

  const RequestListScreen({
    required this.userLatitude,
    required this.userLongitude,
    Key? key,
  }) : super(key: key);

  @override
  _RequestListScreenState createState() => _RequestListScreenState();
}

class _RequestListScreenState extends State<RequestListScreen> {
  List<RequestItem> _requestList = [];
  bool _isLoading = true;
  double _maxDistance = 50.0;
  String _currentAddress = '위치를 가져오는 중...';
  String? _userId;
  late Future<List<RequestItem>> _requestListFuture; // 타입 수정
  bool _isAppInitialized = false; // 초기화 플래그 추가
  bool _isFetchingRequestList = false; // 요청 중 플래그 추가

  @override
  void initState() {
    super.initState();
    _requestListFuture = _fetchRequestList(); // 초기화
  }

// 새로고침 시 호출
  void _refreshRequestList() {
    setState(() {
      _requestListFuture = _fetchRequestList();
    });
  }

  Future<void> _initializeApp() async {
    if (_isAppInitialized) return; // 중복 호출 방지
    _isAppInitialized = true;

    try {
      await _initializeUserId();
      await _fetchUserLocation();
      setState(() {
        _requestListFuture = _fetchRequestList(); // 초기화
      });
    } catch (e) {
      print('[ERROR] 앱 초기화 중 오류 발생: $e');
      Navigator.pushReplacementNamed(context, Routes.login);
    } finally {
      _isAppInitialized = false; // 플래그 해제
    }
  }

  Future<void> _initializeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('id');
    });
    if (_userId == null) {
      print('[ERROR] User ID is null. 로그인이 필요합니다.');
    }
  }

  Future<void> _fetchUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final address = await ApiService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _currentAddress = address;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('latitude', position.latitude);
      await prefs.setDouble('longitude', position.longitude);

      print('[DEBUG] 위치 정보 저장: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('[ERROR] 위치 정보 가져오기 실패: $e');
    }
  }

  Future<List<RequestItem>> _fetchRequestList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('id') ?? '';
      if (userId.isEmpty) throw Exception('유효하지 않은 사용자 ID');

      final requests = await ApiService.fetchRequests(userId);

      // 데이터를 반환
      return requests;
    } catch (e) {
      print('[ERROR] 요청 리스트 로드 실패: $e');
      return []; // 오류 발생 시 빈 리스트 반환
    }
  }


  String _calculateDistance(RequestItem item) {
    try {
      final distance = Geolocator.distanceBetween(
        widget.userLatitude,
        widget.userLongitude,
        double.parse(item.latitude),
        double.parse(item.longitude),
      ) / 1000;
      return distance.toStringAsFixed(1);
    } catch (e) {
      print('[ERROR] 거리 계산 실패: $e');
      return '0.0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('요청 리스트'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => DistanceSettingsDialog(
                  currentDistance: _maxDistance,
                  onDistanceChanged: (newDistance) {
                    setState(() {
                      _maxDistance = newDistance;
                      _requestListFuture = _fetchRequestList();
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
      drawer: AppMenu(
        onRefreshLocation: () async {
          await _fetchUserLocation();
        },
      ),
      body: FutureBuilder<List<RequestItem>>(
        future: _requestListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('요청 데이터를 불러오는 중 오류가 발생했습니다.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('요청 리스트가 없습니다.'));
          }

          final requestList = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _requestListFuture = _fetchRequestList();
              });
            },
            child: ListView.builder(
              itemCount: requestList.length,
              itemBuilder: (context, index) {
                final item = requestList[index];
                return RequestListItem(
                  item: item,
                  distanceDisplay: '${_calculateDistance(item)}km',
                  isFullyJoined: item.joinedWorkers >= item.workers,
                  onJoin: () {
                    // 참여 처리 로직 추가
                    print('[DEBUG] 참여 요청: ${item.id}');
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}