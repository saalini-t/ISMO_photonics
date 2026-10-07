import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('User.fromJson() correctly parses JSON fields', () {
      final json = {
        'id': '123',
        'fullName': 'Test User',
        'email': 'test@example.com',
      };
      final user = User.fromJson(json);

      expect(user.id, '123');
      expect(user.fullName, 'Test User');
      expect(user.email, 'test@example.com');
    });

    test('User.toJson() outputs correct Map structure', () {
      final user = User(
        id: '123',
        fullName: 'Test User',
        email: 'test@example.com',
      );
      final json = user.toJson();

      expect(json['id'], '123');
      expect(json['fullName'], 'Test User');
      expect(json['email'], 'test@example.com');
    });
  });
}

