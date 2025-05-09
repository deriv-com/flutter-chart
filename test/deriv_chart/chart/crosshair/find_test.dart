import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/find.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('findClosestToEpoch should', () {
    test('return null if list is empty', () {
      expect(
        findClosestToEpoch(100, []),
        equals(null),
      );
    });
    test('return tick with exact epoch if present', () {
      final tick100 = Tick(epoch: 100, quote: 0);
      final tick200 = Tick(epoch: 200, quote: 0);
      final tick300 = Tick(epoch: 300, quote: 0);

      expect(
        findClosestToEpoch(
          100,
          [tick100, tick200, tick300],
        ),
        equals(tick100),
      );
      expect(
        findClosestToEpoch(
          200,
          [tick100, tick200, tick300],
        ),
        equals(tick200),
      );
      expect(
        findClosestToEpoch(
          300,
          [tick100, tick200, tick300],
        ),
        equals(tick300),
      );
    });
    test('return tick with closest epoch if exact isn\'t present', () {
      final tick100 = Tick(epoch: 100, quote: 0);
      final tick110 = Tick(epoch: 110, quote: 0);
      final tick120 = Tick(epoch: 120, quote: 0);
      final tick130 = Tick(epoch: 130, quote: 0);
      final tick140 = Tick(epoch: 140, quote: 0);

      expect(
        findClosestToEpoch(
          101,
          [tick100, tick110, tick120, tick130, tick140],
        ),
        equals(tick100),
      );
    });
  });

  group('findEpochIndex should', () {
    test('throw exception if list is empty', () {
      expect(
        () => findEpochIndex(0, <Tick>[]),
        throwsArgumentError,
      );
    });
    test('return index of matching tick', () {
      expect(
        findEpochIndex(1, <Tick>[
          Tick(epoch: 1, quote: 0),
          Tick(epoch: 2, quote: 0),
          Tick(epoch: 3, quote: 0),
        ]),
        0,
      );
      expect(
        findEpochIndex(2, <Tick>[
          Tick(epoch: 1, quote: 0),
          Tick(epoch: 2, quote: 0),
        ]),
        1,
      );
      expect(
        findEpochIndex(4, <Tick>[
          Tick(epoch: 1, quote: 0),
          Tick(epoch: 2, quote: 0),
          Tick(epoch: 3, quote: 0),
          Tick(epoch: 4, quote: 0),
        ]),
        3,
      );
      expect(
        findEpochIndex(300, <Tick>[
          Tick(epoch: 100, quote: 0),
          Tick(epoch: 200, quote: 0),
          Tick(epoch: 300, quote: 0),
          Tick(epoch: 400, quote: 0),
        ]),
        2,
      );
    });
    test('return -0.5 if epoch is before the 1st tick', () {
      expect(
        findEpochIndex(100, <Tick>[
          Tick(epoch: 300, quote: 0),
          Tick(epoch: 400, quote: 0),
          Tick(epoch: 500, quote: 0),
        ]),
        -0.5,
      );
    });
    test('return 0.5 if epoch is between 1st and 2nd', () {
      expect(
        findEpochIndex(350, <Tick>[
          Tick(epoch: 300, quote: 0),
          Tick(epoch: 400, quote: 0),
          Tick(epoch: 500, quote: 0),
        ]),
        0.5,
      );
    });
    test('return 1.5 if epoch is between 2nd and 3rd', () {
      expect(
        findEpochIndex(450, <Tick>[
          Tick(epoch: 300, quote: 0),
          Tick(epoch: 400, quote: 0),
          Tick(epoch: 500, quote: 0),
        ]),
        1.5,
      );
    });
    test('return 2.5 if epoch is after 3rd', () {
      expect(
        findEpochIndex(128, <Tick>[
          Tick(epoch: 123, quote: 0),
          Tick(epoch: 125, quote: 0),
          Tick(epoch: 127, quote: 0),
        ]),
        2.5,
      );
    });
  });
}
