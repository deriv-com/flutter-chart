# Market data
The market data(input data of chart) is a list of *Ticks* or *OHLC*.
- A tick data each element has two properties, epoch (time-stamp) and quote (price).
- An OHLC (candle) data each element has five properties, epoch (time-stamp) and open, close, high, low prices value.


# Chart Scheme 
Chart widget is a Canvas that we paint all data of chart inside this Canvas.

![plot](chart_scheme.png)

this canvas has  X-Axis and Y-Axis coordinate.


# X-Axis
X-Axis coordination system works with *rightBoundEpoch* and *msPerPx* variables.
1. **rightBoundEpoch**: The time-stamp of the chart screen right edge. 
   we initially set it to point to `maxRightBoundEpoch`, The last Tick/OHLC epoch on closed markets or current time on open markets, plus a constant offset.
 
2. **msPerPx**: which specifies each pixel of the chart screen horizontally consists of how many milliseconds. 

3. **leftBoundEpoch**:The time-stamp of the chart screen left edge.
By knowing msPerPx(chart's width in pixels) and rightBoundEpoch, We can then calculate the *leftBoundEpoch* like this:
*leftBoundEpoch = rightBoundEpoch - screenWidth * msPerPx*
 Also we can find out which data is inside this range and gonna visible.

# Y-Axis
For Y-Axis coordination we would need to have min and max quote values that are in the visible area of chart.
1. **topBoundEpoch**:The maximum quote(price) of the data between *rightBoundEpoch* and *leftBoundEpoch*.

2. **bottomBoundEpoch**:The minimum quote(price) of the data between *rightBoundEpoch* and *leftBoundEpoch*.


 **now we can have the two conversion functions which can give us (x, y) positions inside the chart canvas for any epoch and quote values.**

# X-Axis scrolling 
Scrolling in the chart happens by updating *rightBoundEpoch* of the chart's X-Axis.
by changing the *rightBoundEpoch* amount, will make the chart’s scroll position be on the last tick when we first load the chart.


# Zooming 
Scrolling in the chart happens by updating *msPerPx*.
*msPerPx* is for changing the zoom level of the chart, increasing it will result in zoom-out and decreasing to zoom-in.


# Update chart data 
when the list of data changes(by scrolling, zooming, or receiving new data) we need to update the chart.
There is 3 steps that the chart requires to do when these variables change in order to update its components(including mainSeries, indicators, Barrier, markers, ... ).

1. The chart goes through its components and notifies them about the change. Each of these components then update their visible data inside the new (leftEpoch, rightEpoch) range.
 Then they can determine what are their min/max value (quote/price).
 
2. The chart then asks from every components their min/max values through their `minValue` and `maxValue` getters to calculate the overall min/max of its Y-Axis range.
 Any component that is not willing to be included in defining the Y-Axis range can return `double.NaN` values as its  min/max.
  then if this component had any element outside of the chart's Y-Axis range that element will be invisible.
  
3. The conversion functions always return the converted x, y values based on the updated variables (Left/right bound epoch, min/max quote, top/bottom padding).
 The chart will pass these conversion functions along with a reference to its canvas and some other variables to ChartData class to paint their visible data.
 

## Painting data
For painting market data we can have two types of data series:
1. *DataSeries*: Super class of any data series that has one list of sorted data to paint (by epoch).
  LineSeries, CandleSeries, and later OHLCSeries, indicator series like MASeries (for moving average), RSISeries, are all subclasses of DataSeries directly or not.
  
  
  


