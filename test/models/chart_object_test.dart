import 'package:deriv_chart/src/models/barrier_objects.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BarrierObject', () {
    test('Barrier with epoch values isOnEpochRange', () {
      final BarrierObject barrierObject = BarrierObject(10, 20, 10);

      expect(barrierObject.isOnEpochRange(5, 9), false);

      // Right side partially visible
      expect(barrierObject.isOnEpochRange(5, 11), true);

      // Fully visible
      expect(barrierObject.isOnEpochRange(5, 21), true);

      // Left side partially visible
      expect(barrierObject.isOnEpochRange(15, 21), true);

      expect(barrierObject.isOnEpochRange(21, 24), false);
    });

    test('Horizontal Barrier without epoch isOnEpochRange', () {
      final BarrierObject hBarrierObject = BarrierObject(null, null, 10);

      // A horizontal line which will be visible in the entire x-axis view port
      expect(hBarrierObject.isOnEpochRange(5, 9), true);
      expect(hBarrierObject.isOnEpochRange(5, 11), true);
      expect(hBarrierObject.isOnEpochRange(5, 21), true);
      expect(hBarrierObject.isOnEpochRange(15, 21), true);
      expect(hBarrierObject.isOnEpochRange(21, 24), true);
    });

    test('Vertical Barrier isOnEpochRange', () {
      final BarrierObject barrierObject = VerticalBarrierObject(10, null);

      expect(barrierObject.isOnEpochRange(5, 9), false);
      expect(barrierObject.isOnEpochRange(5, 11), true);
      expect(barrierObject.isOnEpochRange(5, 21), true);
      expect(barrierObject.isOnEpochRange(15, 21), false);
      expect(barrierObject.isOnEpochRange(21, 24), false);
    });
  });
}
