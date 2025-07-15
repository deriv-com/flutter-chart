import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/widgets/glassy_blur_effect_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A builder function type for creating a drop-down picker widget to get the
/// value for type [T].
typedef DropdownBuilder<T> = Widget Function(
  T selectedValue,
  ValueChanged<T> onValueSelected,
);

/// Shows a dropdown at the specified position.
///
/// This is a stateless function that shows the dropdown and returns the selected value
/// through the onValueSelected callback.
///
/// [originWidgetPosition] is the position of the original button that triggered
/// the dropdown. Provide the top-left corner of the widget.
///
/// [originWidgetSize] is the size of the button that triggered the dropdown.
void showDropdown<T>({
  required BuildContext context,
  required Offset originWidgetPosition,
  required Size originWidgetSize,
  required T initialValue,
  required ValueChanged<T> onValueSelected,
  required DropdownBuilder<T> dropdownBuilder,
  double gapWithOriginWidget = 8,
  double paddingWithBorder = 8,
}) {
  // Get screen size to determine dropdown direction
  final screenSize = MediaQuery.of(context).size;
  final isBottomHalf = originWidgetPosition.dy > screenSize.height / 2;

  // Create a key for the dropdown
  final GlobalKey dropdownKey = GlobalKey();

  // Track if we've measured the dropdown size
  bool hasMeasuredSize = false;

  // Initial position values (will be updated after measurement)
  double topPosition = originWidgetPosition.dy + 4; // Default to below
  double leftPosition = originWidgetPosition.dx; // Default to centered on x

  // Create overlay entry
  late final OverlayEntry overlayEntry;

  // Define the overlay content
  overlayEntry = OverlayEntry(
    builder: (_) => Provider.value(
      value: context.watch<ChartTheme>(),
      child: StatefulBuilder(
        builder: (context, setState) {
          // After the first build, measure the size of the dropdown
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!hasMeasuredSize) {
              final RenderBox? renderBox =
                  dropdownKey.currentContext?.findRenderObject() as RenderBox?;

              if (renderBox != null) {
                // Get the actual size of the dropdown
                final Size size = renderBox.size;
                final double originWidgetHalfHeight =
                    originWidgetSize.height / 2;

                // Calculate the correct position based on measured dimensions
                final double newTopPosition = isBottomHalf
                    ? originWidgetPosition.dy -
                        size.height -
                        originWidgetHalfHeight -
                        gapWithOriginWidget
                    : originWidgetPosition.dy +
                        originWidgetHalfHeight +
                        gapWithOriginWidget;

                // Keep the original left position based on the origin widget
                double newLeftPosition = originWidgetPosition.dx -
                    (originWidgetSize.width / 2); // Center the dropdown

                // Check if the dropdown would go off screen edges
                final double rightEdge = newLeftPosition + size.width;
                final double leftEdge = newLeftPosition;

                if (rightEdge > screenSize.width) {
                  // Adjust if dropdown goes off the right edge of the screen
                  newLeftPosition =
                      screenSize.width - size.width - paddingWithBorder;
                }

                if (leftEdge < 0) {
                  // Adjust if dropdown goes off the left edge of the screen
                  newLeftPosition = paddingWithBorder;
                }

                setState(() {
                  topPosition = newTopPosition;
                  leftPosition = newLeftPosition;
                  hasMeasuredSize = true;
                });
              }
            }
          });

          return Stack(
            children: [
              // Invisible full-screen touch handler to close dropdown when
              // tapping outside
              _buildOutsideArea(overlayEntry),

              Positioned(
                left: leftPosition,
                top: topPosition,
                child: _buildDropdownContent<T>(
                  context,
                  hasMeasuredSize,
                  dropdownKey,
                  initialValue,
                  onValueSelected,
                  dropdownBuilder,
                  overlayEntry,
                ),
              ),
            ],
          );
        },
      ),
    ),
  );

  // Insert the overlay
  Overlay.of(context).insert(overlayEntry);
}

Widget _buildDropdownContent<T>(
  BuildContext context,
  bool hasMeasuredSize,
  GlobalKey<State<StatefulWidget>> dropdownKey,
  T initialValue,
  ValueChanged<T> onValueSelected,
  DropdownBuilder<T> builder,
  OverlayEntry overlayEntry,
) =>
    AnimatedOpacity(
      opacity: hasMeasuredSize ? 1 : 0,
      duration: const Duration(milliseconds: 240),
      child: Material(
        key: dropdownKey,
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
        child: GlassyBlurEffectWidget(
          child: builder(initialValue, (T selectedValue) {
            onValueSelected(selectedValue);
            overlayEntry.remove();
          }),
        ),
      ),
    );

Widget _buildOutsideArea(OverlayEntry overlayEntry) => Positioned.fill(
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => overlayEntry.remove(),
      ),
    );
