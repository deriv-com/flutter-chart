// import './drawing.dart';
import './base_two_point.dart';

/// segment is an implementation of a BaseTwoPoint drawing.
/// @name CIQ.Drawing.segment
/// @constructor


class Segment extends BaseTwoPoint {
  ///initializes
  Segment({String name = 'segment', bool dragToDraw = false})
      : super(configs: <String>['color', 'lineWidth', 'pattern'], name: name,
      dragToDraw: dragToDraw);

  /// drawing tool pattern
  String pattern = 'solid';

  // @override
  // void render(Canvas? context) {
  //   var panel = this.stx.panels[this.panelName];
  //   if (!panel) return;
  //   var x0 = this.stx.pixelFromTick(this.p0[0], panel.chart);
  //   var x1 = this.stx.pixelFromTick(this.p1[0], panel.chart);
  //   var y0 = this.stx.pixelFromValueAdjusted(panel, this.p0[0], this.p0[1]);
  //   var y1 = this.stx.pixelFromValueAdjusted(panel, this.p1[0], this.p1[1]);
  //
  //   var width = this.lineWidth;
  //   var color = this.getLineColor();
  //
  //   var parameters = {
  //     pattern: this.pattern,
  //     lineWidth: width
  //   };
  //   if (parameters.pattern == "none") parameters.pattern = 'solid';
  //   this.stx.plotLine(
  //       x0,
  //       x1,
  //       y0,
  //       y1,
  //       color,
  //       this.name,
  //       context,
  //       panel,
  //       parameters
  //   );
  //
  //   if (this.axisLabel && !this.repositioner) {
  //     if (name == 'horizontal') {
  //       this.stx.endClip();
  //       var txt = this.p0[1];
  //       if (panel.chart.transformFunc)
  //         txt = panel.chart.transformFunc(this.stx, panel.chart, txt);
  //       if (panel.yAxis.priceFormatter)
  //         txt = panel.yAxis.priceFormatter(this.stx, panel, txt);
  //       else
  //         txt = this.stx.formatYAxisPrice(txt, panel);
  //       this.stx.createYAxisLabel(panel, txt, y0, color);
  //       this.stx.startClip(panel.name);
  //     } else if (
  //     name == 'vertical' &&
  //         this.p0[0] >= 0 &&
  //         !this.stx.chart.xAxis.noDraw
  //     ) {
  //       // don't try to compute dates from before dataSet
  //       var dt, newDT;
  //       dt = this.stx.dateFromTick(this.p0[0], panel.chart, true);
  //       if (!CIQ.ChartEngine.isDailyInterval(this.stx.layout.interval)) {
  //         var milli = dt.getSeconds() * 1000 + dt.getMilliseconds();
  //         if (timezoneJS.Date && this.stx.displayZone) {
  //           // this converts from the quote feed timezone to the chart
  //           // specified time zone
  //           newDT = new timezoneJS.Date(dt.getTime(), this.stx.displayZone);
  //           dt = new Date(
  //               newDT.getFullYear(),
  //               newDT.getMonth(),
  //               newDT.getDate(),
  //               newDT.getHours(),
  //               newDT.getMinutes()
  //           );
  //           dt = new Date(dt.getTime() + milli);
  //         }
  //       } else {
  //         dt.setHours(0, 0, 0, 0);
  //       }
  //       var myDate = CIQ.mmddhhmm(CIQ.yyyymmddhhmm(dt));
  //
  //       if (panel.chart.xAxis.formatter) {
  //         myDate =
  //             panel.chart.xAxis.formatter(dt, this.name, null, null, myDate);
  //       } else if (this.stx.internationalizer) {
  //         var str;
  //         if (dt.getHours() !== 0 || dt.getMinutes ()
  //   !== 0) {
  //   str = this.stx.internationalizer.monthDay.format(dt);
  //   str += " " + this.stx.internationalizer.hourMinute.format(dt);
  //   } else {
  //   str = this.stx.internationalizer.yearMonthDay.format(dt);
  //   }
  //   myDate = str;
  //   }
  //
  //   this.stx.endClip();
  //   this.stx.createXAxisLabel({
  //   panel: panel,
  //   txt: myDate,
  //   x: x0,
  //   backgroundColor: color,
  //   color: null,
  //   pointed: true,
  //   padding: 2
  //   });
  //   this.stx.startClip(panel.name);
  //   }
  //   }
  //   if (
  //   this.highlighted &&
  //   this.name != "horizontal" &&
  //   this.name != "vertical"
  //   ) {
  //   var p0Fill = this.highlighted == "p0" ? true : false;
  //   var p1Fill = this.highlighted == "p1" ? true : false;
  //   littleCircle(context, x0, y0, fill: p0Fill);
  //   littleCircle(context, x1, y1, fill: p1Fill);
  //   }
  // }
  //
  // @override
  // void abort({bool? forceClear}) {
  //   this.stx.setMeasure(null, null, null, null, false);
  // }
  //
  // @override
  // dynamic intersected(num? tick, num? value, dynamic box) {
  //   if (!this.p0 || !this.p1)
  //     return null; // in case invalid drawing (such as from panel that
  //   // no longer exists)
  //   var name = this.name;
  //   if (name != "horizontal" && name != "vertical" && name != "gartley") {
  //     var pointsToCheck = { 0: this.p0, 1: this.p1};
  //     for (var pt in pointsToCheck) {
  //       if (
  //       pointIntersection(pointsToCheck[pt][0], pointsToCheck[pt][1], box)
  //       ) {
  //         highlighted = "p" + pt;
  //         return {
  //           action: "drag",
  //           point: "p" + pt
  //         };
  //       }
  //     }
  //   }
  //   if (name == "horizontal" || name == "vertical") name = "line";
  //   var isIntersected = this.lineIntersection(tick, value, box, name);
  //   if (isIntersected) {
  //     highlighted = true;
  //     // This object will be used for repositioning
  //     return {
  //       action: "move",
  //       p0: CIQ.clone(this.p0),
  //       p1: CIQ.clone(this.p1),
  //       tick: tick, // save original tick
  //       value: value // save original value
  //     };
  //   }
  //   return null;
  // }
  //
  // @override
  // void copyConfig({bool withPreferences = false}) {
  //   Drawing._copyConfig(this, withPreferences: withPreferences);
  //   if (pattern == 'none' && !configs.contains('fillColor')) {
  //     pattern = 'solid';
  //   }
  // }

  /// Reconstruct a segment
  /// @memberOf CIQ.Drawing.segment
  /// @param  {CIQ.ChartEngine} stx The chart object
  /// @param  {object} [obj] A drawing descriptor
  /// @param {string} [obj.col] The line color
  /// @param {string} [obj.pnl] The panel name
  /// @param {string} [obj.ptrn] Optional pattern for line "solid","dotted",
  /// "dashed". Defaults to solid.
  /// @param {number} [obj.lw] Optional line width. Defaults to 1.
  /// @param {number} [obj.v0] Value (price) for the first point
  /// @param {number} [obj.v1] Value (price) for the second point
  /// @param {number} [obj.d0] Date (string form) for the first point
  /// @param {number} [obj.d1] Date (string form) for the second point
  /// @param {number} [obj.tzo0] Offset of UTC from d0 in minutes
  /// @param {number} [obj.tzo1] Offset of UTC from d1 in minutes

  // @override
  // void reconstruct(dynamic stx, dynamic obj) {
  //   this.stx = stx;
  //   this.color = obj.col;
  //   this.panelName = obj.pnl;
  //   this.pattern = obj.ptrn;
  //   this.lineWidth = obj.lw;
  //   this.d0 = obj.d0;
  //   this.d1 = obj.d1;
  //   this.tzo0 = obj.tzo0;
  //   this.tzo1 = obj.tzo1;
  //   this.v0 = obj.v0;
  //   this.v1 = obj.v1;
  //   this.adjust();
  // }
  //
  // @override
  // dynamic serialize() =>
  //     {
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
  //     }
}

