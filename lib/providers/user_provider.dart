import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  String username = '';
  String email = '';
  String id = '';

  void setUser(String newUsername, String newEmail, String newId) {
    username = newUsername;
    email = newEmail;
    id = newId;
    notifyListeners();
  }
}