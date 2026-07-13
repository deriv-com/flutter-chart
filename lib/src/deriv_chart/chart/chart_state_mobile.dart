part of 'chart.dart';

class _ChartStateMobile extends _ChartState {
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

    final Repository<IndicatorConfig>? repository = widget.indicatorsRepo;

    // Bottom (non-overlay) indicators, in repo order, keeping their true
    // index within `repository.items` (needed for hidden-status lookups).
    final List<int> bottomRepoIndices = <int>[
      if (repository != null)
        for (int i = 0; i < repository.items.length; i++)
          if (!repository.items[i].isOverlay) i
    ];

    final List<int> visibleBottomRepoIndices = bottomRepoIndices
        .where((int i) => !repository!.getHiddenStatus(i))
        .toList();

    final List<String> visibleIndicatorKeys = visibleBottomRepoIndices
        .map((int i) => _panelKeyFor(repository!.items[i]))
        .toList();

    // A single flat, ordered chain covering the main chart and every
    // *visible* bottom indicator panel. Keeping this as one chain (rather
    // than resizing the bottom section as a whole and then splitting it
    // among indicators independently) is what lets a resize cascade past
    // an indicator already at its minimum height into the next one that
    // still has room, no matter which divider is being dragged.
    final List<String> orderedKeys = <String>[
      PanelSizeRepository.mainPanelKey,
      ...visibleIndicatorKeys,
    ];

    final double bottomSectionDefaultFraction =
        _getBottomIndicatorsSectionHeightFraction(bottomRepoIndices.length);

    _syncPanelFractions(
      orderedKeys,
      (String key) => key == PanelSizeRepository.mainPanelKey
          ? 1 - bottomSectionDefaultFraction
          : bottomSectionDefaultFraction /
              (visibleIndicatorKeys.isEmpty ? 1 : visibleIndicatorKeys.length),
    );

    List<Widget> getBottomIndicatorsList(
      BuildContext context,
      double usableHeight,
    ) {
      final List<Widget> children = <Widget>[];
      int visiblePosition = 0;

      for (final int repoIndex in bottomRepoIndices) {
        final IndicatorConfig config = repository!.items[repoIndex];
        final bool isHidden = repository.getHiddenStatus(repoIndex);

        final Series series = config.getSeries(
          IndicatorInput(
            widget.mainSeries.input,
            widget.granularity,
          ),
        );

        // TODO(Ramin): Use the key (type + number) once it's implemented.
        final int indexInBottomConfigs =
            referenceIndexOf(widget.bottomConfigs, config);

        final Widget bottomChart = BottomChartMobile(
          series: series,
          isHidden: isHidden,
          granularity: widget.granularity,
          pipSize: config.pipSize,
          title:
              '${config.shortTitle} ${config.number > 0 ? config.number : ''}'
              ' (${config.configSummary})',
          currentTickAnimationDuration: currentTickAnimationDuration,
          quoteBoundsAnimationDuration: quoteBoundsAnimationDuration,
          bottomChartTitleMargin: const EdgeInsets.only(left: Dimens.margin04),
          onHideUnhideToggle: () =>
              _onIndicatorHideToggleTapped(repository, repoIndex),
          onSwap: (int offset) => _onSwap(
              config, widget.bottomConfigs[indexInBottomConfigs + offset]),
          showMoveUpIcon: bottomSeries!.length > 1 && indexInBottomConfigs != 0,
          showMoveDownIcon: bottomSeries.length > 1 &&
              indexInBottomConfigs != bottomSeries.length - 1,
          showFrame: context.read<ChartConfig>().chartAxisConfig.showFrame,
        );

        if (isHidden) {
          children.add(bottomChart);
          continue;
        }

        final String key = _panelKeyFor(config);

        // The divider directly above this panel sits between
        // `orderedKeys[visiblePosition]` (main, or the previous indicator)
        // and `orderedKeys[visiblePosition + 1]` (this indicator) - i.e.
        // its divider index within the shared chain is `visiblePosition`.
        final int dividerIndex = visiblePosition;
        children
          ..add(
            ResizableChartDivider(
              onDragUpdate: (double deltaPixels) => _resizeCascadingPanels(
                orderedKeys,
                dividerIndex,
                deltaPixels / usableHeight,
              ),
              onDragEnd: _persistPanelFractions,
            ),
          )
          ..add(
            SizedBox(
              height: (_panelFractions[key] ?? 0) * usableHeight,
              child: bottomChart,
            ),
          );

        visiblePosition++;
      }

      return children;
    }

    final List<Series> overlaySeries = <Series>[];

    if (widget.indicatorsRepo != null) {
      for (int i = 0; i < widget.indicatorsRepo!.items.length; i++) {
        final IndicatorConfig config = widget.indicatorsRepo!.items[i];
        if (widget.indicatorsRepo!.getHiddenStatus(i) || !config.isOverlay) {
          continue;
        }

        overlaySeries.add(config.getSeries(
          IndicatorInput(
            widget.mainSeries.input,
            widget.granularity,
          ),
        ));
      }
    }

    return LayoutBuilder(builder: (
      BuildContext context,
      BoxConstraints constraints,
    ) {
      final double availableHeight = constraints.maxHeight;
      final double mainFraction =
          _panelFractions[PanelSizeRepository.mainPanelKey] ?? 1.0;

      // Each divider takes up real space in the bottom section's Column
      // alongside the indicator panels, so it must be subtracted from the
      // space panel fractions are applied to - otherwise the panels plus
      // dividers overflow the section's fixed-height SizedBox below.
      final double reservedForDividers =
          visibleIndicatorKeys.length * Dimens.chartPanelDividerHitHeight;
      final double usableHeight =
          _usableHeightFor(availableHeight, visibleIndicatorKeys.length);
      final double bottomSectionHeight =
          (1 - mainFraction) * usableHeight + reservedForDividers;

      final List<Widget> bottomIndicatorsList =
          getBottomIndicatorsList(context, usableHeight);

      return Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                if (context.read<ChartConfig>().chartAxisConfig.showFrame)
                  _buildMainChartFrame(context),
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
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimens.margin08,
                      horizontal: Dimens.margin04,
                    ),
                    child: _buildOverlayIndicatorsLabels(),
                  ),
                ),
              ],
            ),
          ),
          if (_isAllBottomIndicatorsHidden)
            ...bottomIndicatorsList
          else
            SizedBox(
              height: bottomSectionHeight,
              child: Column(children: bottomIndicatorsList),
            ),
        ],
      );
    });
  }

  Widget _buildMainChartFrame(BuildContext context) => Container(
        constraints: const BoxConstraints.expand(),
        child: MobileChartFrameDividers(
          color: const Color(0xFF242828),
          rightPadding: (context.read<XAxisModel>().rightPadding ?? 0) +
              _chartTheme.gridStyle.labelHorizontalPadding,
        ),
      );

  int referenceIndexOf(List<dynamic> list, dynamic element) {
    for (int i = 0; i < list.length; i++) {
      if (identical(list[i], element)) {
        return i;
      }
    }
    return -1;
  }

  void _onIndicatorHideToggleTapped(
    Repository<IndicatorConfig>? repository,
    int index,
  ) {
    repository?.updateHiddenStatus(
      index: index,
      hidden: !repository.getHiddenStatus(index),
    );
  }

  double _getBottomIndicatorsSectionHeightFraction(int bottomIndicatorsCount) =>
      1 - (0.65 - 0.125 * (bottomIndicatorsCount - 1));

  bool get _isAllBottomIndicatorsHidden {
    bool isAllHidden = true;
    for (int i = 0; i < widget.indicatorsRepo!.items.length; i++) {
      if (!widget.indicatorsRepo!.items[i].isOverlay &&
          !(widget.indicatorsRepo?.getHiddenStatus(i) ?? false)) {
        isAllHidden = false;
      }
    }
    return isAllHidden;
  }

  Widget _buildOverlayIndicatorsLabels() {
    final List<Widget> overlayIndicatorsLabels = <Widget>[];
    if (widget.indicatorsRepo != null) {
      for (int i = 0; i < widget.indicatorsRepo!.items.length; i++) {
        final IndicatorConfig config = widget.indicatorsRepo!.items[i];
        if (!config.isOverlay) {
          continue;
        }

        overlayIndicatorsLabels.add(
          Padding(
            padding: const EdgeInsets.only(bottom: Dimens.margin04),
            child: IndicatorLabelMobile(
              title:
                  '${config.shortTitle} ${config.number > 0 ? config.number : ''}'
                  ' (${config.configSummary})',
              showMoveUpIcon: false,
              showMoveDownIcon: false,
              isHidden: widget.indicatorsRepo?.getHiddenStatus(i) ?? false,
              onHideUnhideToggle: () {
                _onIndicatorHideToggleTapped(widget.indicatorsRepo, i);
              },
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: overlayIndicatorsLabels,
    );
  }
}
