import 'package:flutter_test/flutter_test.dart';
import 'package:fluidity/utils/time_format.dart';

void main() {
  test('formatHm pads single-digit hour and minute', () {
    final dt = DateTime(2020, 1, 1, 7, 3);
    expect(formatHm(dt), '07:03');
  });
}
