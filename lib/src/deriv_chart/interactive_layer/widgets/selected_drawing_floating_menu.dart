import 'dart:ui';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/interactable_drawing.dart';
import 'package:deriv_chart/src/theme/design_tokens/core_design_tokens.dart';
import 'package:deriv_chart/src/widgets/glassy_blur_effect_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../interactive_layer_behaviours/interactive_layer_behaviour.dart';
import '../interactive_layer_controller.dart';

// TODO(NA): get the colors and dimensions from the [ChartTheme].
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get the screen size as a fallback
    final screenSize = MediaQuery.of(context).size;

    return Positioned(
      left: _controller.floatingMenuPosition.dx,
      top: _controller.floatingMenuPosition.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanEnd: (_) => _cursor = SystemMouseCursors.grab,
        onPanUpdate: (details) {
          _cursor = SystemMouseCursors.grabbing;

          // Calculate new position
          final newPosition = _controller.floatingMenuPosition + details.delta;

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

          _controller.floatingMenuPosition = Offset(constrainedX, constrainedY);
          setState(() {});
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
    );
  }

  Widget _buildDragIcon() => MouseRegion(
        cursor: _cursor,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            Icons.drag_indicator,
            size: 18,
            color: CoreDesignTokens.coreColorSolidSlate50.withOpacity(0.4),
          ),
        ),
      );

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
