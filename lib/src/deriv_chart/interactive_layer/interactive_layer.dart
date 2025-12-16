// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';
import 'package:deriv_chart/src/deriv_chart/chart/multiple_animated_builder.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/y_axis/y_axis_config.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_controller.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_variant.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_widget.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/drawing_context.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/drawing_tool_gesture_recognizer.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/helpers/types.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_states/interactive_adding_tool_state.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_states/interactive_selected_tool_state.dart';
import 'package:deriv_chart/src/models/axis_range.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../chart/data_visualization/chart_data.dart';
import '../chart/data_visualization/chart_series/data_series.dart';
import '../chart/data_visualization/drawing_tools/ray/ray_line_drawing.dart';
import '../chart/data_visualization/models/animation_info.dart';
import '../drawing_tool_chart/drawing_tools.dart';
import 'interactable_drawings/drawing_v2.dart';
import 'interactable_drawings/interactable_drawing.dart';
import 'interactable_drawing_custom_painter.dart';
import 'interaction_notifier.dart';
import 'interactive_layer_base.dart';
import 'enums/state_change_direction.dart';
import 'interactive_layer_behaviours/interactive_layer_behaviour.dart';
import 'interactive_layer_states/interactive_normal_state.dart';

/// Defines the different interaction modes for the interactive layer.
///
/// The interaction mode determines how the chart responds to user input:
/// * [none] - No active interaction is occurring
/// * [drawingTool] - User is interacting with a drawing tool
/// * [crosshair] - User is interacting with the crosshair
enum InteractionMode {
  /// No active interaction is occurring
  none,

  /// User is interacting with a drawing tool
  drawingTool,

  /// User is interacting with the crosshair
  crosshair,
}

/// Interactive layer of the chart package where elements can be drawn and can
/// be interacted with.
class InteractiveLayer extends StatefulWidget {
  /// Initializes the interactive layer.
  const InteractiveLayer({
    required this.drawingTools,
    required this.series,
    required this.chartConfig,
    required this.quoteToCanvasY,
    required this.quoteFromCanvasY,
    required this.epochToCanvasX,
    required this.epochFromCanvasX,
    required this.drawingToolsRepo,
    required this.quoteRange,
    required this.interactiveLayerBehaviour,
    required this.crosshairZoomOutAnimation,
    required this.crosshairController,
    required this.crosshairVariant,
    this.showCrosshair = true,
    this.pipSize = 4,
    this.onCrosshairAppeared,
    this.onCrosshairDisappeared,
    super.key,
  });

  /// Interactive layer behaviour which defines how interactive layer should
  /// behave in scenarios like adding/dragging, etc.
  final InteractiveLayerBehaviour interactiveLayerBehaviour;

  /// Drawing tools.
  final DrawingTools drawingTools;

  /// Drawing tools repo.
  final Repository<DrawingToolConfig> drawingToolsRepo;

  /// Main Chart series
  final DataSeries<Tick> series;

  /// Chart configuration
  final ChartConfig chartConfig;

  /// Converts quote to canvas Y coordinate.
  final QuoteToY quoteToCanvasY;

  /// Converts canvas Y coordinate to quote.
  final QuoteFromY quoteFromCanvasY;

  /// Converts canvas X coordinate to epoch.
  final EpochFromX epochFromCanvasX;

  /// Converts epoch to canvas X coordinate.
  final EpochToX epochToCanvasX;

  /// Chart's y-axis range.
  final QuoteRange quoteRange;

  /// Whether to show the crosshair or not.
  final bool showCrosshair;

  /// Number of decimal digits when showing prices in the crosshair.
  final int pipSize;

  /// Called when the crosshair appears.
  final VoidCallback? onCrosshairAppeared;

  /// Called when the crosshair disappears.
  final VoidCallback? onCrosshairDisappeared;

  /// Animation for zooming out the crosshair
  final Animation<double> crosshairZoomOutAnimation;

  /// Crosshair controller
  final CrosshairController crosshairController;

  /// The variant of the crosshair to be used.
  /// This is used to determine the type of crosshair to display.
  /// The default is [CrosshairVariant.smallScreen].
  /// [CrosshairVariant.largeScreen] is mostly for web.
  final CrosshairVariant crosshairVariant;

  @override
  State<InteractiveLayer> createState() => _InteractiveLayerState();
}

class _InteractiveLayerState extends State<InteractiveLayer> {
  final Map<String, InteractableDrawing> _interactableDrawings =
      <String, InteractableDrawing>{};

  @override
  void initState() {
    super.initState();

    widget.drawingToolsRepo.addListener(syncDrawingsWithConfigs);
  }

  void syncDrawingsWithConfigs() {
    final interactiveLayerBehaviour = widget.interactiveLayerBehaviour;
    final interactiveLayer = interactiveLayerBehaviour.interactiveLayer;
    final drawingContext = interactiveLayer.drawingContext;

    // Ensure drawing context is available before creating drawings
    if (drawingContext.fullSize == Size.zero) {
      // Drawing context not ready yet, schedule retry after next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          syncDrawingsWithConfigs();
        }
      });
      return;
    }

    final configListIds =
        widget.drawingToolsRepo.items.map((c) => c.configId).toSet();

    for (final config in widget.drawingToolsRepo.items) {
      if (!_interactableDrawings.containsKey(config.configId)) {
        // Add new drawing if it doesn't exist
        final drawing = config.getInteractableDrawing(
          drawingContext,
          interactiveLayerBehaviour.getToolState,
        );
        _interactableDrawings[config.configId!] = drawing;
      }
    }

    bool anyToolRemoved = false;

    // Remove drawings that are not in the config list
    _interactableDrawings.removeWhere((id, _) {
      if (!configListIds.contains(id)) {
        anyToolRemoved = true;
        return true;
      }
      return false;
    });

    if (anyToolRemoved) {
      widget.interactiveLayerBehaviour.updateStateTo(
        InteractiveNormalState(
          interactiveLayerBehaviour: widget.interactiveLayerBehaviour,
        ),
        StateChangeAnimationDirection.forward,
      );
    }

    setState(() {});
  }

  /// Updates the config in the repository with debouncing
  void _updateConfigInRepository(DrawingToolConfig drawing) {
    final String? configId = drawing.configId;

    if (configId == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    final Repository<DrawingToolConfig> repo =
        context.read<Repository<DrawingToolConfig>>();

    // Find the index of the config in the repository
    final int index =
        repo.items.indexWhere((config) => config.configId == drawing.configId);

    if (index == -1) {
      return; // Config not found
    }

    // Update the config in the repository
    repo.updateAt(index, drawing);
  }

  DrawingToolConfig _addDrawingToRepo(DrawingToolConfig drawing) {
    final config = drawing.copyWith(
      configId: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    widget.drawingToolsRepo.add(config);

    return config;
  }

  @override
  void dispose() {
    widget.drawingToolsRepo.removeListener(syncDrawingsWithConfigs);
    super.dispose();
  }

  bool get isStillMounted => mounted;

  @override
  Widget build(BuildContext context) {
    return _InteractiveLayerGestureHandler(
      drawings: _interactableDrawings.values.toList(),
      epochFromX: widget.epochFromCanvasX,
      quoteFromY: widget.quoteFromCanvasY,
      epochToX: widget.epochToCanvasX,
      quoteToY: widget.quoteToCanvasY,
      series: widget.series,
      chartConfig: widget.chartConfig,
      addingDrawingTool: widget.drawingTools.selectedDrawingTool,
      quoteRange: widget.quoteRange,
      interactiveLayerBehaviour: widget.interactiveLayerBehaviour,
      onClearAddingDrawingTool: widget.drawingTools.clearDrawingToolSelection,
      onSaveDrawingChange: _updateConfigInRepository,
      onAddDrawing: _addDrawingToRepo,
      onRemoveDrawing: widget.drawingToolsRepo.remove,
      showCrosshair: widget.showCrosshair,
      pipSize: widget.pipSize,
      crosshairZoomOutAnimation: widget.crosshairZoomOutAnimation,
      onCrosshairAppeared: widget.onCrosshairAppeared,
      onCrosshairDisappeared: widget.onCrosshairDisappeared,
      crosshairController: widget.crosshairController,
      crosshairVariant: widget.crosshairVariant,
    );
  }
}

class _InteractiveLayerGestureHandler extends StatefulWidget {
  const _InteractiveLayerGestureHandler({
    required this.drawings,
    required this.epochFromX,
    required this.quoteFromY,
    required this.epochToX,
    required this.quoteToY,
    required this.series,
    required this.chartConfig,
    required this.onClearAddingDrawingTool,
    required this.onAddDrawing,
    required this.quoteRange,
    required this.interactiveLayerBehaviour,
    required this.crosshairZoomOutAnimation,
    required this.crosshairController,
    required this.crosshairVariant,
    this.addingDrawingTool,
    this.onSaveDrawingChange,
    this.onRemoveDrawing,
    this.showCrosshair = true,
    this.pipSize = 4,
    this.onCrosshairAppeared,
    this.onCrosshairDisappeared,
  });

  final List<InteractableDrawing> drawings;

  final InteractiveLayerBehaviour interactiveLayerBehaviour;

  final Function(DrawingToolConfig)? onSaveDrawingChange;
  final Function(DrawingToolConfig)? onRemoveDrawing;

  final DrawingToolConfig Function(DrawingToolConfig) onAddDrawing;

  final DrawingToolConfig? addingDrawingTool;

  /// To be called whenever adding the [addingDrawingTool] is done to clear it.
  final VoidCallback onClearAddingDrawingTool;

  /// Main Chart series
  final DataSeries<Tick> series;

  /// Chart configuration
  final ChartConfig chartConfig;

  final EpochFromX epochFromX;
  final QuoteFromY quoteFromY;
  final EpochToX epochToX;
  final QuoteToY quoteToY;
  final QuoteRange quoteRange;

  /// Whether to show the crosshair or not.
  final bool showCrosshair;

  /// Number of decimal digits when showing prices in the crosshair.
  final int pipSize;

  /// Called when the crosshair appears.
  final VoidCallback? onCrosshairAppeared;

  /// Called when the crosshair disappears.
  final VoidCallback? onCrosshairDisappeared;

  /// Animation for zooming out the crosshair
  final Animation<double> crosshairZoomOutAnimation;

  /// Crosshair controller
  final CrosshairController crosshairController;

  /// The variant of the crosshair to be used.
  /// This is used to determine the type of crosshair to display.
  /// The default is [CrosshairVariant.smallScreen].
  /// [CrosshairVariant.largeScreen] is mostly for web.
  final CrosshairVariant crosshairVariant;

  @override
  State<_InteractiveLayerGestureHandler> createState() =>
      _InteractiveLayerGestureHandlerState();
}

class _InteractiveLayerGestureHandlerState
    extends State<_InteractiveLayerGestureHandler>
    with TickerProviderStateMixin
    implements InteractiveLayerBase {
  late AnimationController _stateChangeController;
  static const Curve _stateChangeCurve = Curves.easeOut;
  final InteractionNotifier _interactionNotifier = InteractionNotifier();

  String? _addedDrawing;

  @override
  bool get isStillMounted => mounted;

  @override
  AnimationController? get stateChangeAnimationController =>
      _stateChangeController;

  DrawingContext _drawingContext = DrawingContext(
    fullSize: Size.zero,
    contentSize: Size.zero,
  );

  // The current interaction mode
  InteractionMode _currentInteractionMode = InteractionMode.none;

  MouseCursor _mouseCursor = SystemMouseCursors.basic;

  // Custom gesture recognizer for drawing tools
  late DrawingToolGestureRecognizer _drawingToolGestureRecognizer;

  @override
  void initState() {
    super.initState();

    _stateChangeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );

    widget.interactiveLayerBehaviour.init(
      interactiveLayer: this,
      onUpdate: () => setState(() {}),
      stateChangeController: _stateChangeController,
    );
    // Initialize the drawing tool gesture recognizer once
    _drawingToolGestureRecognizer = DrawingToolGestureRecognizer(
      onDrawingToolPanStart: _handleDrawingToolPanStart,
      onDrawingToolPanUpdate: _handleDrawingToolPanUpdate,
      onDrawingToolPanEnd: _handleDrawingToolPanEnd,
      onDrawingToolPanCancel: _handleDrawingToolPanCancel,
      onDrawingToolLongPress: _handleDrawingToolLongPress,
      onDrawingToolLongPressEnd: _handleDrawingToolLongPressEnd,
      hitTest: widget.interactiveLayerBehaviour.hitTestDrawings,
      onCrosshairCancel: _cancelCrosshair,
      debugOwner: this,
    );
  }

  @override
  void didUpdateWidget(covariant _InteractiveLayerGestureHandler oldWidget) {
    super.didUpdateWidget(oldWidget);

    _checkAddingToolToLayer(oldWidget);
  }

  void _checkAddingToolToLayer(_InteractiveLayerGestureHandler oldWidget) {
    _checkNeedStartAdding(oldWidget);
    _checkIsAToolAdded();
  }

  /// Checks if user want to add a new drawing tool and starts adding it if so
  void _checkNeedStartAdding(_InteractiveLayerGestureHandler oldWidget) {
    if (widget.addingDrawingTool != null &&
        widget.addingDrawingTool != oldWidget.addingDrawingTool) {
      widget.interactiveLayerBehaviour
          .startAddingTool(widget.addingDrawingTool!);
    }
  }

  /// Checks if a tool has been added to the layer and updates the state to
  /// [InteractiveSelectedToolState] if it has.
  void _checkIsAToolAdded() {
    for (final drawing in widget.drawings) {
      if (drawing.id == _addedDrawing) {
        WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
            (_) => widget.interactiveLayerBehaviour.aNewToolsIsAdded(drawing));
        break;
      }
    }

    _addedDrawing = null;
  }

  @override
  Future<void> animateStateChange(
    StateChangeAnimationDirection direction, {
    bool animate = true,
  }) async {
    await _runAnimation(direction, animate);
  }

  Future<void> _runAnimation(
    StateChangeAnimationDirection direction,
    bool animate,
  ) async {
    if (direction == StateChangeAnimationDirection.forward) {
      _stateChangeController.reset();
      if (animate) {
        await _stateChangeController.forward();
      } else {
        _stateChangeController.value = 1.0;
      }
    } else {
      if (animate) {
        await _stateChangeController.reverse(from: 1);
      } else {
        _stateChangeController.value = 0.0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();
    return LayoutBuilder(builder: (_, BoxConstraints constraints) {
      final YAxisConfig yAxisConfig = YAxisConfig.instance;

      _drawingContext = DrawingContext(
        fullSize: Size(constraints.maxWidth, constraints.maxHeight),
        contentSize: Size(
          constraints.maxWidth - yAxisConfig.cachedLabelWidth!,
          constraints.maxHeight,
        ),
      );
      // Reconfigure the drawing tool gesture recognizer instead of creating a new one
      _drawingToolGestureRecognizer.updateCallbacks(
        onDrawingToolPanStart: _handleDrawingToolPanStart,
        onDrawingToolPanUpdate: _handleDrawingToolPanUpdate,
        onDrawingToolPanEnd: _handleDrawingToolPanEnd,
        onDrawingToolPanCancel: _handleDrawingToolPanCancel,
        onDrawingToolLongPress: _handleDrawingToolLongPress,
        onDrawingToolLongPressEnd: _handleDrawingToolLongPressEnd,
        hitTest: widget.interactiveLayerBehaviour.hitTestDrawings,
        onCrosshairCancel: _cancelCrosshair,
      );
      return MouseRegion(
        onHover: (event) => _handleHover(event, xAxis),
        onExit: _handleExit,
        cursor: _mouseCursor,
        child: RawGestureDetector(
          gestures: <Type, GestureRecognizerFactory>{
            // Configure tap recognizer
            TapGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
              () => TapGestureRecognizer(),
              (TapGestureRecognizer instance) {
                instance.onTapUp = _handleTapUp;
              },
            ),

            // Configure our custom drawing tool gesture recognizer
            DrawingToolGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                DrawingToolGestureRecognizer>(
              () => _drawingToolGestureRecognizer,
              (DrawingToolGestureRecognizer instance) {
                // Configuration is done in the reset method
              },
            ),

            // Configure long press recognizer
            LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                LongPressGestureRecognizer>(
              () => LongPressGestureRecognizer(),
              (LongPressGestureRecognizer instance) {
                instance
                  ..onLongPressStart = _handleLongPressStart
                  ..onLongPressMoveUpdate = _handleLongPressMoveUpdate
                  ..onLongPressEnd = _handleLongPressEnd;
              },
            ),
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              _buildDrawingsLayer(context, xAxis),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDrawingsLayer(BuildContext context, XAxisModel xAxis) =>
      RepaintBoundary(
        child: MultipleAnimatedBuilder(
            animations: [
              _stateChangeController,
              _interactionNotifier,
              widget.interactiveLayerBehaviour.controller
            ],
            builder: (_, __) {
              final double animationValue =
                  _stateChangeCurve.transform(_stateChangeController.value);

              return Stack(
                fit: StackFit.expand,
                children: widget.series.input.isEmpty
                    ? []
                    : [
                        ...widget.drawings
                            .where(
                              (e) =>
                                  widget.interactiveLayerBehaviour
                                      .getToolZOrder(e) ==
                                  DrawingZOrder.bottom,
                            )
                            .map((DrawingV2 drawing) => _buildDrawing(
                                  drawing,
                                  context,
                                  xAxis,
                                  animationValue,
                                ))
                            .toList(),
                        ...widget.drawings
                            .where(
                              (e) =>
                                  widget.interactiveLayerBehaviour
                                      .getToolZOrder(e) ==
                                  DrawingZOrder.top,
                            )
                            .map((DrawingV2 drawing) => _buildDrawing(
                                  drawing,
                                  context,
                                  xAxis,
                                  animationValue,
                                ))
                            .toList(),
                        ...widget.interactiveLayerBehaviour.previewDrawings
                            .map((DrawingV2 drawing) => _buildDrawing(
                                  drawing,
                                  context,
                                  xAxis,
                                  animationValue,
                                ))
                            .toList(),
                        CrosshairWidget(
                          mainSeries: widget.series,
                          quoteToCanvasY: widget.quoteToY,
                          quoteFromCanvasY: widget.quoteFromY,
                          pipSize: widget.pipSize,
                          crosshairController: widget.crosshairController,
                          crosshairZoomOutAnimation:
                              widget.crosshairZoomOutAnimation,
                          crosshairVariant: widget.crosshairVariant,
                          showCrosshair: widget.showCrosshair,
                        ),
                        ...widget.interactiveLayerBehaviour.previewWidgets,
                      ],
              );
            }),
      );

  CustomPaint _buildDrawing(
    DrawingV2 e,
    BuildContext context,
    XAxisModel xAxis,
    double animationValue,
  ) =>
      CustomPaint(
        key: ValueKey<String>(e.id),
        foregroundPainter: InteractableDrawingCustomPainter(
          drawing: e,
          currentDrawingState: widget.interactiveLayerBehaviour.getToolState(e),
          drawingState: widget.interactiveLayerBehaviour.getToolState,
          series: widget.series,
          theme: context.watch<ChartTheme>(),
          chartConfig: widget.chartConfig,
          epochFromX: xAxis.epochFromX,
          epochToX: xAxis.xFromEpoch,
          quoteToY: widget.quoteToY,
          quoteFromY: widget.quoteFromY,
          epochRange: EpochRange(
            rightEpoch: xAxis.rightBoundEpoch,
            leftEpoch: xAxis.leftBoundEpoch,
          ),
          quoteRange: widget.quoteRange,
          animationInfo: AnimationInfo(
            stateChangePercent: animationValue,
          ),
        ),
      );

  @override
  List<InteractableDrawing<DrawingToolConfig>> get drawings => widget.drawings;

  @override
  EpochFromX get epochFromX => widget.epochFromX;

  @override
  EpochToX get epochToX => widget.epochToX;

  @override
  QuoteFromY get quoteFromY => widget.quoteFromY;

  @override
  QuoteToY get quoteToY => widget.quoteToY;

  @override
  void clearAddingDrawing() => widget.onClearAddingDrawingTool.call();

  @override
  DrawingToolConfig addDrawing(DrawingToolConfig drawing) {
    final config = widget.onAddDrawing.call(drawing);
    _addedDrawing = config.configId;
    return config;
  }

  @override
  void saveDrawing(DrawingToolConfig drawing) =>
      widget.onSaveDrawingChange?.call(drawing);

  @override
  void removeDrawing(DrawingToolConfig drawing) =>
      widget.onRemoveDrawing?.call(drawing);

  @override
  void dispose() {
    _interactionNotifier.dispose();
    _stateChangeController.dispose();
    _drawingToolGestureRecognizer.dispose();
    super.dispose();
  }

  @override
  DrawingContext get drawingContext => _drawingContext;

  @override
  void hideCrosshair() {
    _cancelCrosshair();
  }

  // Update the interaction mode and notify listeners if needed
  void _updateInteractionMode(InteractionMode mode) {
    if (_currentInteractionMode != mode) {
      setState(() {
        _currentInteractionMode = mode;
      });
    }
  }

  // Method to cancel any active crosshair
  void _cancelCrosshair() {
    // Always hide the crosshair if it's visible, regardless of interaction mode
    // This handles cases where crosshair is visible from hover but interaction mode isn't crosshair
    if (widget.crosshairController.value.isVisible) {
      widget.crosshairController.onExit(const PointerExitEvent());
    }

    // Only update interaction mode if we were actually in crosshair mode
    if (_currentInteractionMode == InteractionMode.crosshair) {
      _updateInteractionMode(InteractionMode.none);
    }
  }

  // Handle drawing tool pan start
  void _handleDrawingToolPanStart(DragStartDetails details) {
    // The custom gesture recognizer has already determined that a drawing was hit,
    // so we don't need to check again with widget.interactiveLayerBehaviour.onPanStart(details);
    // Just delegate to the interactive state and update the mode
    widget.interactiveLayerBehaviour.onPanStart(details);
    _updateInteractionMode(InteractionMode.drawingTool);

    // Hide the crosshair when starting to drag a drawing tool
    widget.crosshairController.onExit(const PointerExitEvent());

    _interactionNotifier.notify();
  }

  // Handle drawing tool pan update
  void _handleDrawingToolPanUpdate(DragUpdateDetails details) {
    final bool affectingDrawing =
        widget.interactiveLayerBehaviour.onPanUpdate(details);

    if (affectingDrawing) {
      _updateInteractionMode(InteractionMode.drawingTool);

      // Ensure crosshair remains hidden during drawing tool drag
      if (widget.crosshairController.value.isVisible) {
        widget.crosshairController.onExit(const PointerExitEvent());
      }
    }
    _interactionNotifier.notify();
  }

  // Handle drawing tool pan end
  void _handleDrawingToolPanEnd(DragEndDetails details) {
    widget.interactiveLayerBehaviour.onPanEnd(details);
    _updateInteractionMode(InteractionMode.none);
    _interactionNotifier.notify();
  }

  // Handle drawing tool pan cancel
  void _handleDrawingToolPanCancel() {
    _updateInteractionMode(InteractionMode.none);
  }

  // Handle drawing tool long press
  void _handleDrawingToolLongPress(Offset localPosition) {
    widget.interactiveLayerBehaviour.onLongPress(localPosition);
    _updateInteractionMode(InteractionMode.drawingTool);
  }

  // Handle drawing tool long press end
  void _handleDrawingToolLongPressEnd() {
    widget.interactiveLayerBehaviour.onLongPressEnd();
  }

  void _handleHover(PointerHoverEvent event, XAxisModel xAxis) {
    final newMouseCursor = _getMouseCursor(event.localPosition, xAxis);
    if (_mouseCursor != newMouseCursor) {
      setState(() {
        _mouseCursor = newMouseCursor;
      });
    }
    final bool layerConsumingHover =
        widget.interactiveLayerBehaviour.onHover(event);

    _interactionNotifier.notify();

    // Determine the appropriate interaction mode based on current state
    // If we're hovering over a drawing, we should be in drawing tool mode
    // Otherwise, we should be in normal mode.
    _updateInteractionMode(
      layerConsumingHover ? InteractionMode.drawingTool : InteractionMode.none,
    );

    // Check if we should show crosshair based on drawing tool selection and hover state
    final bool shouldShowCrosshair =
        _shouldShowCrosshairOnHover(event.localPosition, layerConsumingHover);

    // For small screen variant, we don't show the crosshair on hover
    if (widget.crosshairVariant == CrosshairVariant.smallScreen) {
      return;
    }

    // Show or hide crosshair based on the logic
    if (shouldShowCrosshair) {
      widget.crosshairController.onHover(event);
    } else {
      // Hide crosshair if it shouldn't be shown
      widget.crosshairController.onExit(const PointerExitEvent());
    }
  }

  /// Determines whether the crosshair should be shown based on drawing tool selection and hover state.
  ///
  /// The logic is:
  /// - If a drawing tool is selected and the mouse is hovering over it, don't show crosshair
  /// - If a drawing tool is not selected and the mouse hovers over it, show crosshair
  /// - If no drawing tool is being hovered over, show crosshair (normal behavior)
  bool _shouldShowCrosshairOnHover(
      Offset localPosition, bool layerConsumingHover) {
    final currentState = widget.interactiveLayerBehaviour.currentState;

    // If we're in adding tool state, don't show crosshair
    if (currentState is InteractiveAddingToolState) {
      return false;
    }

    // If we're in selected tool state, only hide crosshair when hovering over the selected tool
    if (currentState is InteractiveSelectedToolState) {
      // Find which drawing we're hovering over
      final InteractableDrawing<DrawingToolConfig>? hoveredDrawing =
          _findHoveredDrawing(localPosition);

      if (hoveredDrawing != null &&
          hoveredDrawing.id == currentState.selected.id) {
        // Only hide crosshair if we're hovering over the selected tool
        return false;
      }
      // For all other cases (hovering over different tool or empty space), show crosshair
      return true;
    }

    // For normal state, show crosshair
    return true;
  }

  /// Finds the drawing that is currently being hovered over.
  InteractableDrawing<DrawingToolConfig>? _findHoveredDrawing(
      Offset localPosition) {
    // Check regular drawings
    for (final drawing in widget.drawings) {
      if (drawing.hitTest(localPosition, epochToX, quoteToY)) {
        return drawing;
      }
    }

    // Check preview drawings
    for (final drawing in widget.interactiveLayerBehaviour.previewDrawings) {
      if (drawing.hitTest(localPosition, epochToX, quoteToY)) {
        // Preview drawings don't have the same interface, so we return null
        // This is fine since preview drawings are temporary and shouldn't affect crosshair logic
        return null;
      }
    }

    return null;
  }

  /// Determines the appropriate cursor based on the mouse position and interaction mode
  MouseCursor _getMouseCursor(Offset localPosition, XAxisModel xAxis) {
    // If we're interacting with a drawing tool, use the default cursor
    if (_currentInteractionMode == InteractionMode.drawingTool) {
      return SystemMouseCursors.click;
    }

    // Check if we're over a drawing (clickable element)
    if (widget.interactiveLayerBehaviour.hitTestDrawings(localPosition)) {
      return SystemMouseCursors.grab;
    }

    if (localPosition.dx > (xAxis.graphAreaWidth ?? 0)) {
      return SystemMouseCursors.resizeUpDown;
    }

    if (_currentInteractionMode == InteractionMode.crosshair ||
        (widget.crosshairVariant != CrosshairVariant.smallScreen)) {
      return SystemMouseCursors.precise; // Use precise cursor for crosshair
    }

    // Default cursor
    return MouseCursor.defer;
  }

  void _handleExit(PointerExitEvent event) {
    // Only handle exit events if we're not in drawing tool mode
    if (_currentInteractionMode != InteractionMode.drawingTool) {
      widget.crosshairController.onExit(event);
    }
  }

  // Tap handler
  void _handleTapUp(TapUpDetails details) {
    final bool hitDrawing = widget.interactiveLayerBehaviour.onTap(details);

    _updateInteractionMode(
        hitDrawing ? InteractionMode.drawingTool : InteractionMode.none);
    _interactionNotifier.notify();
  }

  // Long press handlers
  void _handleLongPressStart(LongPressStartDetails details) {
    // Only handle long press if we're not already interacting with a drawing
    if (_currentInteractionMode == InteractionMode.none) {
      widget.crosshairController.onLongPressStart(details);
      _updateInteractionMode(InteractionMode.crosshair);
    }
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    // Only handle updates if we're in crosshair mode
    if (_currentInteractionMode == InteractionMode.crosshair) {
      widget.crosshairController.onLongPressUpdate(details);
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    // Only handle end if we're in crosshair mode
    if (_currentInteractionMode == InteractionMode.crosshair) {
      widget.crosshairController.onLongPressEnd(details);
      _updateInteractionMode(InteractionMode.none);
    }
  }
}
