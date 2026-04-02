import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:kiosko_v2/presentation/widgets/promo_card.dart';
import 'package:kiosko_v2/core/theme/app_colors.dart';

void main() {
  group('PromoCard', () {
    testWidgets('displays title lines', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PromoCard(
                titleLine1: 'Primer',
                titleLine2: 'Combo',
                buttonText: 'Ver mas',
                imageUrl: 'https://example.com/promo.png',
                backgroundColor: AppColors.promoRed,
                onTap: () {},
              ),
            ),
          ),
        );
        expect(find.text('Primer'), findsOneWidget);
        expect(find.text('Combo'), findsOneWidget);
      });
    });

    testWidgets('displays button text', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PromoCard(
                titleLine1: 'Test',
                titleLine2: 'Promo',
                buttonText: 'Click aqui',
                imageUrl: 'https://example.com/promo.png',
                backgroundColor: AppColors.promoBrown,
                onTap: () {},
              ),
            ),
          ),
        );
        expect(find.text('Click aqui'), findsOneWidget);
      });
    });

    testWidgets('calls onTap when pressed', (tester) async {
      bool tapped = false;
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PromoCard(
                titleLine1: 'Test',
                titleLine2: 'Promo',
                buttonText: 'Ver mas',
                imageUrl: 'https://example.com/promo.png',
                backgroundColor: AppColors.promoRed,
                onTap: () => tapped = true,
              ),
            ),
          ),
        );
        await tester.tap(find.byType(PromoCard));
        await tester.pump();
        expect(tapped, isTrue);
      });
    });

    testWidgets('has chevron_right icon', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PromoCard(
                titleLine1: 'Test',
                titleLine2: 'Promo',
                buttonText: 'Ver mas',
                imageUrl: 'https://example.com/promo.png',
                backgroundColor: AppColors.promoRed,
                onTap: () {},
              ),
            ),
          ),
        );
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      });
    });
  });
}
