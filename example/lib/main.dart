import 'dart:async';
import 'dart:collection';
import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:deriv_chart/deriv_chart.dart';
import 'package:example/generated/l10n.dart';
import 'package:example/settings_page.dart';
import 'package:example/utils/endpoints_helper.dart';
import 'package:example/utils/market_change_reminder.dart';
import 'package:example/widgets/connection_status_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deriv_api/api/exceptions/exceptions.dart';
import 'package:flutter_deriv_api/api/manually/ohlc_response_result.dart';
import 'package:flutter_deriv_api/api/manually/tick.dart' as tick_api;
import 'package:flutter_deriv_api/api/manually/tick_base.dart';
import 'package:flutter_deriv_api/api/manually/tick_history_subscription.dart';
import 'package:flutter_deriv_api/api/response/active_symbols_response_result.dart';
import 'package:flutter_deriv_api/api/response/ticks_history_response_result.dart';
import 'package:flutter_deriv_api/api/response/trading_times_response_result.dart';
import 'package:flutter_deriv_api/basic_api/generated/api.dart';
import 'package:flutter_deriv_api/services/connection/api_manager/connection_information.dart';
import 'package:flutter_deriv_api/state/connection/connection_cubit.dart'
    as connection_bloc;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pref/pref.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import 'utils/misc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

  MarketChangeReminder? _marketsChangeReminder;

  // Is used to make sure we make only one request to the API at a time.
  // We will not make a new call until the prev call has completed.
  late Completer<dynamic> _requestCompleter;

  List<Market> _markets = <Market>[];
  final SplayTreeSet<Marker> _markers = SplayTreeSet<Marker>();

  ActiveMarker? _activeMarker;

  late List<ActiveSymbolsItem> _activeSymbols;

  Asset _symbol = Asset(name: 'R_50');

  final ChartController _controller = ChartController();
  PersistentBottomSheetController? _bottomSheetController;

  late PrefServiceCache _prefService;

  @override
  void initState() {
    super.initState();
    _requestCompleter = Completer<dynamic>();
    _connectToAPI();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefService = PrefServiceCache();
    await _prefService.setDefaultValues(<String, dynamic>{
      'appID': defaultAppID,
      'endpoint': defaultEndpoint,
    });
  }

  @override
  void dispose() {
    _tickStreamSubscription?.cancel();
    _connectionBloc.close();
    _bottomSheetController?.close();
    super.dispose();
  }

  Future<void> _connectToAPI() async {
    _connectionBloc = connection_bloc.ConnectionCubit(ConnectionInformation(
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

        await _setupMarketChangeReminder();
      });
  }

  Future<void> _setupMarketChangeReminder() async {
    _marketsChangeReminder?.reset();
    _marketsChangeReminder = MarketChangeReminder(
      () async => (await TradingTimesResponse.fetchTradingTimes(
        const TradingTimesRequest(tradingTimes: 'today'),
      ))
          .tradingTimes!,
      onMarketsStatusChange: (Map<String?, bool>? statusChanges) {
        if (statusChanges == null) {
          return;
        }

        for (int i = 0; i < _activeSymbols.length; i++) {
          if (statusChanges[_activeSymbols[i].symbol] != null) {
            _activeSymbols[i] = _activeSymbols[i].copyWith(
              exchangeIsOpen: statusChanges[_activeSymbols[i].symbol],
            );
          }
        }

        _fillMarketSelectorList();

        if (statusChanges[_symbol.name] != null) {
          _symbol = _symbol.copyWith(isOpen: statusChanges[_symbol.name]);

          // Request for tick stream if symbol is changing from closed to open.
          if (statusChanges[_symbol.name]!) {
            _onIntervalSelected(granularity);
          }
        }
      },
    );
  }

  Future<void> _getActiveSymbols() async {
    _activeSymbols = (await ActiveSymbolsResponse.fetchActiveSymbols(
      const ActiveSymbolsRequest(
          activeSymbols: 'brief', productType: 'basic', landingCompany: null),
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
    setState(() => ticks = ticks + <Tick>[newTick]);
  }

  void _onNewCandle(Candle newCandle) {
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
    return LineSeries(ticks, style: const LineStyle(hasArea: true))
        as DataSeries<Tick>;
  }

  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFF0E0E0E),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _markets == null
                        ? const SizedBox.shrink()
                        : _buildMarketSelectorButton(),
                  ),
                  _buildChartTypeButton(),
                  _buildIntervalSelector(),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: <Widget>[
                  ClipRect(
                    child: DerivChart(
                      mainSeries: _getDataSeries(style),
                      markerSeries: MarkerSeries(
                        _markers,
                        activeMarker: _activeMarker,
                        markerIconPainter: MultipliersMarkerIconPainter(),
                      ),
                      activeSymbol: _symbol.name,
                      annotations: ticks.length > 4
                          ? <ChartAnnotation<ChartObject>>[
                              ..._sampleBarriers,
                              if (_sl && _slBarrier != null)
                                _slBarrier as ChartAnnotation<ChartObject>,
                              if (_tp && _tpBarrier != null)
                                _tpBarrier as ChartAnnotation<ChartObject>,
                              TickIndicator(
                                ticks.last,
                                style: const HorizontalBarrierStyle(
                                  color: Colors.redAccent,
                                  labelShape: LabelShape.pentagon,
                                  hasBlinkingDot: true,
                                  hasArrow: false,
                                ),
                                visibility: HorizontalBarrierVisibility
                                    .keepBarrierLabelVisible,
                              ),
                            ]
                          : null,
                      pipSize:
                          (_tickHistorySubscription?.tickHistory?.pipSize ?? 4)
                              .toInt(),
                      granularity: granularity == 0
                          ? 1000 // average ms difference between ticks
                          : granularity * 1000,
                      controller: _controller,
                      isLive: (_symbol.isOpen) &&
                          (_connectionBloc.state
                              is connection_bloc.ConnectionConnectedState),
                      opacity: _symbol.isOpen ? 1.0 : 0.5,
                      onCrosshairAppeared: () =>
                          Vibration.vibrate(duration: 50),
                      onVisibleAreaChanged: (int leftEpoch, int rightEpoch) {
                        if (!_waitingForHistory &&
                            ticks.isNotEmpty &&
                            leftEpoch < ticks.first.epoch) {
                          _loadHistory(500);
                        }
                      },
                    ),
                  ),
                  // ignore: unnecessary_null_comparison
                  if (_connectionBloc != null &&
                      _connectionBloc.state
                          is! connection_bloc.ConnectionConnectedState)
                    Align(
                      child: _buildConnectionStatus(),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () async {
                        final bool? settingChanged =
                            await Navigator.of(context).push(
                          MaterialPageRoute<bool>(
                              builder: (_) => PrefService(
                                    child: SettingsPage(),
                                    service: _prefService,
                                  )),
                        );

                        if (settingChanged ?? false) {
                          _requestCompleter = Completer<dynamic>();
                          await _tickStreamSubscription?.cancel();
                          ticks.clear();
                          // reconnect to new config
                          await _connectionBloc.reconnect(
                            connectionInformation:
                                await _getConnectionInfoFromPrefs(),
                          );
                        }
                      }),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) => Colors.green),
                    ),
                    child: const Text('Up'),
                    onPressed: () => _addMarker(MarkerDirection.up),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) => Colors.red),
                    ),
                    child: const Text('Down'),
                    onPressed: () => _addMarker(MarkerDirection.down),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => setState(_clearMarkers),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  TextButton(
                    child: const Text('V barrier'),
                    onPressed: () => setState(
                      () => _sampleBarriers.add(
                        VerticalBarrier.onTick(ticks.last,
                            title: 'V Barrier',
                            id: 'VBarrier${_sampleBarriers.length}',
                            longLine: math.Random().nextBool(),
                            style: VerticalBarrierStyle(
                              isDashed: math.Random().nextBool(),
                            )),
                      ),
                    ),
                  ),
                  TextButton(
                    child: const Text('H barrier'),
                    onPressed: () => setState(
                      () => _sampleBarriers.add(
                        HorizontalBarrier(
                          ticks.last.quote,
                          epoch: math.Random().nextBool()
                              ? ticks.last.epoch
                              : null,
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
                  ),
                  TextButton(
                    child: const Text('+ Both'),
                    onPressed: () => setState(() => _sampleBarriers.add(
                          CombinedBarrier(
                            ticks.last,
                            title: 'B Barrier',
                            id: 'CBarrier${_sampleBarriers.length}',
                            horizontalBarrierStyle:
                                const HorizontalBarrierStyle(
                              color: Colors.grey,
                            ),
                          ),
                        )),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => setState(() {
                      _clearBarriers();
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 64,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: CheckboxListTile(
                      value: _sl,
                      onChanged: (bool? sl) => setState(() => _sl = sl!),
                      title: const Text('Stop loss'),
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      value: _tp,
                      onChanged: (bool? tp) => setState(() => _tp = tp!),
                      title: const Text('Take profit'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );

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
          Vibration.vibrate(duration: 50);
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
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? endpoint = preferences.getString('endpoint');

    return ConnectionInformation(
      appId: preferences.getString('appID') ?? defaultAppID,
      brand: 'deriv',
      endpoint: endpoint != null
          ? generateEndpointUrl(endpoint: endpoint)
          : defaultEndpoint,
      authEndpoint: '',
    );
  }
}
