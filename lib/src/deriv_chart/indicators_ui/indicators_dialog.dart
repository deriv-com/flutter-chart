import 'package:deriv_chart/src/deriv_chart/indicators_ui/donchian_channel/donchian_channel_indicator_item.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/rsi/rsi_indicator_item.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/widgets/animated_popup.dart';
import 'package:flutter/material.dart';

import 'bollinger_bands/bollinger_bands_indicator_item.dart';
import 'callbacks.dart';
import 'indicator_item.dart';
import 'ma_env_indicator/ma_env_indicator_item.dart';
import 'ma_indicator/ma_indicator_item.dart';

/// Indicators dialog to add them to the chart.
class IndicatorsDialog extends StatefulWidget {
  /// Initializes
  const IndicatorsDialog({
    Key key,
    this.onAddIndicator,
    this.ticks,
  }) : super(key: key);

  /// List of chart ticks
  final List<Tick> ticks;

  /// Callback which will be called when an specific indicator was added.
  final OnAddIndicator onAddIndicator;

  @override
  _IndicatorsDialogState createState() => _IndicatorsDialogState();
}

class _IndicatorsDialogState extends State<IndicatorsDialog> {
  final List<IndicatorItem> indicatorItems = <IndicatorItem>[];

  @override
  void initState() {
    super.initState();

    indicatorItems
      ..add(MAIndicatorItem(
        ticks: widget.ticks,
        onAddIndicator: widget.onAddIndicator,
      ))
      ..add(BollingerBandsIndicatorItem(
        ticks: widget.ticks,
        onAddIndicator: widget.onAddIndicator,
      ))
      ..add(DonchianChannelIndicatorItem(
        ticks: widget.ticks,
        onAddIndicator: widget.onAddIndicator,
      ))
      ..add(MAEnvIndicatorItem(
        ticks: widget.ticks,
        onAddIndicator: widget.onAddIndicator,
      ))
      ..add(RSIIndicatorItem(
        ticks: widget.ticks,
        onAddIndicator: widget.onAddIndicator,
      ));
  }

  @override
  Widget build(BuildContext context) => AnimatedPopupDialog(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: indicatorItems.length,
          itemBuilder: (BuildContext context, int index) =>
              indicatorItems[index],
        ),
      );
}
