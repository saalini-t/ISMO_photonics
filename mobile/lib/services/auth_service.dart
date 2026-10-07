import 'dart:convert';
import '../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthService(this._apiService, this._storageService);

  Future<User> login(String email, String password) async {
    final response = await _apiService.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    
    final token = response['token'] as String;
    final userJson = response['user'] as Map<String, dynamic>;
    
    await _storageService.saveToken(token);
    await _storageService.saveUserJson(jsonEncode(userJson));
    
    return User.fromJson(userJson);
  }

  Future<User> register(String fullName, String email, String password) async {
    final response = await _apiService.post('/auth/register', data: {
      'fullName': fullName,
      'email': email,
      'password': password,
    });
    
    final token = response['token'] as String;
    final userJson = response['user'] as Map<String, dynamic>;
    
    await _storageService.saveToken(token);
    await _storageService.saveUserJson(jsonEncode(userJson));
    
    return User.fromJson(userJson);
  }

  Future<User?> getMe() async {
    try {
      final response = await _apiService.get('/auth/me');
      final userJson = response['user'] as Map<String, dynamic>? ?? response;
      
      await _storageService.saveUserJson(jsonEncode(userJson));
      return User.fromJson(userJson);
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout');
    } catch (_) {
      // Ignore errors on logout
    } finally {
      await _storageService.deleteToken();
    }
  }
}
