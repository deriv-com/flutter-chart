# Chart Architecture

This document provides a comprehensive overview of the Deriv Chart library's architecture, explaining the key components and how they interact with each other.

## High-Level Architecture

The Deriv Chart library follows a layered architecture with clear separation of concerns:

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

### Key Components

1. **XAxisWrapper**: The outermost layer that:
   - Provides platform-specific X-axis implementations (web/mobile)
   - Manages chart data entries and live data state
   - Handles data fit mode and zoom level (msPerPx)
   - Controls scroll animation and visible area changes

2. **GestureManager**: The middle layer that:
   - Handles user interactions (pan, zoom, tap)
   - Manages gesture states and animations
   - Controls chart navigation and interaction behavior

3. **Chart**: The core component that:
   - Contains MainChart and optional BottomCharts
   - Coordinates shared X-axis between charts
   - Manages Y-axis for each chart section
   - Renders data visualization

This layered structure ensures:
- Clear separation of concerns
- Platform-specific adaptations
- Consistent user interaction handling
- Coordinated data visualization

## Chart Structure

The Chart widget has a vertical structure with multiple chart areas:

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

### MainChart

The MainChart is the primary chart area that:
- Displays market data (line, candlestick charts)
- Shows overlay indicators (like Moving Average)
- Supports drawing tools for technical analysis
- Displays crosshair for price/time inspection
- Renders visual elements like barriers and markers

### BottomCharts

BottomCharts are additional chart areas that:
- Display separate indicator charts (like RSI, MACD)
- Have independent Y-axis scaling
- Share the same X-axis viewport with MainChart
- Can be added/removed dynamically

## Widget Hierarchy

The chart library implements a hierarchical structure of chart widgets:

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

### BasicChart

BasicChart serves as the foundation for all chart widgets, providing:
- Single MainSeries for data visualization
- Y-axis range management
- Coordinate conversion functions
- Y-axis scaling and animations
- Grid lines and labels
- User interactions for Y-axis scaling

### MainChart

MainChart extends BasicChart to create the primary chart area by adding:
- Support for multiple ChartData types
- Crosshair functionality
- Drawing tools
- Overlay indicators

### BottomChart

BottomChart extends BasicChart to create secondary chart areas that:
- Display technical indicators with independent Y-axis scaling
- Maintain separate Y-axis ranges while sharing X-axis viewport
- Support dynamic addition/removal of indicators
- Sync zooming and scrolling with MainChart

## Coordinate System

The chart uses a coordinate system based on time (X-axis) and price (Y-axis):

### X-Axis Coordinates

The X-axis is managed by the XAxisWrapper and uses:
- **rightBoundEpoch**: The timestamp at the right edge of the chart
- **msPerPx**: Milliseconds per pixel (zoom level)
- **leftBoundEpoch**: Calculated as `rightBoundEpoch - screenWidth * msPerPx`

### Y-Axis Coordinates

The Y-axis is managed by each chart (MainChart and BottomCharts) and uses:
- **topBoundQuote**: The maximum price in the visible area
- **bottomBoundQuote**: The minimum price in the visible area
- **quotePerPx**: Price units per pixel

### Coordinate Conversion

The chart provides conversion functions:
- `xFromEpoch`: Converts timestamp to X-coordinate
- `yFromQuote`: Converts price to Y-coordinate
- `epochFromX`: Converts X-coordinate to timestamp
- `quoteFromY`: Converts Y-coordinate to price

These functions enable plotting any data point on the canvas and handling user interactions.

## Data Visualization

The chart library uses a flexible data visualization system:

```
┌─────────────┐
│  ChartData  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Series    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ DataSeries  │
└──────┬──────┘
       │
       ├─────────────┬─────────────┬─────────────┐
       │             │             │             │
       ▼             ▼             ▼             ▼
┌─────────────┐┌─────────────┐┌─────────────┐┌─────────────┐
│ LineSeries  ││CandleSeries ││ OHLCSeries  ││ Indicators  │
└─────────────┘└─────────────┘└─────────────┘└─────────────┘
```

### ChartData

ChartData is an abstract class representing any data that can be displayed on the chart, including:
- Series data (lines, candles)
- Annotations (barriers)
- Markers

### Series

Series is the base class for all chart series, handling:
- Data management
- Range calculation
- Painter creation

### DataSeries

DataSeries extends Series to handle sequential data with:
- Sorted data management
- Visible data calculation
- Min/max value determination

### Specific Series Types

- **LineSeries**: Displays line charts from tick data
- **CandleSeries**: Displays candlestick charts from OHLC data
- **OHLCSeries**: Displays OHLC charts from OHLC data
- **Indicator Series**: Displays technical indicators

## Painter System

The chart uses a custom painting system to render data:

```
┌─────────────────┐
│  SeriesPainter  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   DataPainter   │
└────────┬────────┘
         │
         ├─────────────┬─────────────┬─────────────┐
         │             │             │             │
         ▼             ▼             ▼             ▼
┌─────────────┐┌─────────────┐┌─────────────┐┌─────────────┐
│ LinePainter ││CandlePainter││OHLCPainter  ││ScatterPainter
└─────────────┘└─────────────┘└─────────────┘└─────────────┘
```

### SeriesPainter

SeriesPainter is an abstract class responsible for painting Series data on the canvas.

### DataPainter

DataPainter extends SeriesPainter to provide common painting functionality for DataSeries.

### Specific Painters

- **LinePainter**: Paints line data
- **CandlePainter**: Paints candlestick data
- **OHLCPainter**: Paints OHLC data
- **ScatterPainter**: Paints scatter plot data

## Interactive Layer

The Interactive Layer manages user interactions with drawing tools and provides a sophisticated state-based architecture for handling drawing tool creation, selection, and manipulation.

```
┌─────────────────────────┐
│    Interactive Layer    │
└─────────────┬───────────┘
              │
              ▼
┌─────────────────────────┐
│    InteractiveState     │
└─────────────┬───────────┘
              │
              ├─────────────────┬─────────────────┬─────────────────┐
              │                 │                 │                 │
              ▼                 ▼                 ▼                 ▼
┌─────────────────┐┌─────────────────┐┌─────────────────┐┌─────────────────┐
│  NormalState    ││SelectedToolState││ AddingToolState ││  HoverState     │
└─────────────────┘└─────────────────┘└─────────────────┘└─────────────────┘
```

### Key Components

The Interactive Layer consists of several key components:

- **InteractiveState**: Defines different modes of interaction (normal, selected, adding)
- **InteractiveLayerBehaviour**: Provides platform-specific interaction handling and customizes state transitions
- **DrawingV2**: The base interface for all drawable elements on the chart
- **InteractableDrawing**: Concrete implementations of drawing tools that can be interacted with
- **DrawingAddingPreview**: Specialized components for handling the drawing creation process

### InteractiveState

InteractiveState defines the current mode of interaction with the chart:

- **NormalState**: Default state when no tools are selected
- **SelectedToolState**: Active when a drawing tool is selected
- **AddingToolState**: Active when a new drawing tool is being created
- **HoverState**: A mixin that provides hover functionality

### Drawing Tool States

Each drawing tool has its own state:

- **normal**: Default state
- **selected**: Tool is selected
- **hovered**: Pointer is hovering over the tool
- **adding**: Tool is being created
- **dragging**: Tool is being moved
- **animating**: Tool is being animated

For detailed information about the Interactive Layer architecture, components, and implementation details, see [Interactive Layer](interactive_layer.md).

## Theme System

The chart library includes a theming system:

```
┌─────────────────┐
│   ChartTheme    │
└────────┬────────┘
         │
         ├─────────────────┬─────────────────┐
         │                 │                 │
         ▼                 ▼                 ▼
┌─────────────────┐┌─────────────────┐┌─────────────────┐
│DefaultDarkTheme ││DefaultLightTheme││  CustomTheme    │
└─────────────────┘└─────────────────┘└─────────────────┘
```

### ChartTheme

ChartTheme is an interface defining all themeable aspects of the chart:

- Grid style
- Axis style
- Crosshair style
- Series styles
- Annotation styles
- Background colors

### Default Themes

- **ChartDefaultDarkTheme**: Default dark theme
- **ChartDefaultLightTheme**: Default light theme

### Custom Themes

Users can create custom themes by:
- Implementing the ChartTheme interface
- Extending one of the default themes and overriding specific properties

## DerivChart

DerivChart is a wrapper around the Chart widget that:
- Provides UI for adding/removing indicators and drawing tools
- Manages saving/restoring selected indicators and tools
- Handles indicator and drawing tool configurations

```
┌─────────────────────────┐
│      DerivChart         │
│  ┌───────────────────┐  │
│  │      Chart        │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │  AddOnsRepository │  │
│  └───────────────────┘  │
└─────────────────────────┘
```

### AddOnsRepository

AddOnsRepository is a ChangeNotifier that:
- Manages a list of add-ons (indicators or drawing tools)
- Handles saving/loading from SharedPreferences
- Provides methods for adding, removing, and updating add-ons

## Next Steps

Now that you understand the architecture of the Deriv Chart library, you can explore:

- [Data Models](data_models.md) - Learn about the data structures used in the chart
- [Coordinate System](coordinate_system.md) - Understand how coordinates are managed
- [Rendering Pipeline](rendering_pipeline.md) - Explore how data is rendered on the canvas