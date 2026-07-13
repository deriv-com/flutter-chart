import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/mobile_chart_frame_dividers.dart';
import 'package:deriv_chart/src/deriv_chart/chart/panel_size/panel_size_repository.dart';
import 'package:deriv_chart/src/deriv_chart/chart/resizable_chart_divider.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_variant.dart';
import 'package:deriv_chart/src/theme/dimens.dart';
import 'package:flutter/foundation.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_wrapper.dart';
import 'package:deriv_chart/src/deriv_chart/drawing_tool_chart/drawing_tools.dart';
import 'package:deriv_chart/src/misc/callbacks.dart';
import 'package:deriv_chart/src/models/chart_axis_config.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/chart_default_light_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../add_ons/indicators_ui/indicator_config.dart';
import '../../add_ons/repository.dart';
import '../../misc/chart_controller.dart';
import '../../models/tick.dart';
import '../../theme/chart_default_dark_theme.dart';
import '../../theme/chart_theme.dart';
import '../interactive_layer/interactive_layer_behaviours/interactive_layer_behaviour.dart';
import 'bottom_chart.dart';
import 'bottom_chart_mobile.dart';
import 'data_visualization/annotations/chart_annotation.dart';
import 'data_visualization/chart_data.dart';
import 'data_visualization/chart_series/data_series.dart';
import 'data_visualization/chart_series/series.dart';
import 'data_visualization/markers/marker_series.dart';
import 'data_visualization/models/chart_object.dart';
import 'main_chart.dart';

part 'chart_state_web.dart';

part 'chart_state_mobile.dart';

const Duration _defaultDuration = Duration(milliseconds: 300);

/// Ensures [fractions] has exactly one entry per key in [keys], seeding new
/// keys from [saved] (if previously persisted) or from [defaultFraction],
/// dropping any key no longer present in [keys], and renormalizing so the
/// remaining fractions always sum to `1.0`.
///
/// [fractions] is expected to represent one independent group of sibling
/// panels whose heights add up to the full space they share - e.g. the main
/// chart plus every bottom panel, or (on mobile) the individual indicator
/// panels sharing the bottom section.
///
/// `SharedPreferences` access backing [saved] is async, so a chart's very
/// first build always runs before it has actually loaded - every key gets
/// seeded from [defaultFraction] since [saved] is still empty at that point.
/// Set [forceApplySaved] once that load has completed (see
/// [PanelSizeRepository.loadGeneration]) to overwrite already-seeded keys
/// with the real saved values instead of leaving them stuck at the
/// placeholder defaults; leave it `false` on every other build so a value
/// the user is actively resizing isn't clobbered by a stale saved fraction.
void syncPanelFractions(
  Map<String, double> fractions,
  List<String> keys,
  Map<String, double> saved,
  double Function(String key) defaultFraction, {
  bool forceApplySaved = false,
}) {
  final Set<String> keySet = keys.toSet();
  fractions.removeWhere((String key, _) => !keySet.contains(key));

  for (final String key in keys) {
    if (forceApplySaved && saved.containsKey(key)) {
      fractions[key] = saved[key]!;
    } else {
      fractions[key] ??= saved[key] ?? defaultFraction(key);
    }
  }

  final double sum = fractions.values.fold(0, (double a, double b) => a + b);
  if (sum > 0 && sum != 1.0) {
    fractions.updateAll((_, double value) => value / sum);
  }
}

/// Cascading resize: dragging the divider between `orderedKeys[dividerIndex]`
/// and `orderedKeys[dividerIndex + 1]` grows one side by [deltaFraction] and
/// shrinks the other. A positive [deltaFraction] grows
/// `orderedKeys[dividerIndex]`; a negative one grows
/// `orderedKeys[dividerIndex + 1]`.
///
/// The space to shrink is taken from the nearest neighbor on the shrinking
/// side first; if that neighbor is already at the minimum height (a fixed
/// share of the total, [Dimens.minChartPanelHeightFraction], rather than a
/// fixed pixel amount - so it scales down on small screens instead of
/// eating an unreasonably large share of them), the remainder cascades
/// further down the chain (e.g. dragging the divider between a second and
/// third panel can shrink the first panel too, once the second has nothing
/// left to give) so resizing never gets stuck behind an in-between panel
/// that's already at its minimum. Returns whether [fractions] was changed.
bool resizeCascadingFractions(
  Map<String, double> fractions,
  List<String> orderedKeys,
  int dividerIndex,
  double deltaFraction,
) {
  if (deltaFraction == 0) {
    return false;
  }

  const double minFraction = Dimens.minChartPanelHeightFraction;

  final String recipientKey;
  final List<String> donorChain;
  if (deltaFraction > 0) {
    recipientKey = orderedKeys[dividerIndex];
    donorChain = orderedKeys.sublist(dividerIndex + 1);
  } else {
    recipientKey = orderedKeys[dividerIndex + 1];
    donorChain = orderedKeys.sublist(0, dividerIndex + 1).reversed.toList();
  }

  double remaining = deltaFraction.abs();
  double actualDelta = 0;
  for (final String donor in donorChain) {
    if (remaining <= 0) {
      break;
    }
    final double current = fractions[donor] ?? 0;
    final double avail = current - minFraction;
    if (avail <= 0) {
      continue;
    }
    final double take = avail < remaining ? avail : remaining;
    fractions[donor] = current - take;
    remaining -= take;
    actualDelta += take;
  }

  if (actualDelta <= 0) {
    return false;
  }

  fractions[recipientKey] = (fractions[recipientKey] ?? 0) + actualDelta;
  return true;
}

/// Interactive chart widget.
class Chart extends StatefulWidget {
  /// Creates chart that expands to available space.
  const Chart({
    required this.mainSeries,
    required this.granularity,
    required this.crosshairVariant,
    this.interactiveLayerBehaviour,
    this.drawingTools,
    this.pipSize = 4,
    this.controller,
    this.overlayConfigs,
    this.bottomConfigs = const <IndicatorConfig>[],
    this.markerSeries,
    this.theme,
    this.onCrosshairAppeared,
    this.onCrosshairDisappeared,
    this.onCrosshairHover,
    this.onVisibleAreaChanged,
    this.onQuoteAreaChanged,
    this.isLive = false,
    this.dataFitEnabled = false,
    this.opacity = 1.0,
    this.annotations,
    this.chartAxisConfig = const ChartAxisConfig(),
    this.showCrosshair = false,
    this.indicatorsRepo,
    this.msPerPx,
    this.minIntervalWidth,
    this.maxIntervalWidth,
    this.dataFitPadding,
    this.currentTickAnimationDuration,
    this.quoteBoundsAnimationDuration,
    this.showCurrentTickBlinkAnimation,
    this.verticalPaddingFraction,
    this.bottomChartTitleMargin,
    this.showDataFitButton,
    this.showScrollToLastTickButton,
    this.loadingAnimationColor,
    this.useDrawingToolsV2 = false,
    this.panelSizeRepo,
    Key? key,
  }) : super(key: key);

  /// Whether to use new drawing tools or not.
  final bool useDrawingToolsV2;

  /// Chart's main data series.
  final DataSeries<Tick> mainSeries;

  /// List of overlay indicator series to add on chart beside the [mainSeries].
  final List<IndicatorConfig>? overlayConfigs;

  /// List of bottom indicator series to add on chart separate from the
  /// [mainSeries].
  final List<IndicatorConfig> bottomConfigs;

  /// Open position marker series.
  final MarkerSeries? markerSeries;

  /// Keep the reference to the drawing tools class for
  /// sharing data between the DerivChart and the DrawingToolsDialog
  final DrawingTools? drawingTools;

  /// Chart's controller
  final ChartController? controller;

  /// Number of digits after decimal point in price.
  final int pipSize;

  /// For candles: Duration of one candle in ms.
  /// For ticks: Average ms difference between two consecutive ticks.
  final int granularity;

  /// Called when crosshair details appear after long press.
  final VoidCallback? onCrosshairAppeared;

  /// Called when the crosshair is dismissed.
  final VoidCallback? onCrosshairDisappeared;

  /// Called when the crosshair cursor is hovered/moved.
  final OnCrosshairHoverCallback? onCrosshairHover;

  /// Called when chart is scrolled or zoomed.
  final VisibleAreaChangedCallback? onVisibleAreaChanged;

  /// Callback provided by library user.
  final VisibleQuoteAreaChangedCallback? onQuoteAreaChanged;

  /// Chart's theme.
  final ChartTheme? theme;

  /// Chart's annotations
  final List<ChartAnnotation<ChartObject>>? annotations;

  /// Whether the chart should be showing live data or not.
  ///
  /// In case of being true the chart will keep auto-scrolling when its visible
  /// area is on the newest ticks/candles.
  final bool isLive;

  /// Starts in data fit mode and adds a data-fit button.
  final bool dataFitEnabled;

  /// Chart's opacity, Will be applied on the [mainSeries].
  final double opacity;

  /// Configurations for chart's axes.
  final ChartAxisConfig chartAxisConfig;

  /// Whether the crosshair should be shown or not.
  final bool showCrosshair;

  /// Specifies the zoom level of the chart.
  final double? msPerPx;

  /// Specifies the minimum interval width
  /// that is used for calculating the maximum msPerPx.
  final double? minIntervalWidth;

  /// Specifies the maximum interval width
  /// that is used for calculating the maximum msPerPx.
  final double? maxIntervalWidth;

  /// Padding around data used in data-fit mode.
  final EdgeInsets? dataFitPadding;

  /// Duration of the current tick animated transition.
  final Duration? currentTickAnimationDuration;

  /// Duration of quote bounds animated transition.
  final Duration? quoteBoundsAnimationDuration;

  /// Whether to show current tick blink animation or not.
  final bool? showCurrentTickBlinkAnimation;

  /// Fraction of the chart's height taken by top or bottom padding.
  /// Quote scaling (drag on quote area) is controlled by this variable.
  final double? verticalPaddingFraction;

  /// Specifies the margin to prevent overlap.
  final EdgeInsets? bottomChartTitleMargin;

  /// Whether the data fit button is shown or not.
  final bool? showDataFitButton;

  /// Whether to show the scroll to last tick button or not.
  final bool? showScrollToLastTickButton;

  /// The color of the loading animation.
  final Color? loadingAnimationColor;

  /// Chart's indicators
  final Repository<IndicatorConfig>? indicatorsRepo;

  /// The variant of the crosshair to be used.
  /// This is used to determine the type of crosshair to display.
  /// The default is [CrosshairVariant.smallScreen].
  /// [CrosshairVariant.largeScreen] is mostly for web.
  final CrosshairVariant crosshairVariant;

  /// The interactive layer behaviour.
  final InteractiveLayerBehaviour? interactiveLayerBehaviour;

  /// Persists the relative sizes of the main chart and bottom indicator
  /// panels as the user drags [ResizableChartDivider]s between them.
  final PanelSizeRepository? panelSizeRepo;

  @override
  State<StatefulWidget> createState() =>
      // TODO(Ramin): Make this customizable from outside.
      kIsWeb ? _ChartStateWeb() : _ChartStateMobile();
}

// ignore: prefer_mixin
abstract class _ChartState extends State<Chart> with WidgetsBindingObserver {
  bool? _followCurrentTick;
  late ChartController _controller;
  late ChartTheme _chartTheme;
  late List<Series>? bottomSeries;
  int? expandedIndex;

  /// Current fraction of the available height occupied by each chart panel,
  /// keyed by [PanelSizeRepository.mainPanelKey] for the main chart and by
  /// [IndicatorConfig.configId] for each bottom indicator panel.
  final Map<String, double> _panelFractions = <String, double>{};

  /// The [PanelSizeRepository.loadGeneration] already applied to
  /// [_panelFractions], or `null` if none has been applied yet. See
  /// [_syncPanelFractions].
  int? _appliedPanelSizeGeneration;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addObserver(this);
    _initChartController();
    widget.panelSizeRepo?.addListener(_onPanelSizeRepoChanged);
  }

  /// `PanelSizeRepository.loadFromPrefs` completes asynchronously, so this
  /// forces a rebuild once it has (see [_syncPanelFractions]) - otherwise a
  /// load that finishes after this chart's first build would silently never
  /// reach the screen.
  void _onPanelSizeRepoChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initChartTheme();
  }

  void _initChartController() {
    _controller = widget.controller ?? ChartController();
  }

  List<Series>? _getIndicatorSeries(List<IndicatorConfig>? configs) {
    if (configs == null) {
      return null;
    }

    return configs
        .map((IndicatorConfig indicatorConfig) => indicatorConfig.getSeries(
              IndicatorInput(
                widget.mainSeries.input,
                widget.granularity,
              ),
            ))
        .toList();
  }

  void _initChartTheme() {
    _chartTheme = widget.theme ??
        (Theme.of(context).brightness == Brightness.dark
            ? ChartDefaultDarkTheme()
            : ChartDefaultLightTheme());
  }

  /// Ensures [_panelFractions] has exactly one entry per key in [keys],
  /// seeding new keys from [widget.panelSizeRepo] (if previously saved) or
  /// from [defaultFraction], dropping stale keys, and renormalizing so the
  /// fractions always sum to `1.0`.
  ///
  /// [widget.panelSizeRepo]'s load is async, so the first call here (during
  /// this chart's very first build) always seeds every key from
  /// [defaultFraction] since nothing has loaded yet. Once
  /// [PanelSizeRepository.loadGeneration] moves past whatever generation was
  /// last applied - flagged via [_onPanelSizeRepoChanged] forcing a rebuild -
  /// this overwrites those placeholder defaults with the real saved values
  /// exactly once per load, instead of leaving them stuck.
  void _syncPanelFractions(
    List<String> keys,
    double Function(String key) defaultFraction,
  ) {
    final PanelSizeRepository? repo = widget.panelSizeRepo;
    final bool forceApplySaved = repo != null &&
        repo.loadGeneration > 0 &&
        repo.loadGeneration != _appliedPanelSizeGeneration;
    if (forceApplySaved) {
      _appliedPanelSizeGeneration = repo.loadGeneration;
    }

    syncPanelFractions(
      _panelFractions,
      keys,
      repo?.fractions ?? const <String, double>{},
      defaultFraction,
      forceApplySaved: forceApplySaved,
    );
  }

  /// Cascading resize of the divider at [dividerIndex] within
  /// [_panelFractions]. See [resizeCascadingFractions].
  void _resizeCascadingPanels(
    List<String> orderedKeys,
    int dividerIndex,
    double deltaFraction,
  ) {
    if (resizeCascadingFractions(
      _panelFractions,
      orderedKeys,
      dividerIndex,
      deltaFraction,
    )) {
      setState(() {});
    }
  }

  /// Persists [_panelFractions], merged with any [extraFractions] (used by
  /// mobile to also persist the relative sizes of individual bottom
  /// indicator panels, which are tracked in a separate map).
  void _persistPanelFractions([
    Map<String, double> extraFractions = const <String, double>{},
  ]) {
    widget.panelSizeRepo?.save(<String, double>{
      ..._panelFractions,
      ...extraFractions,
    });
  }

  /// Key for [config]'s panel within [_panelFractions]/[PanelSizeRepository].
  ///
  /// Prefers [AddOnConfig.configId] - a fresh id assigned when the indicator
  /// is added (see `IndicatorsDialog`'s "Add" handler) - since a positional
  /// or title/number-based key would tie a saved size to whatever happens to
  /// look the same, meaning deleting an indicator and adding a new one of
  /// the same type back could silently inherit the deleted one's size.
  /// Falls back to [IndicatorConfig.title] + [AddOnConfig.number] for
  /// indicators added without a [configId] (e.g. persisted from before this
  /// existed, or added directly by a host app rather than through the
  /// indicators dialog).
  String _panelKeyFor(IndicatorConfig config) =>
      config.configId ?? '${config.title}#${config.number}';

  /// Height available for panel fractions once [dividerCount]
  /// [ResizableChartDivider]s - which take up real space in the same
  /// Column as the panels - have been subtracted from [totalHeight].
  double _usableHeightFor(double totalHeight, int dividerCount) =>
      (totalHeight - dividerCount * Dimens.chartPanelDividerHitHeight)
          .clamp(0.0, double.infinity);

  void _onCrosshairHover(
    Offset globalPosition,
    Offset localPosition,
    EpochToX epochToX,
    QuoteToY quoteToY,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
  ) {
    widget.onCrosshairHover?.call(
      globalPosition,
      localPosition,
      epochToX,
      quoteToY,
      epochFromX,
      quoteFromY,
      null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ChartConfig chartConfig = ChartConfig(
      pipSize: widget.pipSize,
      granularity: widget.granularity,
      chartAxisConfig: widget.chartAxisConfig,
    );
    // Calculate default msPerPx based on granularity and default interval width (which defaults to 20 pixels), msPerPx could be null in situations like when data fit mode is enabled.
    final double defaultMsPerPx =
        widget.granularity / widget.chartAxisConfig.defaultIntervalWidth;

    final ChartScaleModel _chartScaleModel = ChartScaleModel(
        granularity: widget.granularity,
        msPerPx: widget.msPerPx ?? defaultMsPerPx);

    final List<Series>? overlaySeries =
        _getIndicatorSeries(widget.overlayConfigs);

    final List<Series>? bottomSeries =
        _getIndicatorSeries(widget.bottomConfigs);

    final List<ChartData> chartDataList = <ChartData>[
      widget.mainSeries,
      if (overlaySeries != null) ...overlaySeries,
      if (bottomSeries != null) ...bottomSeries,
      if (widget.annotations != null) ...widget.annotations!,
    ];

    _controller
      ..getSeriesList = (() => <Series>[
            if (overlaySeries != null) ...overlaySeries,
            if (bottomSeries != null) ...bottomSeries,
          ])
      ..getConfigsList = (() => <IndicatorConfig>[
            if (widget.overlayConfigs != null) ...?widget.overlayConfigs,
            ...widget.bottomConfigs,
          ]);

    final Duration currentTickAnimationDuration =
        widget.currentTickAnimationDuration ?? _defaultDuration;

    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<ChartTheme>.value(value: _chartTheme),
        Provider<ChartConfig>.value(value: chartConfig),
        Provider<ChartScaleModel>.value(value: _chartScaleModel),
      ],
      child: Ink(
        color: _chartTheme.backgroundColor,
        child: GestureManager(
          child: XAxisWrapper(
            maxEpoch: chartDataList.getMaxEpoch(),
            minEpoch: chartDataList.getMinEpoch(),
            chartAxisConfig: widget.chartAxisConfig,
            entries: widget.mainSeries.input,
            pipSize: widget.pipSize,
            onVisibleAreaChanged: _onVisibleAreaChanged,
            isLive: widget.isLive,
            startWithDataFitMode: widget.dataFitEnabled,
            msPerPx: widget.msPerPx,
            minIntervalWidth: widget.minIntervalWidth,
            maxIntervalWidth: widget.maxIntervalWidth,
            dataFitPadding: widget.dataFitPadding,
            scrollAnimationDuration: currentTickAnimationDuration,
            child: buildChartsLayout(context, overlaySeries, bottomSeries),
          ),
        ),
      ),
    );
  }

  Widget buildChartsLayout(
    BuildContext context,
    List<Series>? overlaySeries,
    List<Series>? bottomSeries,
  );

  void _onEdit(IndicatorConfig config) {
    if (widget.indicatorsRepo != null) {
      final int index = widget.indicatorsRepo!.items.indexOf(config);
      widget.indicatorsRepo!.editAt(index);
    }
  }

  void _onRemove(IndicatorConfig config) {
    expandedIndex = null;

    if (widget.indicatorsRepo != null) {
      final int index = widget.indicatorsRepo!.items.indexOf(config);
      widget.indicatorsRepo!.removeAt(index);
    }
  }

  void _onSwap(IndicatorConfig config1, IndicatorConfig config2) {
    if (widget.indicatorsRepo != null) {
      final int index1 = widget.indicatorsRepo!.items.indexOf(config1);
      final int index2 = widget.indicatorsRepo!.items.indexOf(config2);
      widget.indicatorsRepo!.swap(index1, index2);
    }
  }

  void _onVisibleAreaChanged(int leftBoundEpoch, int rightBoundEpoch) {
    widget.onVisibleAreaChanged?.call(leftBoundEpoch, rightBoundEpoch);

    // detect what is current viewing mode before lock the screen
    if (widget.mainSeries.entries != null &&
        widget.mainSeries.entries!.isNotEmpty) {
      if (rightBoundEpoch > widget.mainSeries.entries!.last.epoch) {
        _followCurrentTick = true;
      } else {
        _followCurrentTick = false;
      }
    }
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    //scroll to last tick when screen is on
    if (state == AppLifecycleState.resumed &&
        _followCurrentTick != null &&
        _followCurrentTick!) {
      WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
        // Complete the animation immediately to clear stale previousObject/
        // prevLastEntry values that may have accumulated while the web browser
        // tab was hidden. This prevents the stretched line glitch.
        _controller.onCompleteTickAnimation?.call();
        _controller.onScrollToLastTick?.call(animate: false);
      });
    }
  }

  @override
  void dispose() {
    WidgetsFlutterBinding.ensureInitialized().removeObserver(this);
    widget.panelSizeRepo?.removeListener(_onPanelSizeRepoChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Chart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.panelSizeRepo != oldWidget.panelSizeRepo) {
      oldWidget.panelSizeRepo?.removeListener(_onPanelSizeRepoChanged);
      widget.panelSizeRepo?.addListener(_onPanelSizeRepoChanged);
      _appliedPanelSizeGeneration = null;
    }

    // if controller is set
    if (widget.controller != oldWidget.controller) {
      _initChartController();
    }
    if (widget.theme != oldWidget.theme) {
      _initChartTheme();
    }

    //check if entire entries changes(market or granularity changes)
    // scroll to last tick
    if (widget.mainSeries.entries != null &&
        widget.mainSeries.entries!.isNotEmpty) {
      if (widget.mainSeries.entries!.first.epoch !=
          oldWidget.mainSeries.entries!.first.epoch) {
        _controller.onScrollToLastTick?.call(animate: false);
      }
    }

    // Check if the the expanded bottom indicator is moved/removed.
    if (expandedIndex != null &&
        oldWidget.bottomConfigs.length != widget.bottomConfigs.length &&
        expandedIndex! < (oldWidget.bottomConfigs.length)) {
      final int? newIndex =
          widget.bottomConfigs.indexOf(oldWidget.bottomConfigs[expandedIndex!]);
      if (newIndex != expandedIndex) {
        expandedIndex = newIndex == -1 ? null : newIndex;
      }
    }
  }
}
