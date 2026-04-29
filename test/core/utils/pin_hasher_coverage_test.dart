/// Coverage test for [PinHasher] — exercises the `FormatException` path
/// inside `_tryB64Decode` (line 213: `return null`) which is reached
/// when `verify` is called with a malformed PHC string whose base64
/// salt or hash segment is not valid base64.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/utils/pin_hasher.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PinHasher.verify with malformed hash', () {
    test(
      'returns false for a PHC string with an invalid base64 salt',
      () async {
        // A PHC-like string where the salt field is not valid base64.
        // This forces _tryB64Decode to catch a FormatException and return null,
        // which causes verify to return false.
        const malformedHash =
            r'$argon2id$v=19$m=65536,t=3,p=4$!!!not-valid-base64!!!'
            r'$AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';

        final result = await PinHasher.verify('1234', malformedHash);
        check(result).isFalse();
      },
    );

    test(
      'returns false for a PHC string with completely invalid format',
      () async {
        // A non-PHC garbage string.
        final result = await PinHasher.verify('0000', 'not-a-hash-at-all');
        check(result).isFalse();
      },
    );
  });
}
