import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/dimens.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Width of the visible drag handle pill.
const double _handleWidth = 32;

/// Height of the visible drag handle pill.
const double _handleHeight = 16;

/// Width of each of the two bars inside the drag handle.
const double _handleBarWidth = 21.33;

/// Height of the web hover/drag band around the line - narrower than the
/// touch hit area, since a mouse is precise enough that the cursor should
/// only change (and dragging only start) when it's close to the line and
/// handle, not anywhere within the divider's full row height. This only
/// affects the invisible hit-test region, not the visible line/handle.
const double _webDragBandHeight = 24;

/// A horizontal divider placed between two vertically stacked chart panels
/// (e.g. between the main chart and a bottom indicator panel, or between two
/// bottom indicator panels).
///
/// On web, a narrow band around the line is draggable and shows a resize
/// cursor on hover, since mouse pointers are precise. On touch devices, only
/// the drag handle at its horizontal center is draggable, so dragging
/// doesn't start from an accidental tap anywhere along the line. Either way,
/// the line and the handle switch to [ChartTheme.panelDividerActiveColor]
/// only while actively being dragged.
class ResizableChartDivider extends StatefulWidget {
  /// Creates a [ResizableChartDivider].
  const ResizableChartDivider({
    required this.onDragUpdate,
    this.onDragEnd,
    Key? key,
  }) : super(key: key);

  /// Called with the vertical drag delta, in logical pixels, as the user
  /// drags the divider.
  final ValueChanged<double> onDragUpdate;

  /// Called when the drag gesture ends.
  final VoidCallback? onDragEnd;

  @override
  State<ResizableChartDivider> createState() => _ResizableChartDividerState();
}

class _ResizableChartDividerState extends State<ResizableChartDivider> {
  bool _isDragging = false;

  ChartTheme get _theme => context.read<ChartTheme>();

  Widget _dragArea({required Widget child}) => MouseRegion(
        cursor: SystemMouseCursors.resizeRow,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: (_) => setState(() => _isDragging = true),
          onVerticalDragUpdate: (DragUpdateDetails details) =>
              widget.onDragUpdate(details.delta.dy),
          onVerticalDragEnd: (_) {
            setState(() => _isDragging = false);
            widget.onDragEnd?.call();
          },
          onVerticalDragCancel: () => setState(() => _isDragging = false),
          child: child,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final Color color = _isDragging
        ? _theme.panelDividerActiveColor
        : _theme.crosshairLineDesktopColor;

    final Widget handle = Container(
      width: _handleWidth,
      height: _handleHeight,
      decoration: BoxDecoration(
        color: _theme.backgroundColor,
        borderRadius: BorderRadius.circular(Dimens.borderRadius04),
        border: Border.all(color: color),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(width: _handleBarWidth, height: 1, color: color),
          const SizedBox(height: 4),
          Container(width: _handleBarWidth, height: 1, color: color),
        ],
      ),
    );

    // The visible line and handle, at their natural size, unaffected by
    // however small or large the interactive hit area below is.
    final Widget visuals = Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(height: 1, color: color),
        Center(child: handle),
      ],
    );

    final Widget hitArea = kIsWeb
        ? Center(
            child: SizedBox(
              height: _webDragBandHeight,
              width: double.infinity,
              child: _dragArea(child: const SizedBox.expand()),
            ),
          )
        : Center(
            child: SizedBox(
              width: 44,
              height: Dimens.chartPanelDividerHitHeight,
              child: _dragArea(child: const SizedBox.expand()),
            ),
          );

    return SizedBox(
      height: Dimens.chartPanelDividerHitHeight,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[visuals, hitArea],
      ),
    );
  }
}
