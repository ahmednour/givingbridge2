import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giving_bridge_frontend/services/rtl_layout_service.dart';

void main() {
  group('RTLLayoutService Tests', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    group('Padding Conversion Tests', () {
      test('should convert padding correctly for RTL', () {
        const originalPadding = EdgeInsets.only(left: 10, right: 20, top: 5, bottom: 15);
        final convertedPadding = RTLLayoutService.convertPaddingToRTL(originalPadding, true);
        
        expect(convertedPadding.left, 20); // right becomes left
        expect(convertedPadding.right, 10); // left becomes right
        expect(convertedPadding.top, 5); // top stays same
        expect(convertedPadding.bottom, 15); // bottom stays same
      });

      test('should not convert padding for LTR', () {
        const originalPadding = EdgeInsets.only(left: 10, right: 20, top: 5, bottom: 15);
        final convertedPadding = RTLLayoutService.convertPaddingToRTL(originalPadding, false);
        
        expect(convertedPadding, originalPadding);
      });

      testWidgets('should get directional padding with context', (WidgetTester tester) async {
        const originalPadding = EdgeInsets.only(left: 10, right: 20);
        
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            home: Builder(
              builder: (context) {
                final directionalPadding = RTLLayoutService.getDirectionalPadding(
                  context,
                  originalPadding,
                );
                
                expect(directionalPadding.left, 20); // Should be flipped for Arabic
                expect(directionalPadding.right, 10);
                
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('Alignment Conversion Tests', () {
      test('should convert alignment correctly for RTL', () {
        const originalAlignment = Alignment.centerLeft;
        final convertedAlignment = RTLLayoutService.convertAlignmentToRTL(originalAlignment, true);
        
        expect(convertedAlignment.x, -originalAlignment.x); // x should be flipped
        expect(convertedAlignment.y, originalAlignment.y); // y should stay same
      });

      test('should not convert alignment for LTR', () {
        const originalAlignment = Alignment.centerLeft;
        final convertedAlignment = RTLLayoutService.convertAlignmentToRTL(originalAlignment, false);
        
        expect(convertedAlignment, originalAlignment);
      });

      testWidgets('should get directional alignment with context', (WidgetTester tester) async {
        const originalAlignment = Alignment.centerLeft;
        
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            home: Builder(
              builder: (context) {
                final directionalAlignment = RTLLayoutService.getDirectionalAlignment(
                  context,
                  originalAlignment,
                );
                
                expect(directionalAlignment.x, -originalAlignment.x);
                
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('Cross Axis Alignment Conversion Tests', () {
      test('should convert CrossAxisAlignment.start to end for RTL', () {
        final converted = RTLLayoutService.convertCrossAxisAlignmentToRTL(
          CrossAxisAlignment.start,
          true,
        );
        
        expect(converted, CrossAxisAlignment.end);
      });

      test('should convert CrossAxisAlignment.end to start for RTL', () {
        final converted = RTLLayoutService.convertCrossAxisAlignmentToRTL(
          CrossAxisAlignment.end,
          true,
        );
        
        expect(converted, CrossAxisAlignment.start);
      });

      test('should not convert center alignment for RTL', () {
        final converted = RTLLayoutService.convertCrossAxisAlignmentToRTL(
          CrossAxisAlignment.center,
          true,
        );
        
        expect(converted, CrossAxisAlignment.center);
      });

      test('should not convert alignment for LTR', () {
        final converted = RTLLayoutService.convertCrossAxisAlignmentToRTL(
          CrossAxisAlignment.start,
          false,
        );
        
        expect(converted, CrossAxisAlignment.start);
      });
    });

    group('Main Axis Alignment Conversion Tests', () {
      test('should convert MainAxisAlignment.start to end for RTL', () {
        final converted = RTLLayoutService.convertMainAxisAlignmentToRTL(
          MainAxisAlignment.start,
          true,
        );
        
        expect(converted, MainAxisAlignment.end);
      });

      test('should convert MainAxisAlignment.end to start for RTL', () {
        final converted = RTLLayoutService.convertMainAxisAlignmentToRTL(
          MainAxisAlignment.end,
          true,
        );
        
        expect(converted, MainAxisAlignment.start);
      });

      test('should not convert center alignment for RTL', () {
        final converted = RTLLayoutService.convertMainAxisAlignmentToRTL(
          MainAxisAlignment.center,
          true,
        );
        
        expect(converted, MainAxisAlignment.center);
      });
    });

    group('Border Radius Conversion Tests', () {
      test('should convert border radius correctly for RTL', () {
        const originalRadius = BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(20),
        );
        
        final convertedRadius = RTLLayoutService.convertBorderRadiusToRTL(originalRadius, true);
        
        expect(convertedRadius.topLeft.x, 10); // topRight becomes topLeft
        expect(convertedRadius.topRight.x, 5); // topLeft becomes topRight
        expect(convertedRadius.bottomLeft.x, 20); // bottomRight becomes bottomLeft
        expect(convertedRadius.bottomRight.x, 15); // bottomLeft becomes bottomRight
      });

      test('should not convert border radius for LTR', () {
        const originalRadius = BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(10),
        );
        
        final convertedRadius = RTLLayoutService.convertBorderRadiusToRTL(originalRadius, false);
        
        expect(convertedRadius, originalRadius);
      });
    });

    group('Transform Conversion Tests', () {
      test('should convert transform matrix for RTL', () {
        final originalTransform = Matrix4.identity();
        final convertedTransform = RTLLayoutService.convertTransformToRTL(originalTransform, true);
        
        // The converted transform should have different values for RTL
        expect(convertedTransform.getRow(0)[0], -1.0); // Should be flipped horizontally
      });

      test('should not convert transform for LTR', () {
        final originalTransform = Matrix4.identity();
        final convertedTransform = RTLLayoutService.convertTransformToRTL(originalTransform, false);
        
        expect(convertedTransform, originalTransform);
      });
    });

    group('Offset Conversion Tests', () {
      testWidgets('should get directional offset with context', (WidgetTester tester) async {
        const originalOffset = Offset(10, 20);
        
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            home: Builder(
              builder: (context) {
                final directionalOffset = RTLLayoutService.getDirectionalOffset(
                  context,
                  originalOffset,
                );
                
                expect(directionalOffset.dx, -originalOffset.dx); // x should be flipped for RTL
                expect(directionalOffset.dy, originalOffset.dy); // y should stay same
                
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('List Order Conversion Tests', () {
      test('should reverse list order for RTL', () {
        final originalList = [1, 2, 3, 4, 5];
        final convertedList = RTLLayoutService.convertListOrderForRTL(originalList, true);
        
        expect(convertedList, [5, 4, 3, 2, 1]);
      });

      test('should not reverse list order for LTR', () {
        final originalList = [1, 2, 3, 4, 5];
        final convertedList = RTLLayoutService.convertListOrderForRTL(originalList, false);
        
        expect(convertedList, originalList);
      });

      testWidgets('should get directional list order with context', (WidgetTester tester) async {
        final originalList = ['A', 'B', 'C'];
        
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            home: Builder(
              builder: (context) {
                final directionalList = RTLLayoutService.getDirectionalListOrder(
                  context,
                  originalList,
                );
                
                expect(directionalList, ['C', 'B', 'A']);
                
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('Text Align Conversion Tests', () {
      testWidgets('should get directional text align with context', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            home: Builder(
              builder: (context) {
                // Test left alignment conversion
                final leftAlign = RTLLayoutService.getDirectionalTextAlign(
                  context,
                  defaultAlign: TextAlign.left,
                );
                expect(leftAlign, TextAlign.right); // left becomes right in RTL
                
                // Test right alignment conversion
                final rightAlign = RTLLayoutService.getDirectionalTextAlign(
                  context,
                  defaultAlign: TextAlign.right,
                );
                expect(rightAlign, TextAlign.left); // right becomes left in RTL
                
                // Test start/end alignment (should remain unchanged)
                final startAlign = RTLLayoutService.getDirectionalTextAlign(
                  context,
                  defaultAlign: TextAlign.start,
                );
                expect(startAlign, TextAlign.start);
                
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return default alignment for RTL when no default provided', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            home: Builder(
              builder: (context) {
                final textAlign = RTLLayoutService.getDirectionalTextAlign(context);
                expect(textAlign, TextAlign.right); // Default for RTL
                
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('Utility Methods Tests', () {
      testWidgets('should detect RTL correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            home: Builder(
              builder: (context) {
                expect(RTLLayoutService.isRTL(context), true);
                return Container();
              },
            ),
          ),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            home: Builder(
              builder: (context) {
                expect(RTLLayoutService.isRTL(context), false);
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should get correct text direction', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            home: Builder(
              builder: (context) {
                expect(RTLLayoutService.getTextDirection(context), TextDirection.rtl);
                return Container();
              },
            ),
          ),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            home: Builder(
              builder: (context) {
                expect(RTLLayoutService.getTextDirection(context), TextDirection.ltr);
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should wrap widget with correct directionality', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            home: Builder(
              builder: (context) {
                final wrappedWidget = RTLLayoutService.wrapWithDirectionality(
                  context,
                  const Text('Test'),
                );
                
                expect(wrappedWidget, isA<Directionality>());
                
                return wrappedWidget;
              },
            ),
          ),
        );
      });

      testWidgets('should get correct directional icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            home: Builder(
              builder: (context) {
                final icon = RTLLayoutService.getDirectionalIcon(
                  context,
                  ltrIcon: Icons.arrow_forward,
                  rtlIcon: Icons.arrow_back,
                );
                
                expect(icon, Icons.arrow_back); // Should use RTL icon for Arabic
                
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should get directional flex properties', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            home: Builder(
              builder: (context) {
                final flexProperties = RTLLayoutService.getDirectionalFlexProperties(
                  context,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                );
                
                expect(flexProperties['mainAxisAlignment'], MainAxisAlignment.end);
                expect(flexProperties['crossAxisAlignment'], CrossAxisAlignment.end);
                expect(flexProperties['mainAxisSize'], MainAxisSize.max);
                
                return Container();
              },
            ),
          ),
        );
      });
    });
  });
}