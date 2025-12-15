import 'package:flutter_test/flutter_test.dart';

import 'package:mental_zen/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromJson and toJson roundtrip', () {
      final json = {
        'email': 'test@example.com',
        'displayName': 'Test',
        'createdAt': DateTime(2024, 1, 1),
        'updatedAt': DateTime(2024, 1, 2),
        'settings': {'darkMode': true},
      };
      final model = UserModel.fromJson('id123', json);
      final back = model.toJson();
      expect(back['email'], 'test@example.com');
      expect(back['displayName'], 'Test');
      expect(back['settings'], {'darkMode': true});
    });

    test('fromJson handles missing optional fields', () {
      final model = UserModel.fromJson('id123', {});
      expect(model.email, '');
      expect(model.displayName, '');
      expect(model.settings, {});
    });
  });
}


