import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nesysworks/models/request_item.dart';
import 'package:nesysworks/services/socket_service.dart';
import 'package:provider/provider.dart';
import 'package:nesysworks/providers/user_provider.dart';
import 'package:nesysworks/utils/routes.dart';
import 'package:nesysworks/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SocketService socketService = SocketService();
  socketService.initializeSocket();

  Position? position;
  try {
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

    position = await Geolocator.getCurrentPosition();
  } catch (e) {
    print('[ERROR] 위치 정보를 가져오지 못했습니다: $e');
    position = null;
  }

  // SharedPreferences에서 userId 가져오기
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('id'); // 저장된 사용자 ID 가져오기
  if (userId == null) {
    print('[ERROR] 사용자 ID를 찾을 수 없습니다.');
    throw Exception('userId가 필요합니다.');
  }

  // 기본 RequestItem 생성
  final RequestItem joinedRequestItem = RequestItem.empty();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        Provider(create: (_) => socketService),
      ],
      child: MyApp(
        userLatitude: position?.latitude ?? 0.0,
        userLongitude: position?.longitude ?? 0.0,
        joinedRequestItem: joinedRequestItem, // 전달
        userId: userId, // userId 전달
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final double userLatitude;
  final double userLongitude;
  final RequestItem joinedRequestItem;
  final String userId; // userId 추가

  const MyApp({
    required this.userLatitude,
    required this.userLongitude,
    required this.joinedRequestItem,
    required this.userId, // userId 추가
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NesysWorks',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: SplashScreen(),
      routes: Routes.getRoutes(
        userLatitude: userLatitude,
        userLongitude: userLongitude,
        joinedRequestItem: joinedRequestItem,
        userId: userId,
      )..remove('/'),
    );
  }
}