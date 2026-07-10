part of 'chart.dart';

class _ChartStateWeb extends _ChartState {
  String _bottomPanelKey(int index) =>
      _panelKeyFor(widget.bottomConfigs[index], index);

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
    final int totalBottomCount = widget.bottomConfigs.length;

    // Fractions are tracked for every bottom panel regardless of whether
    // it's currently visible, so expanding/collapsing one to fullscreen
    // doesn't discard the custom sizes of the others.
    final List<String> allPanelKeys = <String>[
      PanelSizeRepository.mainPanelKey,
      for (int i = 0; i < totalBottomCount; i++) _bottomPanelKey(i),
    ];

    _syncPanelFractions(
      allPanelKeys,
      (String key) => key == PanelSizeRepository.mainPanelKey
          ? (totalBottomCount > 0 ? 3 / (3 + totalBottomCount) : 1.0)
          : 1 / (3 + totalBottomCount),
    );

    final double mainFraction =
        _panelFractions[PanelSizeRepository.mainPanelKey] ?? 1.0;

    // While a single bottom panel is expanded to fullscreen, it takes up
    // the entire bottom region (instead of its own stored fraction), and
    // the main chart keeps the fraction it had before expanding.
    double fractionFor(String key) =>
        isExpanded ? (1 - mainFraction) : (_panelFractions[key] ?? 0);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int dividerCount = isExpanded ? 0 : totalBottomCount;
        final double usableHeight =
            _usableHeightFor(constraints.maxHeight, dividerCount);

        Widget panelSizedBox(double fraction, Widget child) => SizedBox(
              height: fraction * usableHeight,
              child: child,
            );

        final List<Widget> children = <Widget>[
          panelSizedBox(
            mainFraction,
            MainChart(
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
        ];

        for (int index = 0; index < totalBottomCount; index++) {
          if (isExpanded && expandedIndex != index) {
            continue;
          }

          final String key = _bottomPanelKey(index);

          // Dragging is only meaningful between panels that are both
          // visible with independently-tracked fractions; disable it while
          // a single panel is expanded to fullscreen.
          if (!isExpanded) {
            final int dividerIndex = index;
            children.add(
              ResizableChartDivider(
                onDragUpdate: (double deltaPixels) => _resizeCascadingPanels(
                  allPanelKeys,
                  dividerIndex,
                  deltaPixels / usableHeight,
                ),
                onDragEnd: _persistPanelFractions,
              ),
            );
          }

          children.add(
            panelSizedBox(
              fractionFor(key),
              BottomChart(
                series: bottomSeries![index],
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
                showExpandedIcon: totalBottomCount > 1,
                showMoveUpIcon:
                    !isExpanded && totalBottomCount > 1 && index != 0,
                showMoveDownIcon: !isExpanded &&
                    totalBottomCount > 1 &&
                    index != totalBottomCount - 1,
              ),
            ),
          );
        }

        return Column(children: children);
      },
    );
  }
}
