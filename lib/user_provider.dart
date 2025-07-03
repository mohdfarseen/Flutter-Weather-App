import 'package:flutter/material.dart';

class UserModel {
  final int id;
  final String username;
  final String email;
  final String role;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });
}

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  bool get isAuthenticated => _user != null;

  void setUser(Map<String, dynamic>? userData) {
    if (userData != null) {
      _user = UserModel(
        id: userData['id'],
        username: userData['username'],
        email: userData['email'],
        role: userData['role'],
      );
    } else {
      _user = null;
    }
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
