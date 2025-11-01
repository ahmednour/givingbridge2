/// Comprehensive test suite for all RTL-aware widgets
/// 
/// This file imports and runs all RTL widget tests to ensure
/// comprehensive coverage of directional layout functionality.

import 'directional_layout_widgets_test.dart' as layout_tests;
import 'directional_navigation_widgets_test.dart' as navigation_tests;
import 'localized_form_widgets_test.dart' as form_tests;

void main() {
  // Run all RTL widget test suites
  layout_tests.main();
  navigation_tests.main();
  form_tests.main();
}