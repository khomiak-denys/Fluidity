import 'package:flutter_test/flutter_test.dart';
import 'package:fluidity/utils/time_format.dart';

void main() {
  test('formatHm returns HH:mm for given DateTime', () {
    final dt = DateTime(2020, 1, 1, 9, 5);
    expect(formatHm(dt), '09:05');
  });
}
