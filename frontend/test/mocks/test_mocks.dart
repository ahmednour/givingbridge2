import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock SharedPreferences for testing
class MockSharedPreferences extends Mock implements SharedPreferences {}

// Mock OfflineService for testing
class MockOfflineService extends Mock {
  Future<void> initialize() async {}
  Future<void> queueOperation(
      String operation, Map<String, dynamic> data) async {}
  Future<void> cacheData(
      {required String key, required Map<String, dynamic> data}) async {}
  int get pendingOperationsCount => 0;
  Future<void> processPendingOperations() async {}
}

// Test setup for mocking plugins
void setupTestMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock SharedPreferences
  SharedPreferences.setMockInitialValues({});
}
