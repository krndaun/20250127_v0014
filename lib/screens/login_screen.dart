import 'package:flutter/material.dart';
import 'package:nesysworks/screens/reset_password_screen.dart';
import 'package:nesysworks/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 기본 이메일과 비밀번호로 텍스트 필드 초기화
  final TextEditingController _emailController =
  TextEditingController(text: "lsj0718 / jd@pline.co.kr");
  final TextEditingController _passwordController =
  TextEditingController(text: "123");

  // 사용자 데이터 저장 메서드
  Future<void> _saveUserData(String username, String email, String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    await prefs.setString('id', id);
    print('[DEBUG] User data saved: username=$username, email=$email, id=$id');
  }

  // 로그인 처리 메서드
  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이메일과 비밀번호를 입력해주세요.')),
      );
      return;
    }

    try {
      final data = await ApiService.login(email, password);

      if (data['status'] == true) {
        if (data['reset'] == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(email: email),
            ),
          );
        } else {
          final username = data['username'] ?? 'username';
          final id = data['id'] ?? 'id';

          await UserService.saveUserData(username, email, id);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('환영합니다, $username님!')),
          );

          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: ${data['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 중 오류가 발생했습니다. 다시 시도해주세요.')),
      );
      print('[ERROR] 로그인 오류: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NESYSWORKS'), // 상단바 타이틀 설정
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '이메일'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('로그인'),
            ),
          ],
        ),
      ),
    );
  }
}