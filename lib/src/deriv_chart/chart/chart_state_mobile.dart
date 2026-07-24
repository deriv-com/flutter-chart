part of 'chart.dart';

class _ChartStateMobile extends _ChartState {
  /// Panel keys (see [_panelKeyFor]) of indicator labels currently expanded to
  /// show their action buttons. Keyed by panel key - rather than held as local
  /// widget state - so an indicator's expanded/collapsed state follows it
  /// across reorders, hides and the frequent live-tick rebuilds, and never
  /// gets attached to the wrong indicator. Labels default to collapsed (absent
  /// from this set).
  final Set<String> _expandedLabelKeys = <String>{};

  bool _isLabelExpanded(IndicatorConfig config) =>
      _expandedLabelKeys.contains(_panelKeyFor(config));

  void _toggleLabelExpanded(IndicatorConfig config) {
    final String key = _panelKeyFor(config);
    setState(() {
      if (!_expandedLabelKeys.remove(key)) {
        _expandedLabelKeys.add(key);
      }
    });
  }

  /// The indicator-label icons supplied by the host app, or Material defaults.
  IndicatorLabelIcons get _labelIcons =>
      widget.indicatorLabelIcons ?? const IndicatorLabelIcons();

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

    // Every bottom indicator's key, visible or hidden, in repo order.
    // Syncing/seeding fractions against this full set (rather than just the
    // visible ones) is what makes a hidden indicator's fraction survive
    // hiding it - since [syncPanelFractions] only drops/renormalizes keys
    // that are absent from the list it's given, a hidden indicator's key
    // staying in this list keeps its stored fraction untouched until it's
    // actually removed from the repo, so unhiding it restores the exact
    // size it had before.
    final List<String> allBottomIndicatorKeys = bottomRepoIndices
        .map((int i) => _panelKeyFor(repository!.items[i]))
        .toList();

    // A single flat, ordered chain covering the main chart and every bottom
    // indicator panel, visible or hidden. Keeping every panel - including
    // hidden ones - in this chain (rather than resizing the bottom section
    // as a whole and then splitting it among indicators independently) is
    // what lets a resize cascade past a panel already at its minimum height
    // into the next one that still has room, no matter which divider is
    // being dragged, and lets a hidden panel's divider still resize it even
    // though its content is collapsed.
    final List<String> orderedKeys = <String>[
      PanelSizeRepository.mainPanelKey,
      ...allBottomIndicatorKeys,
    ];

    final double bottomSectionDefaultFraction =
        _getBottomIndicatorsSectionHeightFraction(bottomRepoIndices.length);

    _syncPanelFractions(
      <String>[PanelSizeRepository.mainPanelKey, ...allBottomIndicatorKeys],
      (String key) => key == PanelSizeRepository.mainPanelKey
          ? 1 - bottomSectionDefaultFraction
          : bottomSectionDefaultFraction /
              (allBottomIndicatorKeys.isEmpty
                  ? 1
                  : allBottomIndicatorKeys.length),
    );

    List<Widget> getBottomIndicatorsList(
      BuildContext context,
      double usableHeight,
    ) {
      final List<Widget> children = <Widget>[];
      int position = 0;

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
          isExpanded: _isLabelExpanded(config),
          granularity: widget.granularity,
          pipSize: config.pipSize,
          title:
              '${config.shortTitle} ${config.number > 0 ? config.number : ''}'
              '${config.configSummary.isEmpty ? '' : ' (${config.configSummary})'}',
          currentTickAnimationDuration: currentTickAnimationDuration,
          quoteBoundsAnimationDuration: quoteBoundsAnimationDuration,
          bottomChartTitleMargin: const EdgeInsets.only(left: Dimens.margin04),
          icons: _labelIcons,
          onExpandToggle: () => _toggleLabelExpanded(config),
          onHideUnhideToggle: () =>
              _onIndicatorHideToggleTapped(repository, repoIndex),
          onEdit: () => _onEdit(config),
          onRemove: () => _onRemove(config),
          onSwap: (int offset) => _onSwap(
              config, widget.bottomConfigs[indexInBottomConfigs + offset]),
          showMoveUpIcon: bottomSeries!.length > 1 && indexInBottomConfigs != 0,
          showMoveDownIcon: bottomSeries.length > 1 &&
              indexInBottomConfigs != bottomSeries.length - 1,
          showFrame: context.read<ChartConfig>().chartAxisConfig.showFrame,
        );

        final String key = _panelKeyFor(config);

        // Every panel - hidden or visible - keeps its own divider and
        // reserves the exact height its fraction represents, so hiding one
        // only collapses its *content* down to the title bar; its divider
        // stays in place and its space keeps being resizable (and cascades
        // into neighboring panels the same way a visible one would), so
        // nothing shifts or resizes as a side effect of hiding/unhiding it.
        //
        // The divider directly above this panel sits between
        // `orderedKeys[position]` (main, or the previous indicator) and
        // `orderedKeys[position + 1]` (this indicator) - i.e. its divider
        // index within the shared chain is `position`.
        final int dividerIndex = position;

        // Every panel's title bar (name, hide/unhide, up/down icons) is made
        // up of fixed-size text and icons rather than freely-scalable chart
        // content, so its fraction - whether it's the *stored* one kept as-
        // is while hidden, or one dragged down toward
        // [Dimens.minChartPanelHeightFraction] while visible - can still
        // work out to less pixel height than that title bar needs. Flooring
        // only the rendered height (not the stored fraction) keeps it from
        // being clipped without affecting the size a hidden panel is
        // restored to on unhide.
        final double panelHeight = (_panelFractions[key] ?? 0) * usableHeight;
        final double renderedHeight =
            math.max(panelHeight, Dimens.indicatorTitleBarMinHeight);

        children
          ..add(
            ResizableChartDivider(
              onDragUpdate: (double deltaPixels) => _resizeCascadingPanels(
                orderedKeys,
                dividerIndex,
                deltaPixels / usableHeight,
                usableHeight: usableHeight,
              ),
              onDragEnd: _persistPanelFractions,
            ),
          )
          ..add(
            SizedBox(
              height: renderedHeight,
              child: bottomChart,
            ),
          );

        position++;
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

      // Each divider takes up real space in the bottom section's Column
      // alongside the indicator panels, so it must be subtracted from the
      // space panel fractions are applied to. Every bottom indicator now
      // keeps its divider whether hidden or visible, so all of them count.
      final double usableHeight =
          _usableHeightFor(availableHeight, bottomRepoIndices.length);

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
          ...bottomIndicatorsList,
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
                  '${config.configSummary.isEmpty ? '' : ' (${config.configSummary})'}',
              isExpanded: _isLabelExpanded(config),
              showMoveUpIcon: false,
              showMoveDownIcon: false,
              isHidden: widget.indicatorsRepo?.getHiddenStatus(i) ?? false,
              icons: _labelIcons,
              onExpandToggle: () => _toggleLabelExpanded(config),
              onHideUnhideToggle: () {
                _onIndicatorHideToggleTapped(widget.indicatorsRepo, i);
              },
              onEdit: () => _onEdit(config),
              onRemove: () => _onRemove(config),
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
