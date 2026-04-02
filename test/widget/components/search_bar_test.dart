import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/presentation/widgets/kiosk_search_bar.dart';

void main() {
  group('KioskSearchBar', () {
    testWidgets('displays hint text', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KioskSearchBar(
              controller: controller,
              onSearch: () {},
            ),
          ),
        ),
      );
      expect(find.text('Buscar productos...'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('calls onSearch when search button tapped', (tester) async {
      bool searched = false;
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KioskSearchBar(
              controller: controller,
              onSearch: () => searched = true,
            ),
          ),
        ),
      );
      // Tap the search button (the orange container with search icon)
      final searchIcons = find.byIcon(Icons.search);
      await tester.tap(searchIcons.last);
      await tester.pump();
      expect(searched, isTrue);
      controller.dispose();
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? changedValue;
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KioskSearchBar(
              controller: controller,
              onSearch: () {},
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'cafe');
      expect(changedValue, equals('cafe'));
      controller.dispose();
    });

    testWidgets('has search icon in both input and button', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KioskSearchBar(
              controller: controller,
              onSearch: () {},
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.search), findsNWidgets(2));
      controller.dispose();
    });
  });
}
