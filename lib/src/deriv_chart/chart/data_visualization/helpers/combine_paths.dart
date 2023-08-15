import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/helpers/find_intersection.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

/// Combines and intersects two paths to generate upper and lower paths.
///
/// Given two paths, this function intersects them to find the common portion
/// and splits the paths into an upper path and a lower path.
(Path, Path) combinePaths(
  DataSeries<Tick> firstSeries,
  List<Tick> firstSeriesEntries,
  List<Tick> secondSeriesEntries,
  EpochToX epochToX,
  QuoteToY quoteToY,
) {
  final Path upperPath = Path();
  final Path lowerPath = Path();

  Offset convertTickToPoint(Tick tick, int i) =>
      Offset(epochToX(firstSeries.getEpochOf(tick, i)), quoteToY(tick.quote));

  void addPoint(List<Offset> pointsList, Tick tick, int i) {
    pointsList.add(convertTickToPoint(tick, i));
  }

  void addPath(Path path, {bool isTopBand = true}) {
    if (isTopBand) {
      upperPath.addPath(path, Offset.zero);
    } else {
      lowerPath.addPath(path, Offset.zero);
    }
  }

  List<Offset> topPoints = <Offset>[];
  List<Offset> bottomPoints = <Offset>[];

  bool isTopBand = false, isBottomBand = false;

  final int startIndex = firstSeries.visibleEntries.startIndex;
  final int endIndex = firstSeries.visibleEntries.endIndex;

  for (int i = startIndex; i <= endIndex - 1; i++) {
    final Tick firstSeriesTick = firstSeriesEntries[i];
    final Tick secondSeriesTick = secondSeriesEntries[i];

    final bool newRegion =
        (isTopBand && firstSeriesTick.quote < secondSeriesTick.quote) ||
            (isBottomBand && firstSeriesTick.quote > secondSeriesTick.quote);

    if (newRegion) {
      // Find intersection point and create a wrap and add point to topband.
      final Tick? firstSeriesPreviousTick = firstSeriesEntries[i - 1];
      final Tick? secondSeriesPreviousTick = secondSeriesEntries[i - 1];
      Offset? intersecion;

      if (firstSeriesPreviousTick != null && secondSeriesPreviousTick != null) {
        intersecion = findIntersection(
          convertTickToPoint(firstSeriesTick, i),
          convertTickToPoint(firstSeriesPreviousTick, i - 1),
          convertTickToPoint(secondSeriesTick, i),
          convertTickToPoint(secondSeriesPreviousTick, i - 1),
        );

        if (intersecion != null) {
          topPoints.add(intersecion);
        }
      }

      addPath(_createPath(topPoints, bottomPoints), isTopBand: isTopBand);

      topPoints = intersecion != null ? <Offset>[intersecion] : <Offset>[];
      bottomPoints = <Offset>[];
      isTopBand = isBottomBand = false;
    } else if (firstSeriesTick.quote == secondSeriesTick.quote) {
      addPoint(topPoints, firstSeriesTick, i);
      // Create a wrap and and point to topBand.
      addPath(_createPath(topPoints, bottomPoints), isTopBand: isTopBand);
      topPoints = <Offset>[];
      bottomPoints = <Offset>[];
      isTopBand = isBottomBand = false;
    }

    if (firstSeriesTick.quote > secondSeriesTick.quote) {
      addPoint(topPoints, firstSeriesTick, i);
      addPoint(bottomPoints, secondSeriesTick, i);
      isTopBand = true;
    } else if (firstSeriesTick.quote < secondSeriesTick.quote) {
      addPoint(topPoints, secondSeriesTick, i);
      addPoint(bottomPoints, firstSeriesTick, i);
      isBottomBand = true;
    }
  }

  addPath(_createPath(topPoints, bottomPoints), isTopBand: isTopBand);

  return (upperPath, lowerPath);
}

Path _createPath(List<Offset> topPoints, List<Offset> bottomPoints) {
  final Path path = Path();
  final List<Offset> allPoints = List<Offset>.from(topPoints)
    ..addAll(bottomPoints.reversed)
    ..add(topPoints[0]);

  for (int i = 0; i < allPoints.length; i++) {
    final Offset point = allPoints[i];

    if (i == 0) {
      path.moveTo(point.dx, point.dy);
      continue;
    }

    path.lineTo(point.dx, point.dy);
  }

  return path;
}
