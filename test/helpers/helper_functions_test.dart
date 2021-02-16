import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('getEnumValue function', () {
    test('Gets enum value as string without enum prefix', () {
      expect(getEnumValue(MockEnum.type1), 'type1');
    });
  });
}

enum MockEnum {
  type1,
  type2,
}
