import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tools_dialog.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicators_dialog.dart';
import 'package:deriv_chart/src/misc/extensions.dart';
import 'package:deriv_chart/src/widgets/animated_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A wrapper around the [Chart] which handles adding indicators to the chart.
class DerivChart extends StatefulWidget {
  /// Initializes
  const DerivChart({
    required this.drawingTools,
    required this.mainSeries,
    required this.granularity,
    this.markerSeries,
    this.controller,
    this.onCrosshairAppeared,
    this.onCrosshairDisappeared,
    this.onCrosshairHover,
    this.onVisibleAreaChanged,
    this.onQuoteAreaChanged,
    this.theme,
    this.isLive = false,
    this.dataFitEnabled = false,
    this.showCrosshair = true,
    this.annotations,
    this.opacity = 1.0,
    this.pipSize = 4,
    this.indicatorsRepo,
    this.drawingToolsRepo,
    this.maxCurrentTickOffset,
    this.msPerPx,
    this.minIntervalWidth,
    this.maxIntervalWidth,
    this.verticalPaddingFraction,
    this.bottomChartTitleMargin,
    this.showDataFitButton,
    this.showScrollToLastTickButton,
    this.loadingAnimationColor,
    Key? key,
  }) : super(key: key);

  /// Chart's main data series
  final DataSeries<Tick> mainSeries;

  /// Open position marker series.
  final MarkerSeries? markerSeries;

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
  /// In case of being true the chart will keep auto-scrolling when its visible
  /// area is on the newest ticks/candles.
  final bool isLive;

  /// Starts in data fit mode and adds a data-fit button.
  final bool dataFitEnabled;

  /// Chart's opacity, Will be applied on the [mainSeries].
  final double opacity;

  /// Whether the crosshair should be shown or not.
  final bool showCrosshair;

  /// Max distance between rightBoundEpoch and nowEpoch in pixels.
  final double? maxCurrentTickOffset;

  /// Specifies the zoom level of the chart.
  final double? msPerPx;

  /// Specifies the minimum interval width
  /// that is used for calculating the maximum msPerPx.
  final double? minIntervalWidth;

  /// Specifies the maximum interval width
  /// that is used for calculating the maximum msPerPx.
  final double? maxIntervalWidth;

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

  /// Chart's drawings
  final Repository<DrawingToolConfig>? drawingToolsRepo;

  /// List of drawing tools
  final DrawingTools drawingTools;

  @override
  _DerivChartState createState() => _DerivChartState();
}

class _DerivChartState extends State<DerivChart> {
  late AddOnsRepository<IndicatorConfig> _indicatorsRepo;

  late AddOnsRepository<DrawingToolConfig> _drawingToolsRepo;

  // final DrawingTools _drawingTools = DrawingTools();

  @override
  void initState() {
    super.initState();

    loadSavedIndicatorsAndDrawingTools();
    _initRepos();
  }

  void _initRepos() {
    _indicatorsRepo = AddOnsRepository<IndicatorConfig>(
      createAddOn: (Map<String, dynamic> map) => IndicatorConfig.fromJson(map),
      onEditCallback: showIndicatorsDialog,
    );

    _drawingToolsRepo = AddOnsRepository<DrawingToolConfig>(
      createAddOn: (Map<String, dynamic> map) =>
          DrawingToolConfig.fromJson(map),
      onEditCallback: showDrawingToolsDialog,
    );

    widget.drawingTools.drawingToolsRepo = widget.drawingToolsRepo;
  }

  Future<void> loadSavedIndicatorsAndDrawingTools() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<AddOnsRepository<AddOnConfig>> _stateRepos =
        <AddOnsRepository<AddOnConfig>>[_indicatorsRepo, _drawingToolsRepo];

    _stateRepos.asMap().forEach((int index, dynamic element) {
      try {
        element.loadFromPrefs(prefs);
      } on Exception {
        // ignore: unawaited_futures
        showDialog<void>(
          context: context,
          builder: (BuildContext context) => AnimatedPopupDialog(
            child: Center(
              child: element is Repository<IndicatorConfig>
                  ? Text(context.localization.warnFailedLoadingIndicators)
                  : Text(context.localization.warnFailedLoadingDrawingTools),
            ),
          ),
        );
      }
    });
  }

  void showIndicatorsDialog() {
    showDialog<void>(
      context: context,
      builder: (
        BuildContext context,
      ) =>
          ChangeNotifierProvider<Repository<IndicatorConfig>>.value(
        value: _indicatorsRepo,
        child: IndicatorsDialog(),
      ),
    );
  }

  void showDrawingToolsDialog() {
    setState(() {
      widget.drawingTools
        ..init()
        ..drawingToolsRepo = _drawingToolsRepo;
    });
    showDialog<void>(
      context: context,
      builder: (
        BuildContext context,
      ) =>
          ChangeNotifierProvider<Repository<DrawingToolConfig>>.value(
        value: _drawingToolsRepo,
        child: DrawingToolsDialog(
          drawingTools: widget.drawingTools,
        ),
      ),
    );
  }

  Widget _buildIndicatorsIcon() => Align(
        alignment: Alignment.topLeft,
        child: IconButton(
          icon: const Icon(Icons.architecture),
          onPressed: showIndicatorsDialog,
        ),
      );

  Widget _buildDrawingToolsIcon() => Align(
        alignment: const FractionalOffset(0.1, 0),
        child: IconButton(
          icon: const Icon(Icons.drive_file_rename_outline_outlined),
          onPressed: showDrawingToolsDialog,
        ),
      );

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: <ChangeNotifierProvider<Repository<AddOnConfig>>>[
          ChangeNotifierProvider<Repository<IndicatorConfig>>.value(
              value: widget.indicatorsRepo ?? _indicatorsRepo),
          ChangeNotifierProvider<Repository<DrawingToolConfig>>.value(
              value: widget.drawingToolsRepo ?? _drawingToolsRepo),
        ],
        child: Builder(
          builder: (BuildContext context) => Stack(
            children: <Widget>[
              Chart(
                mainSeries: widget.mainSeries,
                pipSize: widget.pipSize,
                granularity: widget.granularity,
                controller: widget.controller,
                overlayConfigs: <IndicatorConfig>[
                  ...context
                      .watch<Repository<IndicatorConfig>>()
                      .items
                      .where((IndicatorConfig config) => config.isOverlay)
                ],
                bottomConfigs: <IndicatorConfig>[
                  ...context
                      .watch<Repository<IndicatorConfig>>()
                      .items
                      .where((IndicatorConfig config) => !config.isOverlay)
                ],
                drawingTools: widget.drawingTools,
                markerSeries: widget.markerSeries,
                theme: widget.theme,
                onCrosshairAppeared: widget.onCrosshairAppeared,
                onCrosshairDisappeared: widget.onCrosshairDisappeared,
                onCrosshairHover: widget.onCrosshairHover,
                onVisibleAreaChanged: widget.onVisibleAreaChanged,
                onQuoteAreaChanged: widget.onQuoteAreaChanged,
                isLive: widget.isLive,
                dataFitEnabled: widget.dataFitEnabled,
                opacity: widget.opacity,
                annotations: widget.annotations,
                showCrosshair: widget.showCrosshair,
                indicatorsRepo: widget.indicatorsRepo ?? _indicatorsRepo,
                maxCurrentTickOffset: widget.maxCurrentTickOffset,
                msPerPx: widget.msPerPx,
                minIntervalWidth: widget.minIntervalWidth,
                maxIntervalWidth: widget.maxIntervalWidth,
                verticalPaddingFraction: widget.verticalPaddingFraction,
                bottomChartTitleMargin: widget.bottomChartTitleMargin,
                showDataFitButton: widget.showDataFitButton,
                showScrollToLastTickButton: widget.showScrollToLastTickButton,
                loadingAnimationColor: widget.loadingAnimationColor,
              ),
              if (widget.indicatorsRepo == null) _buildIndicatorsIcon(),
              if (widget.drawingToolsRepo == null) _buildDrawingToolsIcon(),
            ],
          ),
        ),
      );
}
