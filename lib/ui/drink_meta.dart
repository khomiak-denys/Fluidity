/// Mapping of drink type identifiers to emoji icons.
///
/// Emoji values are stored as Unicode escapes (e.g. `\u{1F95B}`) to ensure
/// source files remain encoding-safe across different platforms and Git
/// client configurations.
const Map<String, String> drinkTypeIcons = {
  'glass': '\u{1F95B}',
  'bottle': '\u{1F37C}',
  'cup': '\u{2615}',
};

const Map<String, String> drinkTypeLabels = {
  'glass': 'Glass',
  'bottle': 'Bottle',
  'cup': 'Cup',
};
