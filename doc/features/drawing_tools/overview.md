# Drawing Tools Overview

This document provides an overview of the drawing tools available in the Deriv Chart library, explaining their purpose, categories, and how to use them.

## Introduction to Drawing Tools

Drawing tools allow traders to add visual elements to charts for technical analysis. These tools help identify patterns, trends, support and resistance levels, and other significant price points. The Deriv Chart library provides a comprehensive set of drawing tools to enhance chart analysis.

## Drawing Tool Categories

The Deriv Chart library organizes drawing tools into several categories:

### Lines and Channels

Lines and channels help identify trends, support and resistance levels, and price patterns.

Available line and channel tools:
- Horizontal Line
- Vertical Line
- Trend Line
- Ray Line
- Extended Line
- Parallel Channel
- Regression Channel

[Learn more about Lines and Channels](lines_and_channels.md)

### Fibonacci Tools

Fibonacci tools are based on the Fibonacci sequence and ratios, which are believed to have significance in financial markets.

Available Fibonacci tools:
- Fibonacci Retracement
- Fibonacci Extension
- Fibonacci Fan
- Fibonacci Arc
- Fibonacci Time Zones

[Learn more about Fibonacci Tools](fibonacci_tools.md)

### Geometric Shapes

Geometric shapes help identify chart patterns and areas of interest.

Available geometric shapes:
- Rectangle
- Triangle
- Ellipse
- Polygon
- Arc

### Text and Annotations

Text and annotations allow adding notes and labels to the chart.

Available text and annotation tools:
- Text
- Callout
- Arrow
- Label

## Interactive Layer Architecture

The Deriv Chart library implements drawing tools using an Interactive Layer that manages user interactions:

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

The Interactive Layer:
- Handles user gestures (taps, drags, hovers)
- Manages the lifecycle of drawing tools
- Implements a state pattern for different interaction modes
- Controls the visual appearance of drawing tools

## Using Drawing Tools in the Chart

### Basic Usage with DerivChart

The `DerivChart` widget provides built-in UI for adding and managing drawing tools:

```dart
DerivChart(
  mainSeries: CandleSeries(candles),
  granularity: 60,
  activeSymbol: 'R_100',
  pipSize: 2,
)
```

This includes:
- A drawing tools button in the chart toolbar
- A drawing tools menu for selecting tools
- Tool-specific configuration options
- Persistent storage of drawing tools

### Custom Drawing Tools Management

For more control, you can create your own `AddOnsRepository` for drawing tools:

```dart
final drawingToolsRepo = AddOnsRepository<DrawingToolConfig>(
  createAddOn: (Map<String, dynamic> map) => DrawingToolConfig.fromJson(map),
  onEditCallback: (int index) {
    // Handle editing of drawing tool at index
  },
  sharedPrefKey: 'R_100_drawing_tools',
);

// Load saved drawing tools
await drawingToolsRepo.loadFromPrefs(
  await SharedPreferences.getInstance(),
  'R_100_drawing_tools',
);

// Use the repository with DerivChart
DerivChart(
  mainSeries: CandleSeries(candles),
  drawingToolsRepo: drawingToolsRepo,
  granularity: 60,
  pipSize: 2,
)
```

## Drawing Tool States

Each drawing tool can be in one of the following states:

- **normal**: Default state when the tool is displayed but not being interacted with
- **selected**: The tool is selected and can be manipulated
- **hovered**: The user's pointer is hovering over the tool
- **adding**: The tool is in the process of being created
- **dragging**: The tool is being moved or resized

These states determine how the tool is rendered and how it responds to user interactions.

## Drawing Tool Interaction Flow

The typical flow for adding and interacting with drawing tools is:

1. **Tool Selection**: User selects a drawing tool from the menu
2. **Tool Creation**: User taps on the chart to define the tool's points
   - For a line: tap for start point, tap for end point
   - For a rectangle: tap for one corner, tap for opposite corner
   - For more complex tools: multiple taps to define all required points
3. **Tool Manipulation**: After creation, the tool can be:
   - Selected by tapping on it
   - Moved by dragging it
   - Resized by dragging its control points
   - Configured through the properties panel
   - Deleted using the delete button or keyboard

## Drawing Tool Configuration

Each drawing tool has its own configuration options:

### Style Properties

Common style properties include:
- Line color
- Line thickness
- Line style (solid, dashed, etc.)
- Fill color and opacity
- Text properties (for tools with labels)

### Tool-Specific Properties

Each tool type has specific properties:

- **Fibonacci Retracement**: Levels, labels, colors
- **Trend Line**: Extension options, label options
- **Rectangle**: Border style, fill options
- **Text**: Font, size, alignment

## Example: Adding a Trend Line

```dart
// Create a trend line configuration
final trendLineConfig = TrendLineConfig(
  style: DrawingPaintStyle(
    color: Colors.blue,
    thickness: 2,
    isDashed: false,
  ),
);

// Add it to the repository
drawingToolsRepo.add(trendLineConfig);
```

## Example: Customizing a Drawing Tool

```dart
// Get the existing tool
final existingTool = drawingToolsRepo.items[0] as TrendLineConfig;

// Create an updated version
final updatedTool = TrendLineConfig(
  id: existingTool.id, // Keep the same ID
  style: DrawingPaintStyle(
    color: Colors.red,
    thickness: 3,
    isDashed: true,
  ),
);

// Update it in the repository
drawingToolsRepo.updateAt(0, updatedTool);
```

## Implementing Custom Drawing Tools

You can create custom drawing tools by implementing the required classes:

1. **DrawingToolConfig**: Configuration for the tool
2. **InteractableDrawing**: The drawing implementation
3. **DrawingCreator**: Logic for creating the drawing

### Example: Custom Drawing Tool

```dart
// Configuration
class CustomToolConfig extends DrawingToolConfig {
  final DrawingPaintStyle style;
  
  CustomToolConfig({
    required this.style,
    super.id,
  });
  
  @override
  String get name => 'Custom Tool';
  
  @override
  InteractableDrawing createDrawing() => CustomInteractableDrawing(
    style: style,
  );
  
  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'CustomTool',
    'style': style.toJson(),
  };
  
  factory CustomToolConfig.fromJson(Map<String, dynamic> json) => CustomToolConfig(
    id: json['id'],
    style: DrawingPaintStyle.fromJson(json['style']),
  );
}

// Drawing Implementation
class CustomInteractableDrawing extends InteractableDrawing {
  final List<Offset> points = [];
  
  CustomInteractableDrawing({
    required DrawingPaintStyle style,
  }) : super(style: style);
  
  @override
  bool hitTest(Offset point) {
    // Implement hit testing logic
    if (points.length < 2) return false;
    
    for (int i = 0; i < points.length - 1; i++) {
      if (isPointNearLine(point, points[i], points[i + 1])) {
        return true;
      }
    }
    
    return false;
  }
  
  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    
    final paint = Paint()
      ..color = style.color
      ..strokeWidth = style.thickness
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  void onDrag(Offset delta) {
    for (int i = 0; i < points.length; i++) {
      points[i] = points[i] + delta;
    }
  }
  
  bool isPointNearLine(Offset point, Offset lineStart, Offset lineEnd) {
    // Calculate distance from point to line
    final double lineLength = (lineEnd - lineStart).distance;
    if (lineLength == 0) return false;
    
    final double t = ((point.dx - lineStart.dx) * (lineEnd.dx - lineStart.dx) +
                      (point.dy - lineStart.dy) * (lineEnd.dy - lineStart.dy)) /
                     (lineLength * lineLength);
    
    if (t < 0) {
      return (point - lineStart).distance < 10;
    } else if (t > 1) {
      return (point - lineEnd).distance < 10;
    } else {
      final Offset projection = lineStart + (lineEnd - lineStart) * t;
      return (point - projection).distance < 10;
    }
  }
}

// Drawing Creator
class CustomToolCreator extends DrawingCreator {
  @override
  void onTap(Offset position) {
    if (drawing == null) {
      drawing = CustomInteractableDrawing(
        style: config.style,
      );
      (drawing as CustomInteractableDrawing).points.add(position);
    } else {
      (drawing as CustomInteractableDrawing).points.add(position);
      
      // If we have enough points, complete the drawing
      if ((drawing as CustomInteractableDrawing).points.length >= 3) {
        onAddDrawing();
      }
    }
  }
}
```

## Next Steps

Now that you understand the drawing tools available in the Deriv Chart library, you can explore:

- [Lines and Channels](lines_and_channels.md) - Learn about line and channel tools
- [Fibonacci Tools](fibonacci_tools.md) - Learn about Fibonacci tools
- [Custom Tools](custom_tools.md) - Learn how to create custom drawing tools
- [Interactive Layer](../interactive_layer.md) - Understand the interactive layer architecture