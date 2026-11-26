import 'package:flutter_test/flutter_test.dart';

import 'package:clan_unite/utils/validators.dart';

void main() {
  group('Validators.validateName', () {
    test('accepts names containing apostrophes and hyphens', () {
      expect(Validators.validateName("O'Neil-Smith"), isNull);
    });

    test('rejects names containing unsupported characters', () {
      expect(Validators.validateName('Clan123'), isNotNull);
    });
  });
}
