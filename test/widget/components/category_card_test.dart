import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:kiosko_v2/presentation/widgets/category_card.dart';

void main() {
  group('CategoryCard', () {
    testWidgets('displays category name', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryCard(
                name: 'Cafe',
                imageUrl: 'https://example.com/cafe.png',
                onTap: () {},
              ),
            ),
          ),
        );
        expect(find.text('Cafe'), findsOneWidget);
      });
    });

    testWidgets('calls onTap when pressed', (tester) async {
      bool tapped = false;
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryCard(
                name: 'Cafe',
                imageUrl: 'https://example.com/cafe.png',
                onTap: () => tapped = true,
              ),
            ),
          ),
        );
        await tester.tap(find.byType(CategoryCard));
        await tester.pump();
        expect(tapped, isTrue);
      });
    });

    testWidgets('has correct size 110x110', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: CategoryCard(
                  name: 'Test',
                  imageUrl: 'https://example.com/test.png',
                  onTap: () {},
                ),
              ),
            ),
          ),
        );
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(CategoryCard),
            matching: find.byType(Container),
          ).first,
        );
        expect(container.constraints?.maxWidth, equals(110.0));
        expect(container.constraints?.maxHeight, equals(110.0));
      });
    });

    testWidgets('has AnimatedScale widget', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryCard(
                name: 'Test',
                imageUrl: 'https://example.com/test.png',
                onTap: () {},
              ),
            ),
          ),
        );
        expect(find.byType(AnimatedScale), findsOneWidget);
      });
    });

    testWidgets('has Semantics widget', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryCard(
                name: 'Cafe',
                imageUrl: 'https://example.com/cafe.png',
                onTap: () {},
              ),
            ),
          ),
        );
        expect(find.byType(Semantics), findsWidgets);
      });
    });
  });
}
