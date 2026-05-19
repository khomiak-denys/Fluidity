// Prefer using relative imports for this utility (e.g. `../utils/time_format.dart`) to
// avoid duplicate library instances caused by mixing `package:` and relative URIs.
String formatHm(DateTime dt) {
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}
