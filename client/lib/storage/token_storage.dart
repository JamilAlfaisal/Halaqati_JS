import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

class TokenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    // print('Token saved successfully!');
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> readToken() async {
    // The read method returns the value for the given key.
    String? token = await _storage.read(key: _tokenKey);
    return token;
  }

  Future<void> deleteToken() async {
    // The delete method removes the key-value pair.
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey); // Good practice to delete both
    print('Tokens deleted successfully!');
  }

  Future<bool> hasToken() async {
    return await _storage.containsKey(key: _tokenKey);
  }


}