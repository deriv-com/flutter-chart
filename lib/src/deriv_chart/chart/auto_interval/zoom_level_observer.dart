/// Interface for components that need to observe zoom level changes
abstract class ZoomLevelObserver {
  /// Called when zoom level changes
  void onZoomLevelChanged(double msPerPx, int currentGranularity);
}
