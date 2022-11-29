// import 'package:flutter/cupertino.dart';

import './drawing.dart';

/// Base class for drawings that require two mouse clicks.
/// Override as required.
/// @constructor
/// @name  CIQ.Drawing.BaseTwoPoint

class BaseTwoPoint extends Drawing {
  ///initializes
  BaseTwoPoint(
      {required this.configs, String name = '', bool dragToDraw = false})
      : super(name: name, dragToDraw: dragToDraw);

  /// drawing configs
  List<String> configs = <String>[];

  /// Intersection is based on a hypothetical box that follows a user's tap.
  /// An intersection occurs when the box crosses over the drawing.
  /// The type should be "segment", "ray" or "line" depending on whether
  /// the drawing extends infinitely in any or both directions. Radius
  /// determines the size of the box in pixels and is determined by the
  /// kernel depending on the user interface (mouse, touch, etc.).
  ///
  /// @param {number} tick Tick in the `dataSet`.
  /// @param {number} value Value at the cursor position.
  /// @param {object} box x0, y0, x1, y1, r representing an area around the
  /// cursor, including the radius.
  /// @param {string} type Determines how the line should be treated
  /// (as segment, ray, or line) when	finding an intersection.
  /// @param {number[]} [p0] The x/y coordinates of the first endpoint
  /// of the line that is tested for intersection with `box`.
  /// @param {number[]} [p1] The x/y coordinates of the second endpoint
  /// of the line that is tested for	intersection with `box`.
  /// @param {boolean} [isPixels] Indicates that box values are in pixel
  /// values.
  /// @return {boolean} True if the line intersects the box; otherwise, false.
  ///
  /// @memberOf CIQ.Drawing.BaseTwoPoint

  // dynamic lineIntersection(num? tick,
  //     num? value,
  //     dynamic box,
  //     String? type,
  //     num? p0,
  //     num? p1,
  //     {bool isPixels = false}) {
  //   if (!p0) p0 = this.p0;
  //   if (!p1) p1 = this.p1;
  //   var stx = this.stx;
  //   if (!(p0 && p1)) return false;
  //   var pixelBox = CIQ.convertBoxToPixels(stx, this.panelName, box);
  //   if (pixelBox.x0 === undefined) return false;
  //   var pixelPoint = { x0: p0[0], x1: p1[0], y0: p0[1], y1: p1[1]};
  //   if (!isPixels)
  //     pixelPoint = CIQ.convertBoxToPixels(stx, this.panelName, pixelPoint);
  //   return CIQ.boxIntersects(
  //       pixelBox.x0,
  //       pixelBox.y0,
  //       pixelBox.x1,
  //       pixelBox.y1,
  //       pixelPoint.x0,
  //       pixelPoint.y0,
  //       pixelPoint.x1,
  //       pixelPoint.y1,
  //       type
  //   );
  // }

  /// Determine whether the tick/value lies within the theoretical box
  /// outlined by this drawing's two points.
  ///
  /// @param {number} tick Tick in the `dataSet`.
  /// @param {number} value Value at position.
  /// @param {object} box x0, y0, x1, y1, r representing an area
  /// around the cursor, including the	radius.
  /// @return {boolean} True if box intersects the drawing.
  ///
  /// @memberof CIQ.Drawing.BaseTwoPoint

  // bool boxIntersection(num? tick,
  //     num? value,
  //     dynamic box) {
  //   if (!this.p0 || !this.p1) {
  //     return false;
  //   }
  //   if (
  //   box.x0 > Math.max(this.p0[0], this.p1[0]) ||
  //       box.x1 < Math.min(this.p0[0], this.p1[0])
  //   ) {
  //     return false;
  //   }
  //   if (
  //   box.y1 > Math.max(this.p0[1], this.p1[1]) ||
  //       box.y0 < Math.min(this.p0[1], this.p1[1])
  //   ) {
  //     return false;
  //   }
  //   return true;
  // }

  /// Any two-point drawing that results in a drawing that is less
  /// than 10 pixels can safely be assumed to be an accidental click.
  /// Such drawings are so small that they are difficult to highlight
  /// and delete, so we won't allow them.
  ///
  /// Note: it is very important to use pixelFromValueAdjusted()
  /// rather than pixelFromPrice(). This will ensure that saved drawings
  /// always render correctly when a chart is adjusted or transformed
  /// for display.
  /// @param {number} tick Tick in the `dataSet`.
  /// @param {number} value Value at position.
  /// @memberOf CIQ.Drawing.BaseTwoPoint

  // dynamic accidentalClick(num? tick, num? value) {
  //   var panel = this.stx.panels[this.panelName];
  //   var x0 = this.stx.pixelFromTick(this.p0[0], panel.chart);
  //   var x1 = this.stx.pixelFromTick(tick, panel.chart);
  //   var y0 = this.stx.pixelFromValueAdjusted(panel, this.p0[0], this.p0[1]);
  //   var y1 = this.stx.pixelFromValueAdjusted(panel, tick, value);
  //   var h = Math.abs(x1 - x0);
  //   var v = Math.abs(y1 - y0);
  //   var length = Math.sqrt(h * h + v * v);
  //   if (length < 10) {
  //     penDown = false;
  //     if (dragToDraw) this.stx.undo();
  //     return true;
  //   }
  // }

  /// Value will be the actual underlying, unadjusted value for the drawing.
  /// Any adjustments or transformations are reversed out by the kernel.
  /// Internally, drawings should store their raw data (date and value)
  /// so that they can be rendered on charts with different layouts,
  /// axis, etc.
  /// @param {CanvasRenderingContext2D} Canvas context on which to render.
  /// @param {number} tick Tick in the `dataSet`.
  /// @param {number} value Value at position.
  /// @memberOf CIQ.Drawing.BaseTwoPoint
  // @override
  // bool click(Canvas? context, num? tick, num? value) {
  //   copyConfig();
  //   var panel = this.stx.panels[this.panelName];
  //   if (!penDown) {
  //     setPoint(0, tick, value, panel.chart);
  //     this.penDown = true;
  //     return false;
  //   }
  //   if (accidentalClick(tick, value)) {
  //     return dragToDraw;
  //   }
  //
  //   setPoint(1, tick, value, panel.chart);
  //   penDown = false;
  //   return true; // kernel will call render after this
  // }

  /// Default adjust function for BaseTwoPoint drawings
  /// @memberOf CIQ.Drawing.BaseTwoPoint
  // @override
  // void adjust() {
  //   /// If the drawing's panel doesn't exist then we'll check to see
  //   /// whether the panel has been added. If not then there's no way
  //   /// to adjust
  //   var panel = this.stx.panels[this.panelName];
  //   if (!panel) {
  //     return;
  //   }
  //   setPoint(0, this.d0, this.v0, panel.chart);
  //   setPoint(1, this.d1, this.v1, panel.chart);
  // }

  /// Default move function for BaseTwoPoint drawings
  /// @param {CanvasRenderingContext2D} Canvas context on which to render.
  /// @param {number} tick Tick in the `dataSet`.
  /// @param {number} value Value at position.
  /// @memberOf CIQ.Drawing.BaseTwoPoint
  // @override
  // void move(Canvas? context, num? tick, num? value) {
  //   if (!penDown) {
  //     return;
  //   }
  //
  //   copyConfig();
  //   this.p1 = [tick, value];
  //   render(context);
  // }

  /// Default measure function for BaseTwoPoint drawings
  /// @memberOf CIQ.Drawing.BaseTwoPoint
  // @override
  // void measure() {
  //   if (this.p0 && this.p1) {
  //     this.stx.setMeasure(
  //         this.p0[1],
  //         this.p1[1],
  //         this.p0[0],
  //         this.p1[0],
  //         true,
  //         name
  //     );
  //     var mSticky = this.stx.controls.mSticky;
  //     var mStickyInterior = mSticky &&
  //         mSticky.querySelector('.mStickyInterior');
  //     if (mStickyInterior) {
  //       var lines = [];
  //       lines.push(CIQ.capitalize(this.name));
  //       if (getYValue != null)
  //         lines.push(this.field || this.stx.defaultPlotField || "Close");
  //       lines.push(mStickyInterior.innerHTML);
  //       mStickyInterior.innerHTML = lines.join('<br>');
  //     }
  //   }
  // }
  //
  // @override
  // void reposition(dynamic context, dynamic repositioner, num? tick,
  //     num? value) {
  //   if (!repositioner) {
  //     return;
  //   }
  //   var panel = this.stx.panels[this.panelName];
  //   var tickDiff = repositioner.tick - tick;
  //   var valueDiff = repositioner.value - value;
  //   if (repositioner.action == 'move') {
  //     setPoint(
  //         0,
  //         repositioner.p0[0] - tickDiff,
  //         repositioner.p0[1] - valueDiff,
  //         panel.chart
  //     );
  //     setPoint(
  //         1,
  //         repositioner.p1[0] - tickDiff,
  //         repositioner.p1[1] - valueDiff,
  //         panel.chart
  //     );
  //     render(context);
  //   } else if (repositioner.action == 'drag') {
  //     this[repositioner.point] = [tick, value];
  //     setPoint(0, this.p0[0], this.p0[1], panel.chart);
  //     setPoint(1, this.p1[0], this.p1[1], panel.chart);
  //     render(context);
  //   }
  // }

  /// draw drop zone
  // void drawDropZone(Canvas? context,
  //     num? hBound1,
  //     num?hBound2,
  //     num?leftBound,
  //     num?rightBound) {
  //   var panel = this.stx.panels[this.panelName];
  //   if (!panel) return;
  //   var x0 = panel.left;
  //   var x1 = panel.width;
  //   if (leftBound || leftBound === 0)
  //     x0 = this.stx.pixelFromTick(leftBound, panel.chart);
  //   if (rightBound || rightBound === 0)
  //     x1 = this.stx.pixelFromTick(rightBound, panel.chart);
  //   var y0 = this.stx.pixelFromPrice(hBound1, panel);
  //   var y1 = this.stx.pixelFromPrice(hBound2, panel);
  //   context.fillStyle = '#008000';
  //   context.globalAlpha = 0.2;
  //   context.fillRect(x0, y0, x1 - x0, y1 - y0);
  //   context.globalAlpha = 1;
  // }
}
