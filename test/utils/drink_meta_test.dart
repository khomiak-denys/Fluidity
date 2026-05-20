import 'package:flutter_test/flutter_test.dart';
import 'package:fluidity/ui/drink_meta.dart';

void main() {
  test('drinkTypeIcons uses expected emoji escapes', () {
    expect(drinkTypeIcons['glass'], '\u{1F95B}');
    expect(drinkTypeIcons['bottle'], '\u{1F37C}');
    expect(drinkTypeIcons['cup'], '\u{2615}');
  });

  test('drinkTypeLabels maps known keys', () {
    expect(drinkTypeLabels['glass'], 'Glass');
    expect(drinkTypeLabels['bottle'], 'Bottle');
    expect(drinkTypeLabels['cup'], 'Cup');
  });
}