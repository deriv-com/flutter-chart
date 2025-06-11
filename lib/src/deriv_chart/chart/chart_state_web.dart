part of 'chart.dart';

class _ChartStateWeb extends _ChartState {
  @override
  Widget buildChartsLayout(
    BuildContext context,
    List<Series>? overlaySeries,
    List<Series>? bottomSeries,
  ) {
    final Duration currentTickAnimationDuration =
        widget.currentTickAnimationDuration ?? _defaultDuration;

    final Duration quoteBoundsAnimationDuration =
        widget.quoteBoundsAnimationDuration ?? _defaultDuration;

    final bool isExpanded = expandedIndex != null;

    return Column(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: MainChart(
            drawingTools: widget.drawingTools,
            controller: _controller,
            mainSeries: widget.mainSeries,
            overlaySeries: overlaySeries,
            annotations: widget.annotations,
            markerSeries: widget.markerSeries,
            pipSize: widget.pipSize,
            onCrosshairAppeared: widget.onCrosshairAppeared,
            onQuoteAreaChanged: widget.onQuoteAreaChanged,
            isLive: widget.isLive,
            showLoadingAnimationForHistoricalData: !widget.dataFitEnabled,
            showDataFitButton:
                widget.showDataFitButton ?? widget.dataFitEnabled,
            showScrollToLastTickButton:
                widget.showScrollToLastTickButton ?? true,
            opacity: widget.opacity,
            chartAxisConfig: widget.chartAxisConfig,
            verticalPaddingFraction: widget.verticalPaddingFraction,
            showCrosshair: widget.showCrosshair,
            onCrosshairDisappeared: widget.onCrosshairDisappeared,
            onCrosshairHover: _onCrosshairHover,
            loadingAnimationColor: widget.loadingAnimationColor,
            currentTickAnimationDuration: currentTickAnimationDuration,
            quoteBoundsAnimationDuration: quoteBoundsAnimationDuration,
            showCurrentTickBlinkAnimation:
                widget.showCurrentTickBlinkAnimation ?? true,
            crosshairVariant: widget.crosshairVariant,
            interactiveLayerBehaviour: widget.interactiveLayerBehaviour,
            useDrawingToolsV2: widget.useDrawingToolsV2,
          ),
        ),
        if (bottomSeries?.isNotEmpty ?? false)
          ...bottomSeries!.mapIndexed((int index, Series series) {
            if (isExpanded && expandedIndex != index) {
              return const SizedBox.shrink();
            }

            return Expanded(
              flex: isExpanded ? bottomSeries.length : 1,
              child: BottomChart(
                series: series,
                granularity: widget.granularity,
                pipSize: widget.bottomConfigs[index].pipSize,
                title: widget.bottomConfigs[index].title,
                currentTickAnimationDuration: currentTickAnimationDuration,
                quoteBoundsAnimationDuration: quoteBoundsAnimationDuration,
                bottomChartTitleMargin: widget.bottomChartTitleMargin,
                onRemove: () => _onRemove(widget.bottomConfigs[index]),
                onEdit: () => _onEdit(widget.bottomConfigs[index]),
                onExpandToggle: () {
                  setState(() {
                    expandedIndex = expandedIndex != index ? index : null;
                  });
                },
                onSwap: (int offset) => _onSwap(widget.bottomConfigs[index],
                    widget.bottomConfigs[index + offset]),
                onCrosshairDisappeared: widget.onCrosshairDisappeared,
                onCrosshairHover: (
                  Offset globalPosition,
                  Offset localPosition,
                  EpochToX epochToX,
                  QuoteToY quoteToY,
                  EpochFromX epochFromX,
                  QuoteFromY quoteFromY,
                ) =>
                    widget.onCrosshairHover?.call(
                  globalPosition,
                  localPosition,
                  epochToX,
                  quoteToY,
                  epochFromX,
                  quoteFromY,
                  widget.bottomConfigs[index],
                ),
                isExpanded: isExpanded,
                showCrosshair: widget.showCrosshair,
                showExpandedIcon: bottomSeries.length > 1,
                showMoveUpIcon:
                    !isExpanded && bottomSeries.length > 1 && index != 0,
                showMoveDownIcon: !isExpanded &&
                    bottomSeries.length > 1 &&
                    index != bottomSeries.length - 1,
              ),
            );
          }).toList()
      ],
    );
  }
}
