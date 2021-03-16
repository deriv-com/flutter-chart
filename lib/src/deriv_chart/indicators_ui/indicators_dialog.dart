import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_repository.dart';
import 'package:deriv_chart/src/widgets/animated_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './ma_indicator/ma_indicator_config.dart';

/// Indicators dialog with selected indicators.
class IndicatorsDialog extends StatefulWidget {
  @override
  _IndicatorsDialogState createState() => _IndicatorsDialogState();
}

class _IndicatorsDialogState extends State<IndicatorsDialog> {
  IndicatorConfig _selectedIndicator;

  @override
  Widget build(BuildContext context) {
    final IndicatorsRepository repo = context.watch<IndicatorsRepository>();

    return AnimatedPopupDialog(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<IndicatorConfig>(
                value: _selectedIndicator,
                hint: const Text('Select indicator'),
                items: [
                  const DropdownMenuItem<IndicatorConfig>(
                    child: Text('Moving average'),
                    value: MAIndicatorConfig(),
                  ),
                ],
                onChanged: (IndicatorConfig config) {
                  setState(() {
                    _selectedIndicator = config;
                  });
                },
              ),
              const SizedBox(width: 16),
              RaisedButton(
                child: const Text('Add'),
                onPressed: () async {
                  await repo.add(const MAIndicatorConfig());
                  setState(() {});
                },
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: repo.indicators.length,
              itemBuilder: (BuildContext context, int index) =>
                  repo.indicators[index].getItem(
                (IndicatorConfig updatedConfig) =>
                    repo.updateAt(index, updatedConfig),
                () async {
                  await repo.removeAt(index);
                  setState(() {});
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
