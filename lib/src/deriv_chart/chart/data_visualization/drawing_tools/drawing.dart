import 'dart:developer';

import 'package:flutter/material.dart';

import './line_drawing.dart';

/// Model class to hold visible entries of `DataSeries` and keep track of their
/// [startIndex] and [endIndex] indices.


/// Base class for Drawing Tools. Use {@link CIQ.inheritsFrom} to build
/// a subclass for custom drawing tools.
/// The name of the subclass should be CIQ.Drawing.yourname.
/// Whenever CIQ.ChartEngine.currentVectorParameters.vectorType==yourname,
/// then your drawing tool will be the one that is enabled when the user
/// begins a drawing. Capitalization of yourname must be an exact match
/// otherwise the kernel will not be able to find your drawing tool.
///
/// Each of the CIQ.Drawing prototype functions may be overridden.
/// To create a functioning drawing tool you must override the functions
/// below that create alerts.
///
/// Drawing clicks are always delivered in *adjusted price*. That is,
/// if a stock has experienced splits then the drawing will not display
/// correctly on an unadjusted price chart unless this is considered during
/// the rendering process. Follow the templates to assure correct rendering
/// under both circumstances.
///
/// If no color is specified when building a drawing then color will be set
/// to "auto" and the chart will automatically display white or black
/// depending on the background.
///
/// **Permanent drawings:**<br>
/// To make a particular drawing permanent, set its `permanent` property to
/// `true` once created.
/// <br>Example: <br>
///  ```drawingObject.permanent=true;```
///
/// See {@tutorial Using and Customizing Drawing Tools} for more details.

class Drawing {
  /// initializes
  Drawing({this.name = '', this.dragToDraw = false});

  /// Set this to true to restrict drawing from being rendered on a study
  /// panel.
  /// This parameter may be set for all drawings, for a specific drawing type,
  /// or for a specific drawing instance. See examples.
  /// @memberOf CIQ.Drawing
  /// @example
  /// set drawing instance to chartsOnly. Only this one drawing will be
  /// affected
  /// drawing.chartsOnly=true;
  /// Set particular drawing prototype to chartsOnly. All drawings to type
  /// "difference" will be affected
  /// CIQ.Drawing["difference"].prototype.chartsOnly=true;
  /// Set all drawings to chartsOnly
  /// CIQ.Drawing.prototype.chartsOnly=true;
  bool chartsOnly = false;

  /// drawing color
  String color = '';

  /// drawing tool name
  String name = '';

  /// when in the midst of creating a drawing
  bool penDown = false;

  /// if a drawing is highlighted
  bool highlighted = false;

  /// get Y value
  num Function(num i)? getYValue;

  /// all existing drawing tools:
  Map<String, dynamic> drawingTools = <String, dynamic>{'line': LineDrawing};

  /// all points
  Map<String, dynamic> points = <String, dynamic>{
    /// first point
    'p0': null,

    /// second point
    'p1': null,

    /// third point
    'p2': null,

    /// Value (price) for the first point
    'v0': null,

    /// Value (price) for the second point
    'v1': null,

    /// Value (price) for the third point (if used)
    'v2': null,

    /// Date (string form) for the first point
    'd0': null,

    /// Date (string form) for the second point
    'd1': null,

    /// Date (string form) for the third point (if used)
    'd2': null,

    /// Offset of UTC from d0 in minutes
    'tzo0': null,

    /// Offset of UTC from d1 in minutes
    'tzo1': null,

    /// Offset of UTC from d2 in minutes (if used)
    'tzo2': null,
  };

  /// Since not all drawings have the same configuration parameters,
  /// this is a helper function intended to return the relevant drawing
  /// parameters and default settings for the requested drawing type.
  ///
  /// For example,  you can use the returning object as your template for
  /// creating the proper UI tool box for that particular drawing.
  /// Will you need a line width UI element, a fill color?, etc. Or you can
  /// use it to determine what values you should be setting if enabling
  /// a particular drawing type programmatically with specific properties.
  /// @param {CIQ.ChartEngine} stx Chart object
  /// @param {string} drawingName Name of drawing, e.g. "ray", "segment"
  /// @returns {object} Map of parameters used in the drawing type, with
  /// their current values
  /// @memberOf CIQ.Drawing
  /// @since 3.0.0

  // dynamic getDrawingParameters(dynamic stx, String? drawingName) {
  //   dynamic drawing;
  //   try {
  //     drawing = drawingTools[drawingName]();
  //   } catch (e) {}
  //   if (!drawing) {
  //     return null;
  //   }
  //   drawing.stx = stx;
  //   drawing.copyConfig(withPreferences: true);
  //   dynamic result = {};
  //   dynamic confs = drawing.configs;
  //   for (var c = 0; c < confs.length; c++) {
  //     result[confs[c]] = drawing[confs[c]];
  //   }
  //   dynamic style = stx.canvasStyle('stx_annotation');
  //   if (style && result.font) {
  //     result.font.size = style.fontSize;
  //     result.font.family = style.fontFamily;
  //     result.font.style = style.fontStyle;
  //     result.font.weight = style.fontWeight;
  //   }
  //   return result;
  // }

  /// Static method for saving drawing parameters to preferences.
  ///
  /// Values are stored in `stxx.preferences.drawings` and can be saved
  /// together with the rest of the chart preferences,
  /// which by default are placed in the browser's local storage under
  /// "myChartPreferences".
  /// @param {CIQ.ChartEngine} stx Chart object
  /// @param {string} toolName Name of drawing tool, e.g. "ray", "segment",
  /// "fibonacci"
  /// @memberOf CIQ.Drawing
  /// @since 6.0.0

  // static void saveConfig(dynamic stx, String? toolName) {
  //   if (!toolName) return;
  //   var preferences = stx.preferences;
  //   if (!preferences.drawings) preferences.drawings = {};
  //   preferences.drawings[toolName] = {};
  //   var tempDrawing = new CIQ.Drawing[toolName]();
  //   tempDrawing.stx = stx;
  //   Drawing._copyConfig(tempDrawing);
  //   tempDrawing.configs.forEach(function(config) {
  //   preferences.drawings[toolName][config] = tempDrawing[config];
  //   });
  //   stx.changeOccurred('preferences');
  // }

  /// Static method for restoring default drawing parameters, and removing
  /// custom preferences.
  ///
  /// @param {CIQ.ChartEngine} stx Chart object
  /// @param {string} toolName Name of active drawing tool, e.g. "ray",
  /// "segment", "fibonacci"
  /// @param {boolean} all True to restore default for all drawing objects.
  /// Otherwise only the active drawing object's defaults are restored.
  /// @memberOf CIQ.Drawing
  /// @since 6.0.0

  // static void restoreDefaultConfig(dynamic stx, String? toolName,
  //     {bool all = false}) {
  //   if (all)
  //     stx.preferences.drawings = null;
  //   else
  //     stx.preferences.drawings[toolName] = null;
  //   stx.changeOccurred("preferences");
  //   stx.currentVectorParameters = CIQ.clone(
  //       CIQ.ChartEngine.currentVectorParameters
  //   );
  //   stx.currentVectorParameters.vectorType = toolName;
  // }

  /// Static method to call optional initializeSettings instance method of
  /// the drawing whose name is passed in as an argument.
  /// @param {CIQ.ChartEngine} stx Chart object
  /// @param {string} drawingName Name of drawing, e.g. "ray", "segment",
  /// "fibonacci"
  /// @memberOf CIQ.Drawing
  /// @since 5.2.0 Calls optional instance function instead of doing all the
  /// work internally.

  // static void initializeSettings(dynamic stx, String? drawingName) {
  //   var drawing = CIQ.Drawing[drawingName];
  //   if (drawing) {
  //     var drawInstance = new drawing();
  //     if (drawInstance.initializeSettings) {
  //       drawInstance.initializeSettings(stx);
  //     }
  //   }
  // }

  /// Updates the drawing's field or panelName property to the passed in
  /// argument if the field of the drawing is "sourced" from the
  /// passed in name.
  ///
  /// This is used when moving a series or study, and there is a drawing
  /// based upon it.<br>
  /// It will be called based on the following occurrences:
  /// - Panel of series changed
  /// - Panel of study changed
  /// - Default panel of study changed due to field change
  /// - Outputs of study changed due to field change
  /// - Outputs of study changed due to name change (due to field of
  /// field change)
  /// @param {CIQ.ChartEngine} stx Chart object
  /// @param {string} name Name of study or symbol of series to match with
  /// @param {string} newName Name of new field to use for the drawing field
  /// if a name match is found
  /// @param {string} newPanel Name of new panel to use for the drawing
  /// if a name match is found, ignored if `newName`` is set
  /// @memberOf CIQ.Drawing
  /// @since 7.0.0

  // void updateSource(dynamic stx, String? name, String? newName,
  //     String? newPanel) {
  //   if (!name) return;
  //   var vectorChange = false;
  //   for (var dKey in stx.drawingObjects) {
  //     var drawing = stx.drawingObjects[dKey];
  //     if (!drawing.field) continue;
  //     if (newName) {
  //       // field change
  //       if (drawing.field == name) {
  //         drawing.field = newName;
  //         vectorChange = true;
  //       } else if (
  //       drawing.field.indexOf(name) > -1 &&
  //           drawing.field.indexOf(name + "-") == -1
  //       ) {
  //         drawing.field = drawing.field.replace(name, newName);
  //         vectorChange = true;
  //       }
  //     } else {
  //       // panel change
  //       if (drawing.field.split('-->')[0] == name ||
  //           drawing.panelName == name) {
  //         drawing.panelName = newPanel;
  //         vectorChange = true;
  //       }
  //     }
  //   }
  //   if (vectorChange) {
  //     stx.changeOccurred('vector');
  //   }
  // }

  /// Instance function used to copy the relevant drawing parameters
  /// into itself.
  /// It just calls the static function.
  /// @param {boolean} withPreferences set to true to return previously
  /// saved preferences
  /// @memberOf CIQ.Drawing
  /// @since 3.0.0

  // void copyConfig({bool withPreferences = false}) {
  //   Drawing._copyConfig(this, withPreferences: withPreferences);
  // }

  /// Static function used to copy the relevant drawing parameters into
  /// the drawing instance.
  /// Use this when overriding the Instance function, to perform basic copy
  /// before performing custom operations.
  /// @param {CIQ.Drawing} drawingInstance to copy into
  /// @param {boolean} withPreferences set to true to return previously
  /// saved preferences
  /// @memberOf CIQ.Drawing
  /// @since
  /// - 3.0.0
  /// - 6.0.0 Overwrites parameters with those stored in `preferences.drawings`.

  // static void _copyConfig(Drawing? drawingInstance,
  //     {bool withPreferences = false}) {
  //   var cvp = drawingInstance.stx.currentVectorParameters;
  //   var configs = drawingInstance.configs;
  //   var c, conf;
  //   for (c = 0; c < configs.length; c++) {
  //     conf = configs[c];
  //     if (conf == "color") {
  //       drawingInstance.color = cvp.currentColor;
  //     } else if (conf == "parameters") {
  //       drawingInstance.parameters = CIQ.clone(cvp.fibonacci);
  //     } else if (conf == "font") {
  //       drawingInstance.font = CIQ.clone(cvp.annotation.font);
  //     } else {
  //       drawingInstance[conf] = cvp[conf];
  //     }
  //   }
  //   if (!withPreferences) {
  //     return;
  //   }
  //   var customPrefs = drawingInstance.stx.preferences;
  //   if (customPrefs && customPrefs.drawings) {
  //     CIQ.extend(drawingInstance, customPrefs.drawings[cvp.vectorType]);
  //     for (c = 0; c < configs.length; c++) {
  //       conf = configs[c];
  //       if (conf == 'color') {
  //         cvp.currentColor = drawingInstance.color;
  //       } else if (conf == 'parameters') {
  //         cvp.fibonacci = CIQ.clone(drawingInstance.parameters);
  //       } else if (conf == 'font') {
  //         cvp.annotation.font = CIQ.clone(drawingInstance.font);
  //       } else {
  //         cvp[conf] = drawingInstance[conf];
  //       }
  //     }
  //   }
  // }

  /// Used to set the user behavior for creating drawings.
  ///
  /// By default, a drawing is created with this sequence:
  /// <br>`move crosshair to staring point` → `click` → `move crosshair to
  /// ending point` → `click`.
  /// > On a touch device this would be:
  /// > <br>`move crosshair to staring point` → `tap` → `move crosshair to
  /// ending point` → `tap`.
  ///
  /// Set dragToDraw to `true` to create the drawing with the following
  /// alternate sequence:
  /// <br>`move crosshair to staring point` → `mousedown` → `drag` → `mouseup`
  /// > On a touch device this would be:
  /// > <br>`move crosshair to staring point` → `press` → `drag` → `release`.
  ///
  ///  This parameter is **not compatible** with drawings requiring more than
  ///  one drag movement to complete, such as:
  ///  - Channel
  ///  - Continues Line
  ///  - Elliott Wave
  ///  - Gartley
  ///  - Pitchfork
  ///  - Fibonacci Projection
  ///
  /// Line and Ray have their own separate parameter, which also needs
  /// to be set in the same way,  if this option is desired:
  /// `CIQ.Drawing.line.prototype.dragToDraw=true;`
  ///
  /// This parameter may be set for all drawings compatible with it,
  /// for a specific drawing type, or for a specific drawing instance.
  /// See examples.
  /// @memberOf CIQ.Drawing
  /// @example
  /// // set drawing instance to dragToDraw. Only this one drawing will be
  /// affected
  /// drawing.dragToDraw=true;
  /// // Set particular drawing prototype to dragToDraw. All drawings to type
  /// "difference" will be affected
  /// CIQ.Drawing["difference"].prototype.dragToDraw=true;
  /// // Set all drawings to dragToDraw
  /// CIQ.Drawing.prototype.dragToDraw=true;

  bool dragToDraw = false;

  /// Set this to true to disable selection, repositioning and deletion by
  /// the end user.
  ///
  /// This parameter may be set for all drawings, for a specific drawing type,
  /// or for a specific drawing instance. See examples.
  /// @memberOf CIQ.Drawing
  /// @example
  /// // set drawing instance to permanent. Only this one drawing will be
  /// affected
  /// drawing.permanent=true;
  /// // Set particular drawing prototype to permanent. All drawings to type
  /// "difference" will be affected
  /// CIQ.Drawing["difference"].prototype.permanent=true;
  /// // Set all drawings to permanent
  /// CIQ.Drawing.prototype.permanent=true;

  bool permanent = false;

  /// Is called to tell a drawing to abort itself. It should clean up any
  /// rendered objects such as DOM elements or toggle states. It does not
  /// need to clean up anything that it drew on the canvas.
  /// @param  {boolean} forceClear Indicates that the user explicitly has
  /// deleted the drawing (advanced usage)
  /// @memberOf CIQ.Drawing

  void abort({bool? forceClear}) {}

  /// Should call this.stx.setMeasure() with the measurements of the drawing
  /// if supported
  /// @memberOf CIQ.Drawing

  void measure() {}

  /// Initializes the drawing
  /// @param  {CIQ.ChartEngine} stx   The chart object
  /// @param  {CIQ.ChartEngine.Panel} panel The panel reference
  /// @memberOf CIQ.Drawing

  // void construct(dynamic stx, dynamic panel) {
  //   this.stx = stx;
  //   this.panelName = panel.name;
  // }

  /// Called to render the drawing
  /// @param {CanvasRenderingContext2D} Canvas context on which to render.
  /// @memberOf CIQ.Drawing

  void render(Canvas? context) {
    log('must implement render function!');
  }

  /// Called when a user clicks while drawing.
  ///
  /// @param {object} context The canvas context.
  /// @param {number} tick The tick in the `dataSet`.
  /// @param {number} value The value (price) of the click.
  /// @return {boolean} True if the drawing is complete.
  /// Otherwise the kernel continues accepting clicks.
  ///
  /// @memberof CIQ.Drawing

  dynamic click(Canvas? context, num? tick, num? value) {
    log('must implement click function!');
  }


  /// Called when the user moves while creating a drawing.
  /// @param {CanvasRenderingContext2D} Canvas context on which to render.
  /// @param {number} tick Tick in the `dataSet`.
  /// @param {number} value Value at position.
  /// @memberOf CIQ.Drawing

  void move(Canvas? context, num? tick, num? value) {
    log('must implement move function!');
  }

  /// Called when the user attempts to reposition a drawing.
  /// The repositioner is the object provided
  /// by {@link CIQ.Drawing.intersected} and can be used to determine
  /// which aspect of the drawing is being repositioned. For instance,
  /// this object may indicate which point on the drawing was
  /// selected by the user. It might also contain the original coordinates
  /// of the point or anything else that is useful to render the drawing.
  ///
  /// @param  {object} context The canvas context.
  /// @param  {object} repositioner The repositioner object.
  /// @param  {number} tick Current tick in the `dataSet` for the tap spot.
  /// @param  {number} value Current value in the `dataSet` for the tap spot.
  ///
  /// @memberof CIQ.Drawing

  void reposition(dynamic context, dynamic repositioner, num? tick,
      num? value) {}

  /// Called to determine whether the drawing is intersected by
  /// either the tick/value (pointer location) or box (small box
  /// surrounding the pointer). For line-based drawings, the box should
  /// be checked. For area drawings (rectangles, circles)
  /// the point should be checked.
  ///
  /// @param {number} tick The tick in the `dataSet` representing
  /// the cursor point.
  /// @param {number} value The value (price) representing the cursor point.
  /// @param {object} box	x0, y0, x1, y1, r representing an area
  /// around the cursor, including radius.
  /// @return {object} An object that contains information
  /// about the intersection. This object is passed back to
  /// {@link CIQ.Drawing.reposition} when repositioning the drawing. Return
  /// 		false or null if not intersected.
  /// Simply returning true highlights the drawing.
  ///
  /// @memberof CIQ.Drawing

  dynamic intersected(num? tick, num? value, dynamic box) {
    log('must implement intersected function!');
  }

  /// Reconstruct this drawing type from a serialization object
  /// @param {CIQ.ChartEngine} stx Instance of the chart engine
  /// @param {object} obj Serialized data about the drawing from which
  /// it can be reconstructed.
  /// @memberOf CIQ.Drawing

  void reconstruct(dynamic stx, dynamic obj) {
    log('must implement reconstruct function!');
  }

  /// Serialize a drawing into an object.
  /// @memberOf CIQ.Drawing

  dynamic serialize() {
    log('must implement serialize function!');
  }

  /// Called whenever periodicity changes so that drawings can adjust
  /// their rendering.
  /// @memberOf CIQ.Drawing

  void adjust() {
    log('must implement adjust function!');
  }

  /// Returns the highlighted state. Set this.highlighted to
  /// the highlight state.
  /// For simple drawings the highlighted state is just true or false.
  /// For complex drawings with pivot points for instance, the highlighted
  /// state may have more than two states.
  /// Whenever the highlighted state changes a draw() event will be
  /// triggered.
  /// @param {Boolean} highlighted True to highlight the drawing,
  /// false to unhighlight
  /// @memberOf CIQ.Drawing.BaseTwoPoint

  bool highlight({bool isHighlighted = false}) {
    if (isHighlighted && !highlighted) {
      highlighted = isHighlighted;
    } else if (!isHighlighted && highlighted) {
      highlighted = isHighlighted;
    }
    return highlighted;
  }

  /// littleCircleRadius
  num littleCircleRadius() {
    const num radius = 6; //Math.max(12, this.layout.candleWidth)/2;
    return radius;
  }

  /// draw littleCircle
  // void littleCircle(dynamic ctx, num? x, num? y, {bool fill = false}) {
  //   if (permanent) {
  //     return;
  //   }
  //   var strokeColor = this.stx.defaultColor;
  //   var fillColor = CIQ.chooseForegroundColor(strokeColor);
  //   ctx.beginPath();
  //   ctx.lineWidth = 1;
  //   ctx.arc(x, y, littleCircleRadius(), 0, 2 * Math.PI, false);
  //   if (fill)
  //     ctx.fillStyle = strokeColor;
  //   else
  //     ctx.fillStyle = fillColor;
  //   ctx.strokeStyle = strokeColor;
  //   ctx.setLineDash([]);
  //   ctx.fill();
  //   ctx.stroke();
  //   ctx.closePath();
  // }

  /// rotate
  // void rotator(dynamic ctx, num? x, num? y, {bool on = false}) {
  //   if (permanent) return;
  //   var circleSize = littleCircleRadius();
  //   var strokeColor = this.stx.defaultColor;
  //   ctx.beginPath();
  //   ctx.lineWidth = 2;
  //   if (!on) ctx.globalAlpha = 0.5;
  //   var radius = 4 + circleSize;
  //   ctx.arc(x, y, radius, 0, (3 * Math.PI) / 2, false);
  //   ctx.moveTo(x + 2 + radius, y + 2);
  //   ctx.lineTo(x + radius, y);
  //   ctx.lineTo(x - 2 + radius, y + 2);
  //   ctx.moveTo(x - 2, y + 2 - radius);
  //   ctx.lineTo(x, y - radius);
  //   ctx.lineTo(x - 2, y - 2 - radius);
  //   ctx.strokeStyle = strokeColor;
  //   ctx.stroke();
  //   ctx.closePath();
  //   ctx.globalAlpha = 1;
  // }

  /// move
  // void mover(dynamic ctx, num? x, num? y, {bool on = false}) {
  //   if (permanent) {
  //     return;
  //   }
  //   var circleSize = littleCircleRadius();
  //   var strokeColor = this.stx.defaultColor;
  //   var length = 5;
  //   var start = circleSize + 1;
  //   ctx.save();
  //   ctx.lineWidth = 2;
  //   ctx.strokeStyle = strokeColor;
  //   ctx.translate(x, y);
  //   if (!on) ctx.globalAlpha = 0.5;
  //   for (var i = 0; i < 4; i++) {
  //     ctx.rotate(Math.PI / 2);
  //     ctx.beginPath();
  //     ctx.moveTo(0, start);
  //     ctx.lineTo(0, start + length);
  //     ctx.moveTo(-2, start + length - 2);
  //     ctx.lineTo(0, start + length);
  //     ctx.lineTo(2, start + length - 2);
  //     ctx.closePath();
  //     ctx.stroke();
  //   }
  //   ctx.globalAlpha = 1;
  //   ctx.restore();
  // }

  /// resize
  // void resizer(dynamic ctx, num? x, num? y, {bool on = false}) {
  //   if (permanent) {
  //     return;
  //   }
  //   var circleSize = littleCircleRadius();
  //   var strokeColor = this.stx.defaultColor;
  //   var length = 5 * Math.sqrt(2);
  //   var start = circleSize + 1;
  //   ctx.save();
  //   ctx.lineWidth = 2;
  //   ctx.strokeStyle = strokeColor;
  //   ctx.translate(x, y);
  //   ctx.rotate(((-(x * y) / Math.abs(x * y)) * Math.PI) / 4);
  //   if (!on) ctx.globalAlpha = 0.5;
  //   for (var i = 0; i < 2; i++) {
  //     ctx.rotate(Math.PI);
  //     ctx.beginPath();
  //     ctx.moveTo(0, start);
  //     ctx.lineTo(0, start + length);
  //     ctx.moveTo(-2, start + length - 2);
  //     ctx.lineTo(0, start + length);
  //     ctx.lineTo(2, start + length - 2);
  //     ctx.closePath();
  //     ctx.stroke();
  //   }
  //   ctx.globalAlpha = 1;
  //   ctx.restore();
  // }

  /// Returns true if the tick and value are inside the box
  /// @param  {number} tick  The tick
  /// @param  {number} value The value
  /// @param  {object} box   The box
  /// @param  {boolean} isPixels   True if tick and value are in pixels;
  /// otherwise, they assumed to be in ticks and untransformed y-axis values,
  /// respectively
  /// @return {boolean}       True if the tick and value are within the box
  /// @memberOf CIQ.Drawing
  /// @since 7.0.0 Added `isPixels`.

  // bool pointIntersection(num? tick,
  //     num? value,
  //     dynamic box,
  //     {bool isPixels = false}) {
  //   var panel = this.stx.panels[this.panelName];
  //   if (!panel) {
  //     return false;
  //   }
  //   if (isPixels) {
  //     if (
  //     tick >= box.cx0 &&
  //         tick <= box.cx1 &&
  //         value >= box.cy0 &&
  //         value <= box.cy1
  //     ) {
  //       return true;
  //     }
  //   } else {
  //     if (
  //     tick >= box.x0 &&
  //         tick <= box.x1 &&
  //         value >= Math.min(box.y0, box.y1) &&
  //         value <= Math.max(box.y0, box.y1)
  //     ) {
  //       return true;
  //     }
  //   }
  //   return false;
  // }

  /// Sets the internal properties of the drawing points where x is a tick
  /// or a date and y is a value.
  /// @param  {number} point    index to point to be converted (0,1)
  /// @param  {number|string} x    index of bar in dataSet (tick)
  /// or date of tick (string form)
  /// @param  {number} y    price
  /// @param  {CIQ.ChartEngine.Chart} [chart] Optional chart object
  /// @memberOf CIQ.Drawing.BaseTwoPoint
  /// @since 04-2015

  // void setPoint(num? point, dynamic x, num? y, dynamic chart) {
  //   num? tick;
  //   String? date;
  //   if (x is num) {
  //     tick = x;
  //   } else if (x.length >= 8) {
  //     date = x;
  //   } else {
  //     tick = int.parse(x);
  //   }
  //
  //   if (y || y == 0) {
  //     points['v$point'] = y;
  //   }
  //   DateTime? d;
  //   if (tick != null) {
  //     d = this.stx.dateFromTick(tick, chart, true);
  //     points['tzo$point'] = d.getTimezoneOffset();
  //     points['d$point'] = CIQ.yyyymmddhhmmssmmm(d);
  //     points['p$point'] = [tick, y];
  //   } else if (date != null) {
  //     d = CIQ.strToDateTime(date);
  //     if (!points['tzo$point'] && points['tzo$point'] !== 0)
  //       points['tzo$point'] = d.getTimezoneOffset();
  //     points['d$point'] = date;
  //     var adj = points['tzo$point'] - d.getTimezoneOffset();
  //     d.setMinutes(d.getMinutes() + adj);
  //     var forward = false;
  //
  //     /// if no match, we advance on intraday when there is a no time portion
  //     /// except for free form which already handles time placement internally
  //     if (
  //     name != 'freeform' &&
  //         !CIQ.ChartEngine.isDailyInterval(this.stx.layout.interval) &&
  //         !d.getHours() &&
  //         !d.getMinutes() &&
  //         !d.getSeconds() &&
  //         !d.getMilliseconds()
  //     )
  //       forward = true;
  //
  //     this["p" + point] = [
  //       this.stx.tickFromDate(
//            CIQ.yyyymmddhhmmssmmm(d),
//            chart,
//            null,
//            forward,
//        ),
  //       y
  //     ];
  //   }
  // }

  /// Compute the proper color to use when rendering lines in the drawing.
  ///
  /// Will use the color but if set to auto or transparent, will use
  /// the container's defaultColor.
  /// However, if color is set to auto and the drawing is based off a series,
  /// this function will return that plot's color.
  /// If drawing is highlighted will use the highlight color as defined in
  /// stx_highlight_vector style.
  /// @param {string} color Color string to check and use as a basis
  /// for setting.  If not supplied, uses this.color.
  /// @return {string} Color to use for the line drawing
  /// @memberOf CIQ.Drawing
  /// @since 7.0.0 Replaces `setLineColor`. Will return source line's
  /// color if auto.
  /// @example
  /// 		var trendLineColor=this.getLineColor();
  ///		this.stx.plotLine(x0, x1, y0, y1, trendLineColor, "segment",
  ///context, panel, parameters);

  // String getLineColor(String? color) {
  //   if (color == null) {
  //     color = this.color;
  //   }
  //   var stx = this.stx,
  //       lineColor = color;
  //   if (this.highlighted) {
  //     lineColor = stx.getCanvasColor('stx_highlight_vector');
  //   } else if (CIQ.isTransparent(lineColor)) {
  //     lineColor = stx.defaultColor;
  //   } else if (lineColor == 'auto') {
  //     lineColor = stx.defaultColor;
  //     if (this.field) {
  //       // ugh, need to search for it
  //       var n;
  //       for (n in stx.layout.studies) {
  //         var s = stx.layout.studies[n];
  //         var candidateColor = s.outputs[s.outputMap[this.field]];
  //         if (candidateColor) {
  //           lineColor = candidateColor.color || candidateColor;
  //           break;
  //         }
  //       }
  //       var fallBackOn;
  //       for (n in stx.chart.seriesRenderers) {
  //         var renderer = stx.chart.seriesRenderers[n];
  //         for (var m = 0; m < renderer.seriesParams.length; m++) {
  //           var series = renderer.seriesParams[m];
  //           var fullField = series.field;
  //           if (!fullField && !renderer.highLowBars)
  //             fullField = this.defaultPlotField || "Close";
  //           if (series.symbol && series.subField)
  //             fullField += "-->" + series.subField;
  //           if (this.field == fullField) {
  //             lineColor = series.color;
  //             break;
  //           }
  //           if (series.field && series.field == this.field.split('-->')[0])
  //             fallBackOn = series.color;
  //         }
  //       }
  //       if (fallBackOn) lineColor = fallBackOn;
  //     }
  //   }
  //   if (lineColor == 'auto') lineColor = stx.defaultColor;
  //
  //   return lineColor;
  // }
}
