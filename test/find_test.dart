import 'package:flutter_test/flutter_test.dart';

import 'package:deriv_chart/src/logic/find.dart';
import 'package:deriv_chart/src/models/tick.dart';

void main() {
  group('findClosestToEpoch should', () {
    test('return null if list is empty', () {
      expect(
        findClosestToEpoch(100, <Tick>[]),
        equals(null),
      );
    });
    test('return tick with exact epoch if present', () {
      const Tick tick100 = Tick(epoch: 100, quote: 0);
      const Tick tick200 = Tick(epoch: 200, quote: 0);
      const Tick tick300 = Tick(epoch: 300, quote: 0);

      expect(
        findClosestToEpoch(
          100,
          <Tick>[tick100, tick200, tick300],
        ),
        equals(tick100),
      );
      expect(
        findClosestToEpoch(
          200,
          <Tick>[tick100, tick200, tick300],
        ),
        equals(tick200),
      );
      expect(
        findClosestToEpoch(
          300,
          <Tick>[tick100, tick200, tick300],
        ),
        equals(tick300),
      );
    });
    test('return tick with closest epoch if exact isn\'t present', () {
      const Tick tick100 = Tick(epoch: 100, quote: 0);
      const Tick tick110 = Tick(epoch: 110, quote: 0);
      const Tick tick120 = Tick(epoch: 120, quote: 0);
      const Tick tick130 = Tick(epoch: 130, quote: 0);
      const Tick tick140 = Tick(epoch: 140, quote: 0);

      expect(
        findClosestToEpoch(
          101,
          <Tick>[tick100, tick110, tick120, tick130, tick140],
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
        findEpochIndex(1, const <Tick>[
          Tick(epoch: 1, quote: 0),
          Tick(epoch: 2, quote: 0),
          Tick(epoch: 3, quote: 0),
        ]),
        0,
      );
      expect(
        findEpochIndex(2, const <Tick>[
          Tick(epoch: 1, quote: 0),
          Tick(epoch: 2, quote: 0),
        ]),
        1,
      );
      expect(
        findEpochIndex(4, const <Tick>[
          Tick(epoch: 1, quote: 0),
          Tick(epoch: 2, quote: 0),
          Tick(epoch: 3, quote: 0),
          Tick(epoch: 4, quote: 0),
        ]),
        3,
      );
      expect(
        findEpochIndex(300, const <Tick>[
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
        findEpochIndex(100, const <Tick>[
          Tick(epoch: 300, quote: 0),
          Tick(epoch: 400, quote: 0),
          Tick(epoch: 500, quote: 0),
        ]),
        -0.5,
      );
    });
    test('return 0.5 if epoch is between 1st and 2nd', () {
      expect(
        findEpochIndex(350, const <Tick>[
          Tick(epoch: 300, quote: 0),
          Tick(epoch: 400, quote: 0),
          Tick(epoch: 500, quote: 0),
        ]),
        0.5,
      );
    });
    test('return 1.5 if epoch is between 2nd and 3rd', () {
      expect(
        findEpochIndex(450, const <Tick>[
          Tick(epoch: 300, quote: 0),
          Tick(epoch: 400, quote: 0),
          Tick(epoch: 500, quote: 0),
        ]),
        1.5,
      );
    });
    test('return 2.5 if epoch is after 3rd', () {
      expect(
        findEpochIndex(128, const <Tick>[
          Tick(epoch: 123, quote: 0),
          Tick(epoch: 125, quote: 0),
          Tick(epoch: 127, quote: 0),
        ]),
        2.5,
      );
    });
  });
}
