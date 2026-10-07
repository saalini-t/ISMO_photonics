import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

class StorageService {
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: kAuthTokenKey, value: token);
    } catch (e) {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(kAuthTokenKey, token);
      } else {
        rethrow;
      }
    }
  }

  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: kAuthTokenKey);
    } catch (e) {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(kAuthTokenKey);
      } else {
        rethrow;
      }
    }
  }

  Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: kAuthTokenKey);
    } catch (e) {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(kAuthTokenKey);
      } else {
        rethrow;
      }
    }
  }

  Future<void> saveUserJson(String json) async {
    try {
      await _secureStorage.write(key: kUserDataKey, value: json);
    } catch (e) {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(kUserDataKey, json);
      } else {
        rethrow;
      }
    }
  }

  Future<String?> getUserJson() async {
    try {
      return await _secureStorage.read(key: kUserDataKey);
    } catch (e) {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(kUserDataKey);
      } else {
        rethrow;
      }
    }
  }
}
