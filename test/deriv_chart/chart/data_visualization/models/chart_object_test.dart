import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/barrier_objects.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BarrierObject', () {
    test('Barrier with epoch values isOnEpochRange and isOnValueRange', () {
      const BarrierObject barrierObject =
          BarrierObject(leftEpoch: 10, rightEpoch: 20, value: 10.2);

      expect(barrierObject.isOnEpochRange(5, 9), false);

      // Right side partially visible
      expect(barrierObject.isOnEpochRange(5, 11), true);

      // Fully visible
      expect(barrierObject.isOnEpochRange(5, 21), true);

      // Covers the chart visible range
      expect(barrierObject.isOnEpochRange(12, 18), true);

      // Left side partially visible
      expect(barrierObject.isOnEpochRange(15, 21), true);

      expect(barrierObject.isOnEpochRange(21, 24), false);

      expect(barrierObject.isOnValueRange(5, 9), false);
      expect(barrierObject.isOnValueRange(5, 11), true);
      expect(barrierObject.isOnValueRange(11, 13), false);
    });

    test('Horizontal Barrier without epoch isOnEpochRange and isOnValueRange',
        () {
      const BarrierObject hBarrierObject = BarrierObject(value: 10.2);

      // A horizontal line which will be visible in the entire x-axis view port
      expect(hBarrierObject.isOnEpochRange(5, 9), true);
      expect(hBarrierObject.isOnEpochRange(5, 11), true);
      expect(hBarrierObject.isOnEpochRange(5, 21), true);
      expect(hBarrierObject.isOnEpochRange(15, 21), true);
      expect(hBarrierObject.isOnEpochRange(21, 24), true);

      expect(hBarrierObject.isOnValueRange(5, 9), false);
      expect(hBarrierObject.isOnValueRange(5, 11), true);
      expect(hBarrierObject.isOnValueRange(11, 13), false);
    });

    test('Vertical Barrier isOnEpochRange and isOnValueRange', () {
      const BarrierObject barrierObject = VerticalBarrierObject(10);

      expect(barrierObject.isOnEpochRange(5, 9), false);
      expect(barrierObject.isOnEpochRange(5, 11), true);
      expect(barrierObject.isOnEpochRange(5, 21), true);
      expect(barrierObject.isOnEpochRange(15, 21), false);
      expect(barrierObject.isOnEpochRange(21, 24), false);

      expect(barrierObject.isOnValueRange(5, 9), true);
      expect(barrierObject.isOnValueRange(5, 11), true);
      expect(barrierObject.isOnValueRange(11, 13), true);
    });
  });
}
