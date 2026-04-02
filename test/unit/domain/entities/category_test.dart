import 'package:flutter_test/flutter_test.dart';
import 'package:kiosko_v2/domain/entities/category.dart';

void main() {
  group('Category', () {
    test('equality is based on id', () {
      const a = Category(id: '1', name: 'Cafe', imageUrl: '');
      const b = Category(id: '1', name: 'Coffee', imageUrl: 'x');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('different ids are not equal', () {
      const a = Category(id: '1', name: 'Cafe', imageUrl: '');
      const b = Category(id: '2', name: 'Cafe', imageUrl: '');
      expect(a, isNot(equals(b)));
    });

    test('sortOrder defaults to 0', () {
      const cat = Category(id: '1', name: 'Test', imageUrl: '');
      expect(cat.sortOrder, 0);
    });
  });
}
