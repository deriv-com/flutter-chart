# Widget Structure

The chart library follows a nested widget structure to handle different responsibilities:

```
┌─────────────────────────┐
│      XAxisWrapper       │
│  ┌───────────────────┐  │
│  │  GestureManager   │  │
│  │  ┌─────────────┐  │  │
│  │  │    Chart    │  │  │
│  │  │             │  │  │
│  │  └─────────────┘  │  │
│  └───────────────────┘  │
└─────────────────────────┘
```

1. **XAxisWrapper**: The outermost widget that:
   - Provides platform-specific X-axis implementations (web/mobile)
   - Manages chart data entries and live data state
   - Handles data fit mode and zoom level (msPerPx)
   - Controls scroll animation and visible area changes

2. **GestureManager**: Wrapped inside XAxisWrapper to:
   - Handle user interactions (pan, zoom, tap)
   - Manage gesture states and animations
   - Control chart navigation and interaction behavior

3. **Chart**: The core widget containing:
   - MainChart: Primary chart area for price data visualization
   - BottomCharts: Optional secondary charts for indicators
   - Shared X-axis coordination between main and bottom charts
   - Y-axis management for each chart section

This layered structure ensures separation of concerns:
- XAxisWrapper handles platform specifics and data management
- GestureManager focuses on user interaction
- Chart concentrates on data visualization and coordination

# Chart Structure

The Chart widget has two implementations based on the platform (web/mobile):

```
┌─────────────────────────┐
│         Chart           │
│                         │
│  ┌───────────────────┐  │
│  │    MainChart      │  │
│  │   (Main Data)     │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │   BottomCharts    │  │
│  │(Bottom Indicators)│  │
│  └───────────────────┘  │
│          ...            │
│          ...            │
│          ...            │
└─────────────────────────┘
```

1. **MainChart**: The primary chart area that displays:
   - Market data visualization (Line, Candlestick charts)
   - Overlay indicators (like Moving Average)
   - Drawing tools for technical analysis
   - Crosshair for price/time inspection
   - Other visual elements like barriers and markers

2. **BottomCharts**: Additional chart areas below the MainChart that:
   - Display separate indicator charts (like RSI, MACD)
   - Have their own Y-axis scale independent of MainChart
   - Share the same X-axis viewport with MainChart
   - Can be added/removed dynamically

Both MainChart and BottomCharts:
- Share the same X-axis viewport through XAxisWrapper
- Manage their own Y-axis range and scaling
- Update and repaint when the viewport changes
- Support user interactions like zooming and scrolling

# Chart Widgets Hierarchy

The chart library implements a hierarchical structure of chart widgets, each building upon the capabilities of its parent:

```
┌─────────────────────┐
│     BasicChart      │
│   (Base Features)   │
└─────────┬─────────┬─┘
          │         │
          ▼         ▼
    ┌─────────┐  ┌─────────┐
    │MainChart│  │BottomChart
    └─────────┘  └─────────┘
```

## BasicChart

BasicChart serves as the foundation for all chart widgets, providing essential chart functionality:
- Takes a single MainSeries for data visualization
- Manages Y-axis range through topBoundEpoch and bottomBoundEpoch
- Provides coordinate conversion functions:
  - Uses its Y-axis management to convert values (quotes) to y-positions
  - Works with XAxisWrapper's XAxisModel to convert time (epoch) to x-positions
  - Together these enable plotting any (epoch, quote) point on the canvas
- Handles Y-axis scaling and animations
- Manages grid lines and labels
- Supports user interactions for Y-axis scaling

## MainChart

MainChart extends BasicChart to create the primary chart area by adding:
- Support for multiple ChartData types (mainSeries, overlaySeries, markerSeries)
- Crosshair functionality for price/time inspection
- Drawing tools for technical analysis
- Overlay indicators that share the same Y-axis scale

## BottomChart

BottomChart extends BasicChart to create secondary chart areas that:
- Display technical indicators requiring independent Y-axis scaling below the MainChart
- Maintain separate Y-axis ranges while sharing X-axis viewport
- Support dynamic addition/removal of indicators
- Sync zooming and scrolling with MainChart

This hierarchical structure allows for:
- Code reuse through inheritance
- Clear separation of responsibilities
- Flexible composition of chart features
- Independent Y-axis management with shared X-axis coordination

# Market data

The market data(input data of chart) is a list of _Ticks_ or _OHLC_.

- A **Tick** data element has two properties, epoch (time-stamp) and quote (price).
- An **OHLC** (candle) data which shows the price changes in a period of time, each candle element has five properties, epoch (time-stamp) and open, close, high, low price values.
  These four values respectively represent starting, ending, highest and lowest price in that timeframe.

# Chart Scheme

Chart widget is a Canvas that we paint all data of chart inside this Canvas.

![plot](chart_scheme.png)

this widget has X-Axis and Y-Axis enabled by default.

# X-Axis

X-Axis coordination system works with _rightBoundEpoch_ and _msPerPx_ variables.

1. **rightBoundEpoch**: The time-stamp of the chart screen right edge.
   We initially set it to point to `maxRightBoundEpoch`, The last Tick/OHLC epoch on closed markets, or the last element of the series (overlay/bottom) that has the most positive offset plus a constant offset in pixel (maxCurrentTickOffset).

2. **msPerPx**: which specifies each pixel of the chart screen horizontally consists of how many milliseconds.

3. **leftBoundEpoch**: The time-stamp of the chart screen left edge.
   By knowing **msPerPx**(chart's width in pixels) and **rightBoundEpoch**, We can then calculate the **leftBoundEpoch** like this:
   **leftBoundEpoch = rightBoundEpoch - screenWidth \* msPerPx**
   Also, we can find out which data is inside this range and is going to be visible.

# Y-Axis

For Y-Axis coordination we would need to have min and max quote values that are in the visible area of chart.

1. **topBoundEpoch**: The maximum quote(price) of the data between _rightBoundEpoch_ and _leftBoundEpoch_.

2. **bottomBoundEpoch**: The minimum quote(price) of the data between _rightBoundEpoch_ and _leftBoundEpoch_.

**now we can have the two conversion functions which can give us (x, y) positions inside the chart canvas for any epoch and quote values.**

# X-Axis labels

- **gridTimestamps** calculates the X-Axis labels. it Creates a list of [DateTime] between rightBoundEpoch and leftBoundEpoch with gaps of [timeGridInterval].
- **timeGridInterval** is calculating by function with same name. it Returns the first time interval which has the enough distance between lines.

# Y-Axis labels

**YAxisModel** is a Model for calculating the grid intervals and quotes(labels).
by knowing the **topBoundQuote** and **bottomBoundQuote** we calculate the labels based on interval. this intervals calculates by **quoteGridInterval**.

- **quoteGridInterval** Calculates the grid interval of a quote by getting the [quotePerPx] value.
- **quotePerPx** Calculates the quotes that can be placed per pixel by division of distance between topBound and bottomBound in quote and pixel.

`minDistanceBetweenLines` determines the minimum distance that we want two consecutive Y-Axis labels to have.
`intervals` is a static list of doubles that shows Options for quote labels value distance in Y-Axis.
One of these intervals will be selected to be the distance between Y-Axis labels.
the number from `intervals` list is selected as an interval that using it with the given [quotePerPx] will give us distance more than `minDistanceBetweenLines`.

# X-Axis scrolling

Scrolling in the chart happens by updating **rightBoundEpoch** of the chart's X-Axis.
changing the **rightBoundEpoch** amount will change the chart's scroll position. **rightBoundEpoch** be on the last tick when we first load the chart.

# Zooming

Zooming in the chart happens by updating **msPerPx**.
**msPerPx** is for changing the zoom level of the chart, increasing it will result in zoom-out and decreasing to zoom-in.

# _Painting data_

## Data Visualisation

![plot](data_series.png)
We have an abstract class named **ChartData** that represents any type of data that the chart takes and makes it paint its self on the chart's canvas including _Line_, _Candle_ data, _Markers_, _barriers_, etc.
A **ChartData** can be anything that shows some data on the chart. The chart can take a bunch of ChartData objects and paint them on its canvas.

**DataSeries** is a Super class of any data series that has **_one_** list of sorted data to paint (by epoch).
**LineSeries**, **CandleSeries**, **OHLCSeries**,AbstractSingleIndicatorSeries(all indicator series that shows only one sequential data like **MASeries**(for moving average), **RSISeries**) are all subclasses of DataSeries directly or not.
**DataSeries** holds the common functionalities of managing this list of sorted data.

**Series** is the Base class of all chart series paintings.
The series that have **_more than one_** list of sorted data to paint (like AlligatorIndicatorSeries) extend from **Series** and have some SingleIndicatorSeries inside.

### ChartObject

Any component which can take a rectangle area on the chart's canvas.
It has `isOnEpochRange` and `isOnValueRange` method that shows whether this chart object is in chart horizontal or vertical visible area or not.

### BarrierObject

A **ChartObject** for defining position of a horizontal or vertical barrier.

### Chart annotations

Annotations are ChartData without any sequential data that added to the chart, like **Barriers**.
**ChartAnnotation** is a Base class of chart annotations that extends from **Series**.

### Barriers

**Barrier** is a base class of barrier. Its properties are title, epoch and value.
We have two kinds of barriers: **VerticalBarrier** and **HorizontalBarrier**.
**VerticalBarrier**: is a vertical line in the chart that draws on a specific timestamp. It extends from the **Barrier** class.
**HorizontalBarrier**: is a horizontal line that draws on a specific value(price).

**TickIndicator** is a subclass of **HorizontalBarrier** to show the current tick label and horizontal line. It has its own default configuration like the **HorizontalBarrierVisibility** type.
The reason that we have **TickIndicator** is to recognize the difference between **HorizontalBarrier** and **TickIndicator** if the user did not define the id for them.

To add horizontal/vertical barriers, specify them in the `annotations` parameter of the chart.
They have the `createPainter` object to paint the **BarrierObject** that gets initiated in their `createObject` method.

### Markers

**MarkerSeries** extends from **Series** to show the markers that are added to the chart.

# Painter classes

![plot](data_painters.png)

**SeriesPainter** is an abstract class responsible for painting its [series] data.

We have an abstract class named **DataPainter** that extends from **SeriesPainter** and it is a class for painting common options of [DataSeries] data.

Other painters like **LinePainter**( A [DataPainter] for painting line data), **CandlePainter**(A [DataPainter] for painting CandleStick data) and **ScatterPainter**, all extend from **DataPainter**.

**DataPainter** has a method called `onPaint` that calls `onPaintData`. It actually paints what's inside `onPaintData` that is overridden by each painter. for example **LinePainter** paints line in `onPaintData` method and **CandlePainter** paints Candles and `onPaintData` method. `onPaint` is a method where **DataPainters** need to do some common things before painting.

For painting Barriers, we have **VerticalBarrierPainter** and **HorizontalBarrierPainter** that also extend from **SeriesPainter**.
They override the `onPaint` method to draw a Vertical/Horizontal Barrier.

We have a `StatefulWidget` named **MarkerArea** to draw markers inside it.
**MarkerArea** is a Layer with markers.
For painting markers we have the **MarkerPainter** class extends from `CustomPainter`.

**\*The data in Visible area are between **rightBoundEpoch**, **leftBoundEpoch** and **topBoundEpoch**, **bottomBoundEpoch**, will be painted by these painters.\***

# Painting chart data

when the list of data changes(by scrolling, zooming, or receiving new data) we need to update the chart.
There are 3 steps that the chart requires to do when these variables change in order to update its components(including mainSeries, indicators, Barrier, markers, ... ).

1. The chart goes through its components and notifies them about the change. Each of these components then updates their visible data inside the new (leftEpoch, rightEpoch) range.
   Then they can determine what are their min/max value (quote/price).

2. The chart then asks every component their min/max values through their `minValue` and `maxValue` getters to calculate the overall min/max of its Y-Axis range.
   Any component that is not willing to be included in defining the Y-Axis range can return `double.NaN` values as its min/max.
   Then if this component had any element outside of the chart's Y-Axis range that element will be invisible.

3. The conversion functions always return the converted x, y values based on the updated variables (Left/right bound epoch, min/max quote, top/bottom padding).
   The chart will pass these conversion functions along with a reference to its canvas and some other variables to ChartData class to paint their visible data.

# Cross-hair

We have a `StatefulWidget` **CrosshairArea** that places this area on top of the chart to display candle/point details on longpress.
It contains three other StatelessWidgets named **CrosshairDetails** (The details to show on a crosshair) and **CrosshairLinePainter** (A custom painter to paint the crosshair `line`) and **CrosshairDotPainter** (A custom painter to paint the crosshair `dot`).

When `onLongPressStart` starts, `onCrosshairAppeared` is called to show candle/point details then we stop auto-panning to make it easier to select candle or tick and show the longpress point details on the chart.
Also, we start a timer to track the user scrolling speed.
In the `updatePanSpeed` method, we update the pan speed and scroll when the crosshair point closes to the edges. In normal cases, when the crosshair point is not close to edges, in `onLongPressStart` we make the pan speed equal to 0 to avoid scrolling, but when the user is getting close to edges we need to scroll the chart, so `updatePanSpeed` will help us.
In `onLongPressUpdate` we call `updatePanSpeed`, then we calculate how much time is passed between `onLongPressStart` and `onLongPressUpdate`, and then calculate the animation speed based on this time(using VelocityTracker), then we animate with that speed between the two different points that the user scrolled to show the crosshair.
In `onLongPressEnd`, `onCrosshairDisappeare` is called when the candle or the pointer is dismissed and auto-panning starts again and [crosshairTick] will clear.

# Theme

Chart has its own default dark and light themes that switch depending on Theme.of(context).brightness value. If the user creates their own themes, they would have to handle switching it themselves.
`chart_theme` is the interface, `chart_default_theme` is a default implementation of the `chart_theme` which is instantiated and used inside the `Chart` widget if no theme is passed from the app to the `Chart` widget.

`painting_styles` are some style classes that are used to specify how certain components of the chart should be styled. e.g. `barrier_style` contains style parameters of barriers.

# BasicChart

**BasicChart** is a simple chart widget that serves as the foundation for all chart widgets. It:
- Takes a single Series class to paint (see [Data Visualization](#data-visualisation) for Series hierarchy)
- Uses CustomPaint in its build method to paint the Series data (which extends from ChartData)
- Manages Y-axis range through topBoundEpoch and bottomBoundEpoch
- Provides coordinate conversion between data points and canvas positions
- Handles Y-axis scaling, animations, and padding
- Manages grid lines and labels
- In its build method, uses both:
  - XAxisModel's xFromEpoch function to convert time (epoch) to x-positions
  - Its own yFromQuote function to convert values (quotes) to y-positions
  Together these enable plotting any data point from MainSeries or other Series (ChartData) on the canvas

# MainChart

**MainChart** is a subclass of **BasicChart** that serves as the primary chart area. It is responsible for:
- Displaying the main market data through various chart types (LineSeries, CandleSeries, etc. as described in [Data Visualization](#data-visualisation))
- Showing overlay indicators that share the same Y-axis scale (like Moving Average)
- Supporting drawing tools for technical analysis
- Managing crosshair interactions for price/time inspection
- Handling visual elements like barriers and markers
- Coordinating with the shared X-axis viewport

# BottomChart

**BottomChart** extends from **BasicChart** to provide separate chart areas for indicators that require their own Y-axis scale. Key features:
- Displays technical indicators (RSISeries, MACDSeries, etc. as described in [Data Visualization](#data-visualisation)) that need independent scaling
- Maintains its own Y-axis range and scaling while sharing the X-axis viewport
- Can be dynamically added, removed, or reordered
- Supports user interactions like zooming and scrolling in sync with MainChart
![plot](basic-chart.png)

# Chart

**Chart** is a widget that manages showing **MainChart** and multiple **BottomChart**s (to have `bottomSeries`, series that have different Y-scale than the MainChart) vertically.
**MainChart** and **BottomChart**s use the same **XAxis** (and it's provided in the root of the `Chart` widget to be accessible on the widgets at the bottom) but they have different YAxis.

# DerivChart

**DerivChart** A wrapper around the **chart** widget which provides the UI to add/remove addons (indicators and drawing tools) and to manage saving/restoring selected ones on storage.

\*if you want to have indicators and drawing tools in the chart, you should use **\*DerivChart** instead of **Chart\*\***

![plot](deriv-chart.png)

# Widgets

## Market Selector Widget

The widget that we have included it in the chart project to be accessable inside any other project which is going to use the chart, because this widget is supposed to show the asset (symbols) list to be shown by the chart.

## AnimatedPopupDialog

AnimatedPopupDialog is just a wrapper widget to wrap around any widget to show as a dialog. The dialog will pop up with animation.

## CustomDraggableSheet

CustomDraggableSheet is a wrapper widget to be used combined with a bottom sheet that makes to give the widget inside the bottom sheet the behavior that we want.

## Drawing Tool Chart

### Drawing Tools

For a brief explanation of how drawing tools work, please refer to [Drawing Tools](drawing_tools.md) section.

### Interactive Layer (New Implementation)

The chart implements a new Interactive Layer that manages user interactions with drawing tools. This new implementation will replace the previous drawing tools handling mechanism, which will be deprecated and removed in future versions.

The Interactive Layer:

- Handles user gestures (taps, drags, hovers) on the chart
- Manages the lifecycle of drawing tools from creation to manipulation
- Implements a state pattern to handle different interaction modes
- Controls the visual appearance of drawing tools based on their state
- Provides a more maintainable and extensible architecture for drawing tools

The Interactive Layer uses different states to manage interactions:

1. **Normal State**: Default state when no tools are selected
2. **Selected Tool State**: Active when a drawing tool is selected
3. **Adding Tool State**: Active when a new drawing tool is being created

Each drawing tool also has its own state (normal, selected, hovered, adding, dragging) that determines how it's rendered and how it responds to user interactions.

For a detailed explanation of the Interactive Layer architecture and state management, see [Interactive Layer](interactive_layer.md).
