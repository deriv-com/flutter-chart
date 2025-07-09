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

### Basic Usage

To enable the Interactive Layer V2, simply set the `useDrawingToolsV2` flag to `true`:

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

### Widget Compatibility

The usage is the same for both `DerivChart` and `Chart` widgets:

```dart
// Using DerivChart
DerivChart(
  useDrawingToolsV2: true,
  mainSeries: CandleSeries(candles),
  // Other parameters...
)

// Using Chart widget directly
Chart(
  useDrawingToolsV2: true,
  mainSeries: CandleSeries(candles),
  // Other parameters...
)
```

### Behavior Customization

You can customize the Interactive Layer behavior by passing either mobile or desktop behaviors:

```dart
// Mobile behavior - optimized for touch interactions
final InteractiveLayerBehaviour mobileBehaviour = InteractiveLayerMobileBehaviour();

// Desktop behavior - optimized for mouse and keyboard interactions
final InteractiveLayerBehaviour desktopBehaviour = InteractiveLayerDesktopBehaviour();

Chart(
  useDrawingToolsV2: true,
  interactiveLayerBehaviour: mobileBehaviour, // or desktopBehaviour
  mainSeries: CandleSeries(candles),
  // Other parameters...
)
```

### Dynamic Platform Detection

You can make the behavior instantiation dynamic by checking the platform on your side:

```dart
// Dynamic platform-based behavior selection
final InteractiveLayerBehaviour behaviour = kIsWeb
    ? InteractiveLayerDesktopBehaviour() // For web/desktop
    : InteractiveLayerMobileBehaviour(); // For mobile

Chart(
  useDrawingToolsV2: true,
  interactiveLayerBehaviour: behaviour,
  mainSeries: CandleSeries(candles),
  // Other parameters...
)
```

**Note**: If you don't provide a behavior, the package will use the `kIsWeb` flag internally to automatically select the appropriate behavior.

### Controller for Advanced Control

To have control over the Interactive Layer and get updates of the current state, you can create a controller:

```dart
// Create a controller instance
final InteractiveLayerController controller = InteractiveLayerController();

// Pass the controller to the behavior
final InteractiveLayerBehaviour behaviour = InteractiveLayerMobileBehaviour(
  controller: controller
);

Chart(
  useDrawingToolsV2: true,
  interactiveLayerBehaviour: behaviour,
  mainSeries: CandleSeries(candles),
  // Other parameters...
)
```

The controller allows you to:
- Cancel adding tools programmatically: `controller.cancelAdding()`
- Listen to state changes and show user guidance
- Get updates about the current state of the layer

**Real Implementation Example**: See [`example/lib/main.dart`](../example/lib/main.dart) where a `ListenableBuilder` listens to the controller's state changes and shows a cancel button when adding tools.

## Advanced Customization

### Custom Platform Behavior

You can create more sophisticated platform detection logic:

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

### Controller State Management

The controller provides detailed state information that you can use to enhance user experience:

```dart
// Listen to state changes to show user guidance
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

**Real Implementation**: See the complete implementation in [`example/lib/main.dart`](../example/lib/main.dart) lines 462-482, where the controller state is monitored and a cancel button is shown during tool addition.

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

## Next Steps

Now that you understand how to use the Interactive Layer, you can explore:

- [Interactive Layer Architecture](interactive_layer.md) - Learn about the internal architecture of the Interactive Layer
- [Custom Drawing Tools](../advanced_usage/custom_drawing_tools.md) - Create your own custom drawing tools
- [Advanced Usage](../advanced_usage/performance_optimization.md) - Optimize performance for charts with many drawing tools