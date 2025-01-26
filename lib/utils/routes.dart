import 'package:flutter/material.dart';
import 'package:nesysworks/screens/splash_screen.dart';
import 'package:nesysworks/screens/login_screen.dart';
import 'package:nesysworks/screens/reset_password_screen.dart';
import 'package:nesysworks/screens/request_list_screen.dart';
import 'package:nesysworks/screens/joined_request_screen.dart';
import 'package:nesysworks/models/request_item.dart'; // RequestItem 가져오기

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String resetPassword = '/reset_password';
  static const String requestList = '/request_list';
  static const String joinedRequest = '/joined_request';
  static const String home = '/home'; // 홈 경로 추가

  static Map<String, WidgetBuilder> getRoutes({
    required double userLatitude,
    required double userLongitude,
    required RequestItem joinedRequestItem,
    required String userId, // userId가 필수 매개변수
  }) {
    return {
      splash: (_) => SplashScreen(),
      login: (_) => LoginScreen(),
      // resetPassword: (_) => ResetPasswordScreen(),
      requestList: (_) => RequestListScreen(
        userLatitude: userLatitude,
        userLongitude: userLongitude,
      ),
      joinedRequest: (_) => JoinedRequestScreen(
        joinedRequest: joinedRequestItem, // 매개변수 이름 일치
        participants: [], // 참여자 리스트
        socket: null, // 소켓 연결
        maxDistance: 50.0, // 기본 거리
        userId: userId, // userId 전달
      ),
      home: (_) => RequestListScreen(
        userLatitude: userLatitude,
        userLongitude: userLongitude,
      ), // 홈 화면 추가
    };
  }
}