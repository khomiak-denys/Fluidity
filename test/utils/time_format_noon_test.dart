import 'package:flutter_test/flutter_test.dart';
import 'package:fluidity/utils/time_format.dart';

void main() {
  test('formatHm formats noon correctly', () {
    final dt = DateTime(2020, 1, 1, 12, 34);
    expect(formatHm(dt), '12:34');
  });
}
