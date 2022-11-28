// import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/segment.dart';
//
// /// Line drawing tool. A line is a vector defined by two points that is infinite in both directions.
// /// It inherits its properties from {@link CIQ.Drawing.segment}.
//
// class LineDrawing extends Segment {
//   LineDrawing() : super(name: 'line', dragToDraw: false);
//
//
//   /// calculate line vector
//   void calculateOuterSet(dynamic panel) {
//     if (this.p0[0] == this.p1[0] ||
//         this.p0[1] == this.p1[1] ||
//         CIQ.ChartEngine.isDailyInterval(this.stx.layout.interval)) {
//       return;
//     }
//
//     var vector = {
//       x0: this.p0[0],
//       y0: this.p0[1],
//       x1: this.p1[0],
//       y1: this.p1[1]
//     };
//     if (vector.x0 > vector.x1) {
//       vector = {x0: this.p1[0], y0: this.p1[1], x1: this.p0[0], y1: this.p0[1]};
//     }
//
//     var earlier = vector.x0 - 1000;
//     var later = vector.x1 + 1000;
//
//     this.v0B = CIQ.yIntersection(vector, earlier);
//     this.v1B = CIQ.yIntersection(vector, later);
//     this.d0B = this.stx.dateFromTick(earlier, panel.chart);
//     this.d1B = this.stx.dateFromTick(later, panel.chart);
//   }
//
//   bool click(dynamic context, dynamic tick, dynamic value) {
//     var panel = this.stx.panels[this.panelName];
//     if (!panel) return;
//     this.copyConfig();
//     if (!this.penDown) {
//       this.setPoint(0, tick, value, panel.chart);
//       this.penDown = true;
//       return false;
//     }
//
//     /// if the user accidentally double clicks in rapid fashion
//     if (this.accidentalClick(tick, value)) return this.dragToDraw;
//     this.setPoint(1, tick, value, panel.chart);
//     this.calculateOuterSet(panel);
//     this.penDown = false;
//     return true; // kernel will call render after this
//   }
//
//   /// Reconstruct a line
//   /// @param  {CIQ.ChartEngine} stx The chart object
//   /// @param  {object} [obj] A drawing descriptor
//   /// @param {string} [obj.col] The line color
//   /// @param {string} [obj.pnl] The panel name
//   /// @param {string} [obj.ptrn] Optional pattern for line "solid","dotted","dashed". Defaults to solid.
//   /// @param {number} [obj.lw] Optional line width. Defaults to 1.
//   /// @param {number} [obj.v0] Value (price) for the first point
//   /// @param {number} [obj.v1] Value (price) for the second point
//   /// @param {number} [obj.d0] Date (string form) for the first point
//   /// @param {number} [obj.d1] Date (string form) for the second point
//   /// @param {number} [obj.v0B] Computed outer Value (price) for the first point if original drawing was on intraday but now displaying on daily
//   /// @param {number} [obj.v1B] Computed outer Value (price) for the second point if original drawing was on intraday but now displaying on daily
//   /// @param {number} [obj.d0B] Computed outer Date (string form) for the first point if original drawing was on intraday but now displaying on daily
//   /// @param {number} [obj.d1B] Computed outer Date (string form) for the second point if original drawing was on intraday but now displaying on daily
//   /// @param {number} [obj.tzo0] Offset of UTC from d0 in minutes
//   /// @param {number} [obj.tzo1] Offset of UTC from d1 in minutes
//   /// @memberOf CIQ.Drawing.line
//
//   void reconstruct(dynamic stx, dynamic obj) {
//     this.stx = stx;
//     this.color = obj.col;
//     this.panelName = obj.pnl;
//     this.pattern = obj.ptrn;
//     this.lineWidth = obj.lw;
//     this.v0 = obj.v0;
//     this.v1 = obj.v1;
//     this.d0 = obj.d0;
//     this.d1 = obj.d1;
//     this.tzo0 = obj.tzo0;
//     this.tzo1 = obj.tzo1;
//     if (obj.d0B) {
//       this.d0B = obj.d0B;
//       this.d1B = obj.d1B;
//       this.v0B = obj.v0B;
//       this.v1B = obj.v1B;
//     }
//     this.adjust();
//   }
//
//   dynamic serialize() {
//     var obj = {
//       name: this.name,
//       pnl: this.panelName,
//       col: this.color,
//       ptrn: this.pattern,
//       lw: this.lineWidth,
//       d0: this.d0,
//       d1: this.d1,
//       tzo0: this.tzo0,
//       tzo1: this.tzo1,
//       v0: this.v0,
//       v1: this.v1
//     };
//     if (this.d0B) {
//       obj.d0B = this.d0B;
//       obj.d1B = this.d1B;
//       obj.v0B = this.v0B;
//       obj.v1B = this.v1B;
//     }
//     return obj;
//   }
//
//   void adjust() {
//     var panel = this.stx.panels[this.panelName];
//     if (!panel) return;
//     this.setPoint(0, this.d0, this.v0, panel.chart);
//     this.setPoint(1, this.d1, this.v1, panel.chart);
//
//     /// Use outer set if original drawing was on intraday but now displaying on daily
//     if (CIQ.ChartEngine.isDailyInterval(this.stx.layout.interval) && this.d0B) {
//       this.setPoint(0, this.d0B, this.v0B, panel.chart);
//       this.setPoint(1, this.d1B, this.v1B, panel.chart);
//     }
//   }
// }
