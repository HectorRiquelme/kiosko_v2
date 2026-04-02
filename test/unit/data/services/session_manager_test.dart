import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kiosko_v2/data/services/session_manager.dart';

void main() {
  group('SessionManager', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('saveSession and getSession', () async {
      await SessionManager.saveSession('admin1');
      final userId = await SessionManager.getSession();
      expect(userId, 'admin1');
    });

    test('getSession returns null when no session', () async {
      final userId = await SessionManager.getSession();
      expect(userId, isNull);
    });

    test('clearSession removes session', () async {
      await SessionManager.saveSession('admin1');
      await SessionManager.clearSession();
      final userId = await SessionManager.getSession();
      expect(userId, isNull);
    });
  });
}
