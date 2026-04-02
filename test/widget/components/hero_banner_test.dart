import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:kiosko_v2/presentation/widgets/hero_banner.dart';

Widget _wrapBanner(HeroBanner banner) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 1000,
        height: 400,
        child: banner,
      ),
    ),
  );
}

void main() {
  group('HeroBanner', () {
    testWidgets('displays discount and percentage text', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          _wrapBanner(HeroBanner(
            discountText: 'Descuento especial',
            percentageText: 'Hasta 50%',
            buttonText: 'Ordenar',
            imageUrl: 'https://example.com/hero.png',
            onButtonTap: () {},
          )),
        );
        expect(find.text('Descuento especial'), findsOneWidget);
        expect(find.text('Hasta 50%'), findsOneWidget);
      });
    });

    testWidgets('displays button text', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          _wrapBanner(HeroBanner(
            discountText: 'Test',
            percentageText: '30%',
            buttonText: 'Order Now',
            imageUrl: 'https://example.com/hero.png',
            onButtonTap: () {},
          )),
        );
        expect(find.text('Order Now'), findsOneWidget);
      });
    });

    testWidgets('calls onButtonTap when button pressed', (tester) async {
      bool tapped = false;
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          _wrapBanner(HeroBanner(
            discountText: 'Test',
            percentageText: '50%',
            buttonText: 'Ordenar',
            imageUrl: 'https://example.com/hero.png',
            onButtonTap: () => tapped = true,
          )),
        );
        await tester.tap(find.text('Ordenar'));
        await tester.pump();
        expect(tapped, isTrue);
      });
    });
  });
}
