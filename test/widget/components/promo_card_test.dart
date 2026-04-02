import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:kiosko_v2/presentation/widgets/promo_card.dart';
import 'package:kiosko_v2/core/theme/app_colors.dart';

void main() {
  group('PromoCard', () {
    Widget buildPromo({VoidCallback? onTap, String? buttonText}) {
      return PromoCard(
        titleLine1: 'Primer',
        titleLine2: 'Combo',
        buttonText: buttonText ?? 'Ver mas',
        imageUrl: 'https://example.com/promo.png',
        backgroundColor: AppColors.promoRed,
        onTap: onTap ?? () {},
      );
    }

    testWidgets('displays title lines', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: buildPromo())),
        );
        expect(find.text('Primer'), findsOneWidget);
        expect(find.text('Combo'), findsOneWidget);
      });
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('displays button text', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: buildPromo(buttonText: 'Click aqui')),
          ),
        );
        expect(find.text('Click aqui'), findsOneWidget);
      });
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('calls onTap when pressed', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      bool tapped = false;
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: buildPromo(onTap: () => tapped = true)),
          ),
        );
        await tester.tap(find.byType(PromoCard));
        await tester.pump();
        expect(tapped, isTrue);
      });
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('has chevron_right icon', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: buildPromo())),
        );
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      });
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
