import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:weatherapp/database_helper.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Hash password using SHA256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, dynamic>?> registerUser({
    required String username,
    required String email,
    required String password,
    String role = 'user', // Default role
  }) async {
    // Check if username or email already exists
    if (await _dbHelper.getUserByUsername(username) != null) {
      throw Exception('Username already exists');
    }
    if (await _dbHelper.getUserByEmail(email) != null) {
      throw Exception('Email already exists');
    }

    final String passwordHash = _hashPassword(password);
    final Map<String, dynamic> userRow = {
      'username': username,
      'email': email,
      'password_hash': passwordHash,
      'role': role,
    };

    final id = await _dbHelper.insertUser(userRow);
    if (id > 0) {
      return {
        'id': id,
        'username': username,
        'email': email,
        'role': role,
      };
    }
    return null;
  }

  Future<Map<String, dynamic>?> loginUser(String emailOrUsername, String password) async {
    Map<String, dynamic>? user;

    // Try fetching user by email first
    user = await _dbHelper.getUserByEmail(emailOrUsername);

    // If not found by email, try by username
    if (user == null) {
      user = await _dbHelper.getUserByUsername(emailOrUsername);
    }

    if (user != null) {
      final String passwordHash = _hashPassword(password);
      if (user['password_hash'] == passwordHash) {
        return {
          'id': user['id'],
          'username': user['username'],
          'email': user['email'],
          'role': user['role'],
        };
      } else {
        throw Exception('Invalid password');
      }
    } else {
      throw Exception('User not found');
    }
  }

  // In a real app, you'd manage session/token here.
  // For simplicity, we'll rely on a global state or provider later.
  Future<void> logoutUser() async {
    // Clear session data, if any.
    // This is more relevant when using tokens or more complex session management.
    print("User logged out");
  }
}
