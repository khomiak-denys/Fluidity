# Testing

## Running tests

```bash
flutter test
```

## Running a single test file

```bash
flutter test test/utils/drink_meta_test.dart
```

## Running tests by name

```bash
flutter test --plain-name "formatHm"
```

## Fail fast

```bash
flutter test --fail-fast
```

## Coverage

```bash
flutter test --coverage
```

Coverage output is written to `coverage/lcov.info`.

## Widget tests

```bash
flutter test test/home_list_count_test.dart
```