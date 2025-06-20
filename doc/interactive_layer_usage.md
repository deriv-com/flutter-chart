# Interactive Layer Usage Guide

This guide provides practical examples and instructions for using the Interactive Layer in the Deriv Chart library. The Interactive Layer enables users to add, manipulate, and interact with drawing tools on charts.

## Introduction to Interactive Layer V2

The Interactive Layer V2 is a new implementation for drawing tools that introduces more control and flexibility over drawing tool behaviors and animations. It provides:

- **More Control and Flexibility**: Enhanced control over drawing tool behaviors and animations
- **Customization Ability**: Consumer apps can customize it from outside and have customized behavior based on different conditions like per-platform behaviors
- **Improved Default Behavior**: The new interactive layer comes with improved default behavior and experience for drawing tools
- **Minimal Impact**: It is introduced with minimum to no effect on the usage of the drawing tools

**Beta Status**: Interactive Layer V2 is currently in beta. To use it, you need to pass the `useDrawingToolsV2` flag as `true` to the chart (default is `false`). Later, it will replace the old implementations of drawing tools.

**Simple Activation**: For just enabling this feature, you need to set this flag to `true` and any drawing tools you add will be on the Interactive Layer V2.

## Getting Started

## Basic Setup

### Enabling Interactive Layer V2

To enable the Interactive Layer V2, simply set the `useDrawingToolsV2` flag to `true` when using the `DerivChart` widget:

```dart
DerivChart(
  useDrawingToolsV2: true, // Enable Interactive Layer V2
  mainSeries: CandleSeries(candles),
  granularity: 60000,
  activeSymbol: 'R_100',
  pipSize: 4,
  drawingToolsRepo: myDrawingToolsRepo, // Optional
)
```

### Standard Setup

Either when using `DerivChart` or `Chart` widgets, users can set the `useDrawingToolsV2` flag as `true` to enable the Interactive Layer V2:

```dart
DerivChart(
  useDrawingToolsV2: true, // Enable Interactive Layer V2
  mainSeries: CandleSeries(candles),
  granularity: 60000,
  activeSymbol: 'R_100',
  pipSize: 4,
  drawingToolsRepo: myDrawingToolsRepo, // Optional
)
```

When using the `Chart` widget directly, the usage is the same as `DerivChart`:

```dart
// For advanced usage of Interactive Layer, we can create a controller instance
final InteractiveLayerController controller = InteractiveLayerController();

// Pass the controller to the behavior - this provides runtime control like canceling adding tools
// programmatically or showing user guides when a tool is being added
final InteractiveLayerBehaviour behaviour = InteractiveLayerMobileBehaviour(
  controller: controller
);

Chart(
  useDrawingToolsV2: true, // Enable Interactive Layer V2
  interactiveLayerBehaviour: behaviour, // Pass behavior instance to define the behavior explicitly
  mainSeries: CandleSeries(candles),
  pipSize: 2,
  granularity: 60000,
  // Other parameters...
)
```

## Customizing Interactive Layer Behavior

The Interactive Layer V2 allows you to customize how drawing tools behave by providing a specific `InteractiveLayerBehaviour` implementation.

### Platform-Specific Behaviors

The `InteractiveLayerBehaviour` defines how the layer will behave. By default, there are two implementations:

- **Desktop Behavior**: `InteractiveLayerDesktopBehaviour` - Optimized for mouse and keyboard interactions
- **Mobile Behavior**: `InteractiveLayerMobileBehaviour` - Optimized for touch-friendly environments

The behavior is customizable by creating custom behavior and passing it to the chart.

#### Automatic Platform Detection

By default, the package will automatically select the appropriate behavior based on the `kIsWeb` flag, but you can explicitly specify which behavior to use:

```dart
// Automatic platform detection (recommended)
DerivChart(
  useDrawingToolsV2: true,
  mainSeries: CandleSeries(candles),
  // The package will automatically choose desktop or mobile behavior
)

// Manual platform-specific behavior
final InteractiveLayerBehaviour behaviour = kIsWeb
    ? InteractiveLayerDesktopBehaviour() // For mouse-based interactions
    : InteractiveLayerMobileBehaviour();  // For touch-based interactions

DerivChart(
  useDrawingToolsV2: true,
  interactiveLayerBehaviour: behaviour,
  mainSeries: CandleSeries(candles),
)
```

#### Conditional Platform Behavior

You can make this conditional and check your environment to send the mobile or desktop behavior accordingly:

```dart
// Example: Force mobile behavior on tablets even if on web
final bool isMobileEnvironment = Platform.isAndroid || Platform.isIOS || 
    (kIsWeb && MediaQuery.of(context).size.width < 768);

final InteractiveLayerBehaviour behaviour = isMobileEnvironment
    ? InteractiveLayerMobileBehaviour()
    : InteractiveLayerDesktopBehaviour();

DerivChart(
  useDrawingToolsV2: true,
  interactiveLayerBehaviour: behaviour,
  mainSeries: CandleSeries(candles),
)
```

### Using a Controller

For advanced usage of the Interactive Layer, you can create a controller instance and pass it to the behavior class to have runtime control over the layer, such as:

- **Starting a tool addition flow**
- **Canceling the flow programmatically**
- **Getting updated information about the current state of the layer**
- **Performing actions in the consumer app** (like showing user guides or steps when a tool is being added)

```dart
// Create a controller
final InteractiveLayerController controller = InteractiveLayerController();

// Create a mobile behavior with the controller
final InteractiveLayerBehaviour behaviour = InteractiveLayerMobileBehaviour(
  controller: controller
);

// Use it with DerivChart
DerivChart(
  useDrawingToolsV2: true,
  interactiveLayerBehaviour: behaviour,
  mainSeries: CandleSeries(candles),
  // Other parameters...
)

// Use the controller to cancel adding
controller.cancelAdding();

// Listen to state changes to show user guidance
// Example: Check if the controller current state is adding state and call cancelAdding method
ListenableBuilder(
  listenable: controller,
  builder: (context, _) {
    if (controller.currentState is InteractiveAddingToolState) {
      return Column(
        children: [
          Text('Currently adding a drawing tool'),
          Text('Tap on the chart to place the tool'),
          ElevatedButton(
            onPressed: controller.cancelAdding,
            child: Text('Cancel'),
          ),
        ],
      );
    }
    return SizedBox();
  },
)
```

**Real Implementation Example**: You can see a complete working example of this pattern in [`example/lib/main.dart`](../example/lib/main.dart) where a `ListenableBuilder` listens to the controller's state changes. When the controller's current state is `InteractiveAddingToolState`, it shows a cancel button that calls the `cancelAdding()` method of the controller.

### Complete Example

Here's a complete example showing how to use the Interactive Layer V2 with a controller (based on the example in `example/lib/main.dart`):

```dart
class ChartWithInteractiveLayer extends StatefulWidget {
  @override
  _ChartWithInteractiveLayerState createState() => _ChartWithInteractiveLayerState();
}

class _ChartWithInteractiveLayerState extends State<ChartWithInteractiveLayer> {
  final InteractiveLayerController _interactiveLayerController = 
      InteractiveLayerController();
  late final InteractiveLayerBehaviour _interactiveLayerBehaviour;
  
  @override
  void initState() {
    super.initState();
    
    // Create the appropriate behavior based on platform with controller
    _interactiveLayerBehaviour = kIsWeb
        ? InteractiveLayerDesktopBehaviour(
            controller: _interactiveLayerController)
        : InteractiveLayerMobileBehaviour(
            controller: _interactiveLayerController);
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DerivChart(
          useDrawingToolsV2: true,
          interactiveLayerBehaviour: _interactiveLayerBehaviour,
          mainSeries: CandleSeries(candles),
          granularity: 60000,
          activeSymbol: 'R_100',
          pipSize: 4,
          // Other chart parameters...
        ),
        
        // UI to show a cancel button when adding a drawing tool
        Positioned(
          top: 16,
          right: 16,
          child: ListenableBuilder(
            listenable: _interactiveLayerController,
            builder: (_, __) {
              if (_interactiveLayerController.currentState 
                  is InteractiveAddingToolState) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Cancel adding'),
                    IconButton(
                      onPressed: _interactiveLayerController.cancelAdding,
                      icon: const Icon(Icons.cancel),
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }
}
```

## Managing Drawing Tools

### Creating a Drawing Tools Repository

The `AddOnsRepository` class is used to manage drawing tools:

```dart
final drawingToolsRepo = AddOnsRepository<DrawingToolConfig>(
  createAddOn: (Map<String, dynamic> map) => DrawingToolConfig.fromJson(map),
  sharedPrefKey: 'R_100', // Use the symbol code for saving settings
);
```

### Adding Drawing Tools

You can add drawing tools to the repository programmatically:

```dart
// Add a horizontal line
drawingToolsRepo.add(HorizontalLineDrawingToolConfig(
  value: 125.0,
  color: Colors.red,
  lineStyle: LineStyle.dashed,
));

// Add a trend line
drawingToolsRepo.add(TrendLineDrawingToolConfig(
  startPoint: Point(1625097600000, 120.0), // (epoch, quote)
  endPoint: Point(1625184000000, 130.0),   // (epoch, quote)
  color: Colors.blue,
  lineStyle: LineStyle.solid,
));
```

### Removing Drawing Tools

To remove a drawing tool:

```dart
drawingToolsRepo.remove(drawingToolConfig);
```

### Clearing All Drawing Tools

To remove all drawing tools:

```dart
drawingToolsRepo.clear();
```

## User Interaction Modes

The Interactive Layer supports different interaction modes:

### Normal Mode

In normal mode, users can:
- Select existing drawing tools by tapping on them
- Initiate adding new drawing tools

### Selected Tool Mode

When a drawing tool is selected, users can:
- Move the entire tool by dragging it
- Modify specific points of the tool using control handles
- Delete the tool (typically through a context menu or delete button)

### Adding Tool Mode

When adding a new tool, users can:
- Tap on the chart to define points for the new tool
- Drag to position certain types of tools
- Confirm the addition with a final tap

## Platform-Specific Behavior

The Interactive Layer automatically adapts to different platforms:

### Desktop Behavior

On desktop platforms, the Interactive Layer:
- Supports hover effects
- Uses mouse clicks for precise positioning
- May use keyboard shortcuts for additional functionality

### Mobile Behavior

On mobile platforms, the Interactive Layer:
- Uses touch gestures optimized for finger input
- Provides larger touch targets
- May use multi-touch gestures for certain operations

## Adding Drawing Tools via UI

To enable users to add drawing tools through the UI:

1. Create a button or menu item for each drawing tool type
2. When the user selects a tool, call the appropriate method:

```dart
// When the user clicks on the "Add Horizontal Line" button
void onAddHorizontalLinePressed() {
  final config = HorizontalLineDrawingToolConfig(
    color: Colors.red,
    lineStyle: LineStyle.dashed,
  );
  
  // If using DerivChart with automatic repository management
  derivChartController.addDrawingTool(config);
  
  // Or if managing the repository yourself
  drawingToolsRepo.add(config);
}
```

## Customizing Drawing Tools

You can customize the appearance and behavior of drawing tools:

```dart
// Customize a horizontal line
final horizontalLine = HorizontalLineDrawingToolConfig(
  value: 125.0,
  color: Colors.red,
  lineStyle: LineStyle.dashed,
  lineThickness: 2.0,
  extendToRight: true,  // Extend the line to the right edge of the chart
  labelVisible: true,   // Show a label with the price value
  labelPosition: LabelPosition.right,
);

// Customize a trend line
final trendLine = TrendLineDrawingToolConfig(
  startPoint: Point(1625097600000, 120.0),
  endPoint: Point(1625184000000, 130.0),
  color: Colors.blue,
  lineStyle: LineStyle.solid,
  lineThickness: 2.0,
  extendToRight: false,
  extendToLeft: false,
);
```

## Listening to Drawing Tool Events

You can listen to events related to drawing tools:

```dart
DerivChart(
  // ... other parameters
  onDrawingToolAdded: (DrawingToolConfig config) {
    print('Drawing tool added: ${config.type}');
  },
  onDrawingToolRemoved: (DrawingToolConfig config) {
    print('Drawing tool removed: ${config.type}');
  },
  onDrawingToolSelected: (DrawingToolConfig config) {
    print('Drawing tool selected: ${config.type}');
  },
)
```

## Available Drawing Tools

The Deriv Chart library includes several built-in drawing tools:

| Tool | Description | Configuration Class |
|------|-------------|---------------------|
| Horizontal Line | A horizontal line at a specific price level | `HorizontalLineDrawingToolConfig` |
| Vertical Line | A vertical line at a specific time point | `VerticalLineDrawingToolConfig` |
| Trend Line | A line connecting two points | `TrendLineDrawingToolConfig` |
| Ray | A line extending from a point in one direction | `RayDrawingToolConfig` |
| Rectangle | A rectangle defined by two corner points | `RectangleDrawingToolConfig` |
| Channel | Parallel lines defining a price channel | `ChannelDrawingToolConfig` |
| Fibonacci Fan | Fibonacci fan lines from a point | `FibonacciFanDrawingToolConfig` |

## Best Practices

1. **Platform Adaptation**: Let the Interactive Layer handle platform-specific behavior automatically by using the appropriate `InteractiveLayerBehaviour` implementation.

2. **Repository Management**: Use the `AddOnsRepository` to manage drawing tools, which provides persistence and easy addition/removal of tools.

3. **User Experience**: Provide clear UI elements for adding, selecting, and removing drawing tools to ensure a good user experience.

4. **Error Handling**: Implement proper error handling for cases where drawing tools might be invalid or outside the visible chart area.

5. **Performance**: Be mindful of the number of drawing tools added to a chart, as a large number can impact performance.

6. **Controller Usage**: Use the `InteractiveLayerController` to provide user guidance and control over the drawing process.

## Next Steps

Now that you understand how to use the Interactive Layer, you can explore:

- [Interactive Layer Architecture](interactive_layer.md) - Learn about the internal architecture of the Interactive Layer
- [Custom Drawing Tools](../advanced_usage/custom_drawing_tools.md) - Create your own custom drawing tools
- [Advanced Usage](../advanced_usage/performance_optimization.md) - Optimize performance for charts with many drawing tools