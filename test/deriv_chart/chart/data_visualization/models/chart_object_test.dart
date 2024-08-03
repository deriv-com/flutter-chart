// ignore_for_file: always_specify_types

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/barrier_objects.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BarrierObject', () {
    test('Barrier with epoch values isOnEpochRange and isOnValueRange', () {
      const int leftEpoch = 30;
      const int rightEpoch = 50;

      // considering buffer distance as well which is half of the visible range
      // Visible range: 30 - 50, Safe distance: 10
      //                          visible range
      //              buffer zone                buffer zone
      //                        |               |
      //                |       |               |        |
      //  0  5  10  15  20  25  30  35  40  45  50  55  60  65  70  75  80

      // Completely in range.
      const object1 = BarrierObject(leftEpoch: 35, rightEpoch: 40, quote: 10);
      expect(object1.isOnEpochRange(leftEpoch, rightEpoch), true);

      // Covers the chart visible range.
      const object2 = BarrierObject(leftEpoch: 25, rightEpoch: 55, quote: 10);
      expect(object2.isOnEpochRange(leftEpoch, rightEpoch), true);

      // Right side of the object on left buffer zone.
      const object3 = BarrierObject(leftEpoch: 15, rightEpoch: 25, quote: 10);
      expect(object3.isOnEpochRange(leftEpoch, rightEpoch), true);

      // Outside of the buffer zone on the left.
      const object4 = BarrierObject(leftEpoch: 5, rightEpoch: 15, quote: 10);
      expect(object4.isOnEpochRange(leftEpoch, rightEpoch), false);

      // Left side of the object on the right buffer zone.
      const object5 = BarrierObject(leftEpoch: 55, rightEpoch: 65, quote: 10);
      expect(object5.isOnEpochRange(leftEpoch, rightEpoch), true);

      // Outside of the buffer zone on the right.
      const object6 = BarrierObject(leftEpoch: 65, rightEpoch: 70, quote: 10);
      expect(object6.isOnEpochRange(leftEpoch, rightEpoch), false);
    });

    test('Horizontal Barrier without epoch isOnEpochRange and isOnValueRange',
        () {
      const BarrierObject hBarrierObject = BarrierObject(quote: 10.2);

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

      // Inside visible range.
      expect(barrierObject.isOnEpochRange(5, 11), true);

      // In right buffer zone.
      expect(barrierObject.isOnEpochRange(5, 9), true);

      // Inside left buffer zone.
      expect(barrierObject.isOnEpochRange(11, 16), true);

      // Outside on the left.
      expect(barrierObject.isOnEpochRange(15, 18), false);

      // Outside on the right.
      expect(barrierObject.isOnEpochRange(1, 6), false);
    });
  });
}
