import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  /// 사용자 데이터 저장
  static Future<void> saveUserData(String username, String email, String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    await prefs.setString('id', id);
  }

  /// 사용자 데이터 로드
  static Future<Map<String, String?>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString('username'),
      'email': prefs.getString('email'),
      'id': prefs.getString('id'),
    };
  }

  /// 사용자 데이터 삭제
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}