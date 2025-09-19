import 'dart:async';
import 'dart:collection';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math' as math;

import 'package:deriv_chart/deriv_chart.dart';
import 'package:example/generated/l10n.dart';
import 'package:example/settings_page.dart';
import 'package:example/utils/endpoints_helper.dart';
import 'package:example/widgets/connection_status_label.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deriv_api/api/exceptions/exceptions.dart';
import 'package:flutter_deriv_api/api/manually/ohlc_response_result.dart';
import 'package:flutter_deriv_api/api/manually/tick.dart' as tick_api;
import 'package:flutter_deriv_api/api/manually/tick_base.dart';
import 'package:flutter_deriv_api/api/manually/tick_history_subscription.dart';
import 'package:flutter_deriv_api/api/response/active_symbols_response_result.dart';
import 'package:flutter_deriv_api/api/response/ticks_history_response_result.dart';
import 'package:flutter_deriv_api/basic_api/generated/api.dart';
import 'package:flutter_deriv_api/services/connection/api_manager/connection_information.dart';
import 'package:flutter_deriv_api/state/connection/connection_cubit.dart'
    as connection_bloc;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pref/pref.dart';

import 'utils/misc.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

/// The start of the application.
class MyApp extends StatelessWidget {
  /// Intiialize
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          ChartLocalization.delegate,
          ExampleLocalization.delegate,
        ],
        supportedLocales: ExampleLocalization.delegate.supportedLocales,
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: const SafeArea(
          child: Scaffold(
            body: FullscreenChart(),
          ),
        ),
      );
}

/// Chart that sits in fullscreen.
class FullscreenChart extends StatefulWidget {
  /// Initializes a chart that sits in fullscreen.
  const FullscreenChart({Key? key}) : super(key: key);

  @override
  _FullscreenChartState createState() => _FullscreenChartState();
}

class _FullscreenChartState extends State<FullscreenChart> {
  static const String defaultAppID = '36544';
  static const String defaultEndpoint = 'blue.derivws.com';

  List<Tick> ticks = <Tick>[];
  ChartStyle style = ChartStyle.line;
  int granularity = 0;

  final List<Barrier> _sampleBarriers = <Barrier>[];
  HorizontalBarrier? _slBarrier, _tpBarrier;
  bool _sl = false, _tp = false;

  TickHistorySubscription? _tickHistorySubscription;

  StreamSubscription<TickBase?>? _tickStreamSubscription;

  late connection_bloc.ConnectionCubit _connectionBloc;

  bool _waitingForHistory = false;

  // Is used to make sure we make only one request to the API at a time.
  // We will not make a new call until the prev call has completed.
  late Completer<dynamic> _requestCompleter;

  List<Market> _markets = <Market>[];
  final SplayTreeSet<Marker> _markers = SplayTreeSet<Marker>();

  ActiveMarker? _activeMarker;
  ActiveMarkerGroup? _activeMarkerGroup;

  late List<ActiveSymbolsItem> _activeSymbols;

  Asset _symbol = Asset(name: 'R_50');

  final ChartController _controller = ChartController();
  PersistentBottomSheetController? _bottomSheetController;

  late final InteractiveLayerBehaviour _interactiveLayerBehaviour;

  final InteractiveLayerController _interactiveLayerController =
      InteractiveLayerController();

  late PrefServiceCache _prefService;

  TradeType _currentTradeType = TradeType.multipliers;

  // Dynamic marker duration in milliseconds
  int _markerDurationMs = 10000;
  // PnL label lifetime after marker end in milliseconds
  static const int _pnlLabelLifetimeMs = 4000;

  @override
  void initState() {
    super.initState();
    _requestCompleter = Completer<dynamic>();
    _connectToAPI();
    _initPrefs();

    _interactiveLayerBehaviour = kIsWeb
        ? InteractiveLayerDesktopBehaviour(
            controller: _interactiveLayerController)
        : InteractiveLayerMobileBehaviour(
            controller: _interactiveLayerController);
  }

  Future<void> _initPrefs() async {
    _prefService = PrefServiceCache();
    await _prefService.setDefaultValues(<String, dynamic>{
      'appID': defaultAppID,
      'endpoint': defaultEndpoint,
      'tradeType': TradeType.multipliers.value,
    });

    // Load current trade type from preferences
    await _loadTradeType();
  }

  Future<void> _loadTradeType() async {
    // Get the trade type directly from PrefService instead of SharedPreferences
    // to ensure we get the latest value immediately
    final String? tradeTypeValue = _prefService.get<String>('tradeType');
    if (tradeTypeValue != null) {
      final TradeType newTradeType =
          TradeTypeExtension.fromValue(tradeTypeValue);
      setState(() {
        _currentTradeType = newTradeType;
      });
    }
  }

  @override
  void dispose() {
    _tickStreamSubscription?.cancel();
    _connectionBloc.close();
    _bottomSheetController?.close();
    super.dispose();
  }

  Future<void> _connectToAPI() async {
    _connectionBloc = connection_bloc.ConnectionCubit(
        const ConnectionInformation(
      endpoint: defaultEndpoint,
      appId: defaultAppID,
      brand: 'deriv',
      authEndpoint: '',
    ))
      ..stream.listen((connection_bloc.ConnectionState connectionState) async {
        if (connectionState is! connection_bloc.ConnectionConnectedState) {
          // Calling this since we show some status labels when NOT connected.
          setState(() {});
          return;
        }

        if (ticks.isEmpty) {
          try {
            await _getActiveSymbols();

            if (!_requestCompleter.isCompleted) {
              _requestCompleter.complete();
            }
            await _onIntervalSelected(0);
          } on BaseAPIException catch (e) {
            await showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(
                  e.message!,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            );
          }
        } else {
          await _initTickStream(
            TicksHistoryRequest(
              ticksHistory: _symbol.name,
              adjustStartTime: 1,
              end: 'latest',
              start: ticks.last.epoch ~/ 1000,
              style: granularity == 0 ? 'ticks' : 'candles',
              granularity: granularity > 0 ? granularity : null,
            ),
            resume: true,
          );
        }
      });
  }

  Future<void> _getActiveSymbols() async {
    _activeSymbols = (await ActiveSymbolsResponse.fetchActiveSymbols(
      const ActiveSymbolsRequest(
        activeSymbols: 'brief',
        productType: 'basic',
        landingCompany: null,
      ),
    ))
        .activeSymbols!;

    final ActiveSymbolsItem firstOpenSymbol = _activeSymbols.firstWhere(
        (ActiveSymbolsItem activeSymbol) => activeSymbol.exchangeIsOpen);

    _symbol = Asset(
      name: firstOpenSymbol.symbol,
      displayName: firstOpenSymbol.displayName,
      market: firstOpenSymbol.market,
      subMarket: firstOpenSymbol.submarket,
      isOpen: firstOpenSymbol.exchangeIsOpen,
    );

    _fillMarketSelectorList();
  }

  void _fillMarketSelectorList() {
    final Set<String?> marketTitles = <String?>{};

    final List<Market> markets = <Market>[];

    for (final ActiveSymbolsItem symbol in _activeSymbols) {
      if (!marketTitles.contains(symbol.market)) {
        marketTitles.add(symbol.market);
        markets.add(
          Market.fromAssets(
            name: symbol.market,
            displayName: symbol.marketDisplayName,
            assets: _activeSymbols
                .where((dynamic activeSymbol) =>
                    activeSymbol.market == symbol.market)
                .map<Asset>((dynamic activeSymbol) => Asset(
                      market: activeSymbol.market,
                      marketDisplayName: activeSymbol.marketDisplayName,
                      subMarket: activeSymbol.submarket,
                      name: activeSymbol.symbol,
                      displayName: activeSymbol.displayName,
                      subMarketDisplayName: activeSymbol.submarketDisplayName,
                      isOpen: activeSymbol.exchangeIsOpen,
                    ))
                .toList(),
          ),
        );
      }
    }
    setState(() => _markets = markets);
    _bottomSheetController?.setState?.call(() {});
  }

  Future<void> _initTickStream(
    TicksHistoryRequest request, {
    bool resume = false,
  }) async {
    try {
      await _tickStreamSubscription?.cancel();

      if (_symbol.isOpen) {
        _tickHistorySubscription =
            await TicksHistoryResponse.fetchTicksAndSubscribe(request);

        final List<Tick> fetchedTicks =
            _getTicksFromResponse(_tickHistorySubscription!.tickHistory!);

        if (resume) {
          // TODO(ramin): Consider changing TicksHistoryRequest params to avoid
          // overlapping ticks
          if (ticks.last.epoch == fetchedTicks.first.epoch) {
            ticks.removeLast();
          }

          setState(() => ticks.addAll(fetchedTicks));
        } else {
          _resetCandlesTo(fetchedTicks);
        }

        _tickStreamSubscription =
            _tickHistorySubscription!.tickStream!.listen(_handleTickStream);
      } else {
        _tickHistorySubscription = null;

        final List<Tick> historyCandles = _getTicksFromResponse(
          await TicksHistoryResponse.fetchTickHistory(request),
        );

        _resetCandlesTo(historyCandles);
      }

      _updateSampleSLAndTP();

      WidgetsBinding.instance.addPostFrameCallback(
        (Duration timeStamp) => _controller.scrollToLastTick(),
      );
    } on BaseAPIException catch (e) {
      dev.log(e.message!, error: e);
    } finally {
      _completeRequest();
    }
  }

  void _resetCandlesTo(List<Tick> fetchedCandles) => setState(() {
        ticks = fetchedCandles;
      });

  void _completeRequest() {
    if (!_requestCompleter.isCompleted) {
      _requestCompleter.complete(null);
    }
  }

  void _handleTickStream(TickBase? newTick) {
    if (!_requestCompleter.isCompleted || newTick == null) {
      return;
    }

    if (newTick is tick_api.Tick) {
      _onNewTick(Tick(
        epoch: newTick.epoch!.millisecondsSinceEpoch,
        quote: newTick.quote!,
      ));
    } else if (newTick is OHLC) {
      _onNewCandle(Candle(
        epoch: newTick.openTime!.millisecondsSinceEpoch,
        high: newTick.high!,
        low: newTick.low!,
        open: newTick.open!,
        close: newTick.close!,
        currentEpoch: newTick.epoch!.millisecondsSinceEpoch,
      ));
    }
  }

  void _onNewTick(Tick newTick) {
    _removeExpiredMarkers(newTick.epoch);
    setState(() => ticks = ticks + <Tick>[newTick]);
  }

  void _onNewCandle(Candle newCandle) {
    _removeExpiredMarkers(newCandle.currentEpoch);
    final List<Candle> previousCandles =
        ticks.isNotEmpty && ticks.last.epoch == newCandle.epoch
            ? ticks.sublist(0, ticks.length - 1) as List<Candle>
            : ticks as List<Candle>;

    setState(() {
      // Don't modify candles in place, otherwise Chart's didUpdateWidget won't
      // see the difference.
      ticks = previousCandles + <Candle>[newCandle];
    });
  }

  /// Removes markers that have exceeded their duration
  void _removeExpiredMarkers(int currentEpoch) {
    bool clearedActiveGroup = false;
    _markers.removeWhere((Marker marker) {
      final int endEpoch = marker.epoch + _markerDurationMs;
      // Keep the marker around long enough to display PnL label window:
      // 1s delay before showing + 4s visibility = 5s after end.
      final bool isExpired =
          currentEpoch >= endEpoch + 1000 + _pnlLabelLifetimeMs;
      // Contract end moment
      final bool hasContractEnded = currentEpoch >= endEpoch + 1000;
      if (isExpired && _activeMarker?.epoch == marker.epoch) {
        _activeMarker = null;
      }
      // Clear active group as soon as contract ends, and also if fully expired
      if ((hasContractEnded || isExpired) &&
          _activeMarkerGroup?.id == 'marker_${marker.epoch}') {
        clearedActiveGroup = true;
      }
      return isExpired;
    });
    if (clearedActiveGroup) {
      setState(() {
        _activeMarkerGroup = null;
      });
    }
  }

  DataSeries<Tick> _getDataSeries(ChartStyle style) {
    if (ticks is List<Candle> && style != ChartStyle.line) {
      switch (style) {
        case ChartStyle.hollow:
          return HollowCandleSeries(ticks as List<Candle>);
        case ChartStyle.ohlc:
          return OhlcCandleSeries(ticks as List<Candle>);
        default:
          return CandleSeries(ticks as List<Candle>);
      }
    }
    return LineSeries(
      ticks,
    ) as DataSeries<Tick>;
  }

  @override
  Widget build(BuildContext context) => Material(
        color: DarkThemeColors.backgroundDynamicHighest,
        child: Column(
          children: <Widget>[
            _TopControls(
              marketButton: _buildMarketSelectorButton(),
              chartTypeButton: _buildChartTypeButton(),
              intervalSelector: _buildIntervalSelector(),
            ),
            Expanded(
              child: _ChartSection(
                interactiveLayerBehaviour: _interactiveLayerBehaviour,
                mainSeries: _getDataSeries(style),
                markerSeries: _getMarkerSeries(),
                activeSymbol: _symbol.name,
                annotations: _buildAnnotations(),
                pipSize: (_tickHistorySubscription?.tickHistory?.pipSize ?? 4)
                    .toInt(),
                granularityMs: granularity == 0 ? 1000 : granularity * 1000,
                controller: _controller,
                isLive: (_symbol.isOpen) &&
                    (_connectionBloc.state
                        is connection_bloc.ConnectionConnectedState),
                opacity: _symbol.isOpen ? 1.0 : 0.5,
                onVisibleAreaChanged: (int leftEpoch, int rightEpoch) {
                  if (!_waitingForHistory &&
                      ticks.isNotEmpty &&
                      leftEpoch < ticks.first.epoch) {
                    _loadHistory(500);
                  }
                },
                isConnected: _connectionBloc.state
                    is connection_bloc.ConnectionConnectedState,
                connectionStatus: _buildConnectionStatus(),
                interactiveLayerController: _interactiveLayerController,
              ),
            ),
            _ActionButtonsRow(
              onSettingsPressed: () => _onSettingsPressed(context),
              upLabel: _getUpButtonText(),
              downLabel: _getDownButtonText(),
              onUp: () => _addMarker(MarkerDirection.up),
              onDown: () => _addMarker(MarkerDirection.down),
              onClearMarkers: () => setState(_clearMarkers),
            ),
            _BarriersControlsRow(
              onAddVerticalBarrier: () => setState(
                () => _sampleBarriers.add(
                  VerticalBarrier.onTick(
                    ticks.last,
                    title: 'V Barrier',
                    id: 'VBarrier${_sampleBarriers.length}',
                    longLine: math.Random().nextBool(),
                    style: VerticalBarrierStyle(
                      isDashed: math.Random().nextBool(),
                    ),
                  ),
                ),
              ),
              onAddHorizontalBarrier: () => setState(
                () => _sampleBarriers.add(
                  HorizontalBarrier(
                    ticks.last.quote,
                    epoch: math.Random().nextBool() ? ticks.last.epoch : null,
                    id: 'HBarrier${_sampleBarriers.length}',
                    longLine: math.Random().nextBool(),
                    visibility: HorizontalBarrierVisibility.normal,
                    style: HorizontalBarrierStyle(
                      color: Colors.grey,
                      isDashed: math.Random().nextBool(),
                    ),
                  ),
                ),
              ),
              onAddCombinedBarrier: () => setState(
                () => _sampleBarriers.add(
                  CombinedBarrier(
                    ticks.last,
                    title: 'B Barrier',
                    id: 'CBarrier${_sampleBarriers.length}',
                    horizontalBarrierStyle: const HorizontalBarrierStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              onClearBarriers: () => setState(_clearBarriers),
            ),
            _SlTpCheckboxesRow(
              sl: _sl,
              tp: _tp,
              onSlChanged: (bool? value) => setState(() => _sl = value!),
              onTpChanged: (bool? value) => setState(() => _tp = value!),
            ),
          ],
        ),
      );

  List<ChartAnnotation<ChartObject>>? _buildAnnotations() {
    if (ticks.length <= 4) {
      return null;
    }
    return <ChartAnnotation<ChartObject>>[
      ..._sampleBarriers,
      if (_sl && _slBarrier != null) _slBarrier as ChartAnnotation<ChartObject>,
      if (_tp && _tpBarrier != null) _tpBarrier as ChartAnnotation<ChartObject>,
      TickIndicator(
        ticks.last,
        style: const HorizontalBarrierStyle(
          color: DarkThemeColors.currentSpotDotColor,
          labelShape: LabelShape.pentagon,
          hasBlinkingDot: true,
          hasArrow: false,
          lineColor: DarkThemeColors.currentSpotLineColor,
          isDashed: false,
          labelShapeBackgroundColor: DarkThemeColors.currentSpotContainerColor,
          textStyle: TextStyle(
            color: DarkThemeColors.currentSpotTextColor,
            fontSize: 10,
          ),
        ),
        visibility: HorizontalBarrierVisibility.keepBarrierLabelVisible,
      ),
    ];
  }

  Future<void> _onSettingsPressed(BuildContext context) async {
    final bool? settingChanged = await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => PrefService(
          child: SettingsPage(),
          service: _prefService,
        ),
      ),
    );

    await _loadTradeType();

    if (settingChanged ?? false) {
      _requestCompleter = Completer<dynamic>();
      await _tickStreamSubscription?.cancel();
      ticks.clear();
      await _connectionBloc.reconnect(
        connectionInformation: await _getConnectionInfoFromPrefs(),
      );
    }
  }

  void _addMarker(MarkerDirection direction) {
    final Tick lastTick = ticks.last;
    void onTap() {
      setState(() {
        _activeMarker = ActiveMarker(
          direction: direction,
          epoch: lastTick.epoch,
          quote: lastTick.quote,
          text: '0.00 USD',
          onTap: () {
            debugPrint('>>> tapped active marker');
          },
          onTapOutside: () {
            setState(() {
              _activeMarker = null;
            });
          },
        );
      });
    }

    setState(() {
      _markers.add(Marker(
        direction: direction,
        epoch: lastTick.epoch,
        quote: lastTick.quote,
        onTap: onTap,
      ));
    });
  }

  void _clearMarkers() {
    _markers.clear();
    _activeMarker = null;
    _activeMarkerGroup = null;
  }

  void _clearBarriers() {
    _sampleBarriers.clear();
    _sl = false;
    _tp = false;
  }

  Widget _buildConnectionStatus() => ConnectionStatusLabel(
        text: _connectionBloc.state is connection_bloc.ConnectionErrorState
            // ignore: lines_longer_than_80_chars
            ? '${(_connectionBloc.state as connection_bloc.ConnectionErrorState).error}'
            : _connectionBloc.state
                    is connection_bloc.ConnectionDisconnectedState
                ? 'Connection lost, trying to reconnect...'
                : 'Connecting...',
      );

  Widget _buildMarketSelectorButton() => MarketSelectorButton(
        asset: _symbol,
        onTap: () {
          _bottomSheetController = showBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            builder: (BuildContext context) => MarketSelector(
              selectedItem: _symbol,
              markets: _markets,
              onAssetClicked: (
                  {required Asset asset, required bool favouriteClicked}) {
                if (!favouriteClicked) {
                  Navigator.of(context).pop();
                  _symbol = asset;
                  _onIntervalSelected(granularity);
                }
              },
            ),
          );
        },
      );

  Future<void> _loadHistory(int count) async {
    _waitingForHistory = true;

    final TicksHistoryResponse moreData =
        await TicksHistoryResponse.fetchTickHistory(
      TicksHistoryRequest(
        ticksHistory: _symbol.name,
        end: '${ticks.first.epoch ~/ 1000}',
        count: count,
        style: granularity == 0 ? 'ticks' : 'candles',
        granularity: granularity > 0 ? granularity : null,
      ),
    );

    final List<Tick> loadedCandles = _getTicksFromResponse(moreData);

    // Ensure we don't have two candles with the same epoch.
    while (loadedCandles.isNotEmpty &&
        loadedCandles.last.epoch >= ticks.first.epoch) {
      loadedCandles.removeLast();
    }

    setState(() {
      ticks.insertAll(0, loadedCandles);
    });

    _waitingForHistory = false;
  }

  IconButton _buildChartTypeButton() => IconButton(
        icon: Icon(
          style == ChartStyle.line
              ? Icons.show_chart
              : style == ChartStyle.candles
                  ? Icons.insert_chart
                  : style == ChartStyle.hollow
                      ? Icons.insert_chart_outlined_outlined
                      : Icons.add_chart,
          color: Colors.white,
        ),
        onPressed: () {
          setState(() {
            switch (style) {
              case ChartStyle.ohlc:
                style = ChartStyle.line;
                return;
              case ChartStyle.line:
                style = ChartStyle.candles;
                return;
              case ChartStyle.candles:
                style = ChartStyle.hollow;
                return;
              default:
                style = ChartStyle.ohlc;
                return;
            }
          });
        },
      );

  Widget _buildIntervalSelector() => Theme(
        data: ThemeData.dark(),
        child: DropdownButton<int>(
          value: granularity,
          items: <int>[
            0,
            60,
            120,
            180,
            300,
            600,
            900,
            1800,
            3600,
            7200,
            14400,
            28800,
            86400,
          ]
              .map<DropdownMenuItem<int>>(
                  (int granularity) => DropdownMenuItem<int>(
                        value: granularity,
                        child: Text('${getGranularityLabel(granularity)}'),
                      ))
              .toList(),
          onChanged: _onIntervalSelected,
        ),
      );

  Future<void> _onIntervalSelected(int? value) async {
    if (!_requestCompleter.isCompleted) {
      return;
    }

    _requestCompleter = Completer<dynamic>();

    setState(() {
      ticks.clear();
      _clearMarkers();
      _clearBarriers();
    });

    try {
      await _tickHistorySubscription?.unsubscribe();
    } on Exception catch (e) {
      _completeRequest();
      dev.log(e.toString(), error: e);
    } finally {
      granularity = value ?? 0;

      await _initTickStream(TicksHistoryRequest(
        ticksHistory: _symbol.name,
        adjustStartTime: 1,
        end: 'latest',
        count: 500,
        style: granularity == 0 ? 'ticks' : 'candles',
        granularity: granularity > 0 ? granularity : null,
      ));
    }
  }

  List<Tick> _getTicksFromResponse(TicksHistoryResponse tickHistory) {
    List<Tick> candles = <Tick>[];
    if (tickHistory.history != null) {
      final int count = tickHistory.history!.prices!.length;
      for (int i = 0; i < count; i++) {
        candles.add(Tick(
          epoch: tickHistory.history!.times![i].millisecondsSinceEpoch,
          quote: tickHistory.history!.prices![i],
        ));
      }
    }

    if (tickHistory.candles != null) {
      candles = tickHistory.candles!
          .where((CandlesItem? ohlc) => ohlc != null)
          .map<Candle>((CandlesItem? ohlc) => Candle(
                epoch: ohlc!.epoch!.millisecondsSinceEpoch,
                high: ohlc.high!,
                low: ohlc.low!,
                open: ohlc.open!,
                close: ohlc.close!,
                currentEpoch: ohlc.epoch!.millisecondsSinceEpoch,
              ))
          .toList();
    }
    return candles;
  }

  void _updateSampleSLAndTP() {
    final double ticksMin = ticks.map((Tick t) => t.quote).reduce(math.min);
    final double ticksMax = ticks.map((Tick t) => t.quote).reduce(math.max);

    _slBarrier = HorizontalBarrier(
      ticksMin,
      title: 'Stop loss',
      style: const HorizontalBarrierStyle(
        color: Color(0xFFCC2E3D),
        isDashed: false,
      ),
      visibility: HorizontalBarrierVisibility.forceToStayOnRange,
    );

    _tpBarrier = HorizontalBarrier(
      ticksMax,
      title: 'Take profit',
      style: const HorizontalBarrierStyle(
        isDashed: false,
      ),
      visibility: HorizontalBarrierVisibility.forceToStayOnRange,
    );
  }

  Future<ConnectionInformation> _getConnectionInfoFromPrefs() async {
    // Get values directly from PrefService instead of SharedPreferences
    final String? endpoint = _prefService.get<String>('endpoint');
    final String? appId = _prefService.get<String>('appID');

    return ConnectionInformation(
      appId: appId ?? defaultAppID,
      brand: 'deriv',
      endpoint: endpoint != null
          ? generateEndpointUrl(endpoint: endpoint)
          : defaultEndpoint,
      authEndpoint: '',
    );
  }

  String _getUpButtonText() {
    switch (_currentTradeType) {
      case TradeType.multipliers:
        return 'Up';
      case TradeType.riseFall:
        return 'Rise';
    }
  }

  String _getDownButtonText() {
    switch (_currentTradeType) {
      case TradeType.multipliers:
        return 'Down';
      case TradeType.riseFall:
        return 'Fall';
    }
  }

  /// Converts markers to marker groups for rise/fall trade type
  List<MarkerGroup> _convertMarkersToGroups(int currentEpoch) {
    return _markers.map((Marker marker) {
      final int endEpoch = marker.epoch + _markerDurationMs;

      final List<ChartMarker> chartMarkers = <ChartMarker>[];

      // Show the standard markers until a short time after end
      final bool showStandardMarkers = currentEpoch < endEpoch + 500;
      if (showStandardMarkers) {
        chartMarkers.addAll(<ChartMarker>[
          ChartMarker(
            epoch: marker.epoch,
            quote: marker.quote,
            direction: marker.direction,
            markerType: MarkerType.entryTick,
          ),
          ChartMarker(
            epoch: endEpoch,
            quote: marker.quote,
            direction: marker.direction,
            markerType: MarkerType.end,
          ),
          ChartMarker(
            epoch: marker.epoch,
            quote: marker.quote,
            direction: marker.direction,
            markerType: MarkerType.contractMarker,
            onTap: () {
              setState(() {
                _activeMarker = null;
                _activeMarkerGroup = ActiveMarkerGroup(
                  markers: chartMarkers,
                  type: 'tick',
                  id: 'marker_${marker.epoch}',
                  currentEpoch: currentEpoch,
                  profitAndLossText: '+9.55 USD',
                  onTap: marker.onTap,
                  onTapOutside: () {
                    setState(() => _activeMarkerGroup = null);
                  },
                );
              });
            },
          ),
        ]);
      }

      // Show PnL label starting 1s after end, and hide after 4s have passed.
      if (currentEpoch >= endEpoch + 1000 &&
          currentEpoch < endEpoch + 1000 + _pnlLabelLifetimeMs) {
        chartMarkers.add(
          ChartMarker(
            epoch: endEpoch,
            quote: marker.quote,
            direction: marker.direction,
            markerType: MarkerType.profitAndLossLabel,
          ),
        );
      }

      return MarkerGroup(
        chartMarkers,
        type: 'tick',
        id: 'marker_${marker.epoch}',
        currentEpoch: currentEpoch,
        profitAndLossText: '+9.55 USD',
      );
    }).toList();
  }

  /// Gets the appropriate marker series based on trade type
  dynamic _getMarkerSeries() {
    if (_currentTradeType == TradeType.riseFall) {
      // Get the current epoch from the latest tick
      final int currentEpoch = ticks.isNotEmpty
          ? ticks.last.epoch
          : DateTime.now().millisecondsSinceEpoch;

      return MarkerGroupSeries(
        SplayTreeSet<Marker>(),
        markerGroupIconPainter: TickMarkerIconPainter(),
        markerGroupList: _convertMarkersToGroups(currentEpoch),
        activeMarkerGroup: _activeMarkerGroup,
      );
    } else {
      return MarkerSeries(
        _markers,
        activeMarker: _activeMarker,
        markerIconPainter: MultipliersMarkerIconPainter(),
      );
    }
  }
}

class _TopControls extends StatelessWidget {
  const _TopControls({
    required this.marketButton,
    required this.chartTypeButton,
    required this.intervalSelector,
  });

  final Widget marketButton;
  final Widget chartTypeButton;
  final Widget intervalSelector;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          Expanded(child: marketButton),
          chartTypeButton,
          intervalSelector,
        ],
      ),
    );
  }
}

class _ChartSection extends StatelessWidget {
  const _ChartSection({
    required this.interactiveLayerBehaviour,
    required this.mainSeries,
    required this.markerSeries,
    required this.activeSymbol,
    required this.annotations,
    required this.pipSize,
    required this.granularityMs,
    required this.controller,
    required this.isLive,
    required this.opacity,
    required this.onVisibleAreaChanged,
    required this.isConnected,
    required this.connectionStatus,
    required this.interactiveLayerController,
  });

  final InteractiveLayerBehaviour interactiveLayerBehaviour;
  final DataSeries<Tick> mainSeries;
  final dynamic markerSeries;
  final String activeSymbol;
  final List<ChartAnnotation<ChartObject>>? annotations;
  final int pipSize;
  final int granularityMs;
  final ChartController controller;
  final bool isLive;
  final double opacity;
  final void Function(int leftEpoch, int rightEpoch) onVisibleAreaChanged;
  final bool isConnected;
  final Widget connectionStatus;
  final InteractiveLayerController interactiveLayerController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ClipRect(
          child: DerivChart(
            useDrawingToolsV2: true,
            interactiveLayerBehaviour: interactiveLayerBehaviour,
            mainSeries: mainSeries,
            markerSeries: markerSeries,
            activeSymbol: activeSymbol,
            annotations: annotations,
            pipSize: pipSize,
            granularity: granularityMs,
            controller: controller,
            isLive: isLive,
            opacity: opacity,
            onVisibleAreaChanged: onVisibleAreaChanged,
          ),
        ),
        if (!isConnected)
          Align(
            child: connectionStatus,
          ),
        Container(
          alignment: Alignment.topRight,
          padding: const EdgeInsets.all(16),
          child: ListenableBuilder(
            listenable: interactiveLayerController,
            builder: (_, __) {
              if (interactiveLayerController.currentState
                  is InteractiveAddingToolState) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('Cancel adding'),
                    IconButton(
                      onPressed: interactiveLayerController.cancelAdding,
                      icon: const Icon(Icons.cancel),
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }
}

class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow({
    required this.onSettingsPressed,
    required this.upLabel,
    required this.downLabel,
    required this.onUp,
    required this.onDown,
    required this.onClearMarkers,
  });

  final VoidCallback onSettingsPressed;
  final String upLabel;
  final String downLabel;
  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onClearMarkers;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: onSettingsPressed,
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) => const Color(0xFF00C390),
              ),
              foregroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) => Colors.white,
              ),
            ),
            child: Text(upLabel),
            onPressed: onUp,
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) => const Color(0xFFDE0040),
              ),
              foregroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) => Colors.white,
              ),
            ),
            child: Text(downLabel),
            onPressed: onDown,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onClearMarkers,
          ),
        ],
      ),
    );
  }
}

class _BarriersControlsRow extends StatelessWidget {
  const _BarriersControlsRow({
    required this.onAddVerticalBarrier,
    required this.onAddHorizontalBarrier,
    required this.onAddCombinedBarrier,
    required this.onClearBarriers,
  });

  final VoidCallback onAddVerticalBarrier;
  final VoidCallback onAddHorizontalBarrier;
  final VoidCallback onAddCombinedBarrier;
  final VoidCallback onClearBarriers;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TextButton(
            child: const Text('V barrier'),
            onPressed: onAddVerticalBarrier,
          ),
          TextButton(
            child: const Text('H barrier'),
            onPressed: onAddHorizontalBarrier,
          ),
          TextButton(
            child: const Text('+ Both'),
            onPressed: onAddCombinedBarrier,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onClearBarriers,
          ),
        ],
      ),
    );
  }
}

class _SlTpCheckboxesRow extends StatelessWidget {
  const _SlTpCheckboxesRow({
    required this.sl,
    required this.tp,
    required this.onSlChanged,
    required this.onTpChanged,
  });

  final bool sl;
  final bool tp;
  final ValueChanged<bool?> onSlChanged;
  final ValueChanged<bool?> onTpChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        children: <Widget>[
          Expanded(
            child: CheckboxListTile(
              value: sl,
              onChanged: onSlChanged,
              title: const Text('Stop loss'),
            ),
          ),
          Expanded(
            child: CheckboxListTile(
              value: tp,
              onChanged: onTpChanged,
              title: const Text('Take profit'),
            ),
          ),
        ],
      ),
    );
  }
}
