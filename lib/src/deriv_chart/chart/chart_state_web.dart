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

    final Repository<IndicatorConfig>? repository = widget.indicatorsRepo;

    // The repository is the source of truth whenever the host supplies one -
    // it is what carries hidden status. `Chart` also accepts plain
    // `overlayConfigs`/`bottomConfigs` with no repository at all, and those
    // hosts still get their indicators drawn; they simply have nowhere to
    // record a hidden state, so nothing is hidden.
    final List<IndicatorConfig> bottomPanelConfigs = repository != null
        ? <IndicatorConfig>[
            for (final IndicatorConfig config in repository.items)
              if (!config.isOverlay) config
          ]
        : widget.bottomConfigs;

    // Each panel's true index within `repository.items`, for hidden-status
    // lookups. Empty when there is no repository.
    final List<int> bottomRepoIndices = <int>[
      if (repository != null)
        for (int i = 0; i < repository.items.length; i++)
          if (!repository.items[i].isOverlay) i
    ];

    // Every bottom indicator's key, visible or hidden, in order. Keeping
    // hidden ones in this list is what preserves their stored fraction while
    // hidden (see [syncPanelFractions]), so unhiding restores the exact size
    // the panel had before.
    final List<String> allBottomIndicatorKeys =
        bottomPanelConfigs.map(_panelKeyFor).toList();

    // One flat, ordered chain covering the main chart and every bottom panel,
    // so a resize can cascade past a panel already at its minimum height into
    // the next one that still has room.
    final List<String> orderedKeys = <String>[
      PanelSizeRepository.mainPanelKey,
      ...allBottomIndicatorKeys,
    ];

    final int totalBottomCount = allBottomIndicatorKeys.length;

    _syncPanelFractions(
      orderedKeys,
      (String key) => key == PanelSizeRepository.mainPanelKey
          ? (totalBottomCount > 0 ? 3 / (3 + totalBottomCount) : 1.0)
          : 1 / (3 + totalBottomCount),
    );

    // Overlay indicators are drawn on the main chart, so a hidden one is
    // simply left out of the series list; its label stays (see
    // [_buildOverlayIndicatorsLabels]) so it can be unhidden again.
    //
    // Without a repository the series already built from `overlayConfigs` are
    // used as they are. The two sources are deliberately never merged:
    // `DerivChart` derives `overlayConfigs` *from* the repository it also
    // passes, so combining them would draw every overlay twice.
    final List<Series> visibleOverlaySeries = <Series>[];
    if (repository != null) {
      for (int i = 0; i < repository.items.length; i++) {
        final IndicatorConfig config = repository.items[i];
        if (repository.getHiddenStatus(i) || !config.isOverlay) {
          continue;
        }
        visibleOverlaySeries.add(config.getSeries(
          IndicatorInput(widget.mainSeries.input, widget.granularity),
        ));
      }
    } else {
      visibleOverlaySeries.addAll(overlaySeries ?? const <Series>[]);
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Each divider takes up real space in the same Column as the panels,
        // so it has to come off the height the fractions are applied to.
        final double usableHeight =
            _usableHeightFor(constraints.maxHeight, totalBottomCount);

        final List<Widget> children = <Widget>[
          SizedBox(
            height: (_panelFractions[PanelSizeRepository.mainPanelKey] ?? 1.0) *
                usableHeight,
            child: Stack(
              children: <Widget>[
                MainChart(
                  drawingTools: widget.drawingTools,
                  controller: _controller,
                  mainSeries: widget.mainSeries,
                  overlaySeries: visibleOverlaySeries,
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
        ];

        for (int position = 0;
            position < bottomPanelConfigs.length;
            position++) {
          final IndicatorConfig config = bottomPanelConfigs[position];
          final int repoIndex =
              repository != null ? bottomRepoIndices[position] : -1;
          final bool isHidden =
              repository != null && repository.getHiddenStatus(repoIndex);
          final String key = _panelKeyFor(config);

          final Series series = config.getSeries(
            IndicatorInput(widget.mainSeries.input, widget.granularity),
          );

          // TODO(Ramin): Use the key (type + number) once it's implemented.
          final int indexInBottomConfigs =
              referenceIndexOf(widget.bottomConfigs, config);

          // The divider directly above this panel sits between
          // `orderedKeys[position]` (main, or the previous indicator) and
          // `orderedKeys[position + 1]` (this one).
          final int dividerIndex = position;

          // A panel's label is fixed-size text and icons rather than freely
          // scalable chart content, so its fraction can work out to less pixel
          // height than the label needs. Flooring only the rendered height
          // keeps the label from being clipped without affecting the size a
          // hidden panel is restored to on unhide.
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
                child: BottomChartWithLabel(
                  series: series,
                  isHidden: isHidden,
                  isExpanded: _isLabelExpanded(config),
                  granularity: widget.granularity,
                  pipSize: config.pipSize,
                  title: _indicatorLabelTitle(config),
                  currentTickAnimationDuration: currentTickAnimationDuration,
                  quoteBoundsAnimationDuration: quoteBoundsAnimationDuration,
                  bottomChartTitleMargin: widget.bottomChartTitleMargin,
                  icons: _labelIcons,
                  onExpandToggle: () => _toggleLabelExpanded(config),
                  onHideUnhideToggle: () =>
                      _onIndicatorHideToggleTapped(repository, repoIndex),
                  onEdit: () => _onEdit(config),
                  onRemove: () => _onRemove(config),
                  onSwap: (int offset) => _onSwap(config,
                      widget.bottomConfigs[indexInBottomConfigs + offset]),
                  showMoveUpIcon:
                      totalBottomCount > 1 && indexInBottomConfigs != 0,
                  showMoveDownIcon: totalBottomCount > 1 &&
                      indexInBottomConfigs != totalBottomCount - 1,
                  showFrame: false,
                ),
              ),
            );
        }

        return Column(children: children);
      },
    );
  }
}
