import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_repository.dart';
import 'package:deriv_chart/src/widgets/animated_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Indicators dialog with selected indicators.
class IndicatorsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final IndicatorsRepository repo = context.watch<IndicatorsRepository>();

    return AnimatedPopupDialog(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: repo.indicators.length,
        itemBuilder: (BuildContext context, int index) =>
            repo.indicators[index].getItem(
          (IndicatorConfig updatedConfig) =>
              repo.updateAt(index, updatedConfig),
          () => repo.removeAt(index),
        ),
      ),
    );
  }
}
