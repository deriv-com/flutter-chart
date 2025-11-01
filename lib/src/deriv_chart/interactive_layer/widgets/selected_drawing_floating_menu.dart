import 'package:deriv_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/interactable_drawing.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/widgets/glassy_blur_effect_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../interactive_layer_behaviours/interactive_layer_behaviour.dart';
import '../interactive_layer_controller.dart';

/// A floating menu that appears when a drawing is selected.
class SelectedDrawingFloatingMenu extends StatefulWidget {
  /// Creates a floating menu for the selected drawing.
  const SelectedDrawingFloatingMenu({
    required this.drawing,
    required this.interactiveLayerBehaviour,
    required this.onUpdateDrawing,
    required this.onRemoveDrawing,
    super.key,
  });

  /// The drawing that is currently selected.
  final InteractableDrawing<DrawingToolConfig> drawing;

  /// The controller for the interactive layer.
  final InteractiveLayerBehaviour interactiveLayerBehaviour;

  /// Callback to update the drawing.
  final UpdateDrawingTool onUpdateDrawing;

  /// Callback to remove the drawing.
  final UpdateDrawingTool onRemoveDrawing;

  @override
  State<SelectedDrawingFloatingMenu> createState() =>
      _SelectedDrawingFloatingMenuState();
}

class _SelectedDrawingFloatingMenuState
    extends State<SelectedDrawingFloatingMenu> {
  // Store the menu size
  Size _menuSize = Size.zero;

  // Local state to persist the dragged position across rebuilds
  Offset? _draggedPosition;

  MouseCursor _cursor = SystemMouseCursors.grab;

  late final InteractiveLayerController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = widget.interactiveLayerBehaviour.controller;
    _scaleAnimation = CurvedAnimation(
      parent: Tween<double>(begin: 0.8, end: 1)
          .animate(widget.interactiveLayerBehaviour.stateChangeController),
      curve: Curves.easeOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: widget.interactiveLayerBehaviour.stateChangeController,
      curve: Curves.easeOut,
    );

    // Initialize dragged position from controller
    _draggedPosition = _controller.floatingMenuPosition;

    // Schedule a post-frame callback to get the menu size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMenuSize();
    });
  }

  void _updateMenuSize() {
    // Get the size of this menu widget
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _menuSize = renderBox.size;
        // Update the controller with the menu size
        _controller.floatingMenuSize = _menuSize;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get the screen size as a fallback
    final screenSize = MediaQuery.of(context).size;

    // Use local dragged position if available, otherwise use controller's position
    final effectivePosition =
        _draggedPosition ?? _controller.floatingMenuPosition;

    return Positioned(
      left: effectivePosition.dx,
      top: effectivePosition.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (details) {
          // Hide the crosshair when starting to drag the toolbar
          widget.interactiveLayerBehaviour.interactiveLayer.hideCrosshair();
        },
        onPanEnd: (_) => _cursor = SystemMouseCursors.grab,
        onPanUpdate: (details) {
          _cursor = SystemMouseCursors.grabbing;

          // Calculate new position based on current effective position
          final currentPosition =
              _draggedPosition ?? _controller.floatingMenuPosition;
          final newPosition = currentPosition + details.delta;

          // Update menu size if not already set
          if (_menuSize == Size.zero) {
            _updateMenuSize();
          }

          // Find the nearest ancestor that provides size constraints
          final RenderBox? ancestorBox =
              context.findRenderObject()?.parent as RenderBox?;
          final Size parentSize = ancestorBox?.size ?? screenSize;

          // Constrain the position to keep the menu within the parent boundaries
          final constrainedX =
              newPosition.dx.clamp(0.0, parentSize.width - _menuSize.width);
          final constrainedY =
              newPosition.dy.clamp(0.0, parentSize.height - _menuSize.height);

          final constrainedPosition = Offset(constrainedX, constrainedY);

          // Store in local state to persist across rebuilds
          setState(() {
            _draggedPosition = constrainedPosition;
          });

          // Also update controller for other components that might need it
          _controller.floatingMenuPosition = constrainedPosition;
        },
        child: AnimatedBuilder(
          animation: widget.interactiveLayerBehaviour.stateChangeController,
          builder: (_, child) => FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
          child: GlassyBlurEffectWidget(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4, right: 8),
              child: Row(
                children: <Widget>[
                  _buildDragIcon(),
                  _buildDrawingMenuOptions(),
                  const SizedBox(width: 4),
                  _buildRemoveButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDragIcon() {
    final ChartTheme theme = context.watch<ChartTheme>();

    return MouseRegion(
      cursor: _cursor,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(
          Icons.drag_indicator,
          size: 18,
          color: theme.floatingMenuDragIconColor,
        ),
      ),
    );
  }

  Widget _buildDrawingMenuOptions() => widget.drawing.getToolBarMenu(
        onUpdate: widget.onUpdateDrawing,
      );

  Widget _buildRemoveButton(BuildContext context) => SizedBox(
        width: 32,
        height: 32,
        child: TextButton(
          child: const Icon(Icons.delete_outline, size: 18),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onPressed: () => widget.onRemoveDrawing(widget.drawing.config),
        ),
      );
}
