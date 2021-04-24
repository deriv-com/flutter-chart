// @dart=2.9

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/theme/chart_default_dark_theme.dart';
import 'package:deriv_chart/src/theme/chart_default_light_theme.dart';
import 'package:deriv_chart/src/widgets/custom_draggable_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Bottom sheet container used in chart library.
class ChartBottomSheet extends StatefulWidget {
  /// Creates a bottom sheet container for [child].
  const ChartBottomSheet({
    @required this.child,
    this.theme,
    Key key,
  }) : super(key: key);

  /// Body of bottom sheet container.
  final Widget child;

  /// The theme of the chart which the bottom sheet is being placed inside.
  final ChartTheme theme;

  @override
  _ChartBottomSheetState createState() => _ChartBottomSheetState();
}

class _ChartBottomSheetState extends State<ChartBottomSheet> {
  ChartTheme _theme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _theme = widget.theme ?? Theme.of(context).brightness == Brightness.dark
        ? ChartDefaultDarkTheme()
        : ChartDefaultLightTheme();
  }

  @override
  Widget build(BuildContext context) => CustomDraggableSheet(
        child: Provider<ChartTheme>.value(
          value: _theme,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(_theme.borderRadius24Chart),
              topRight: Radius.circular(_theme.borderRadius24Chart),
            ),
            child: Material(
              elevation: 8,
              color: _theme.base07Color,
              child: Column(
                children: <Widget>[
                  _buildTopHandle(),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildTopHandle() => Container(
        padding: EdgeInsets.symmetric(vertical: _theme.margin08Chart),
        width: double.infinity,
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _theme.base05Color,
              borderRadius: BorderRadius.circular(_theme.borderRadius04Chart),
            ),
          ),
        ),
      );
}
