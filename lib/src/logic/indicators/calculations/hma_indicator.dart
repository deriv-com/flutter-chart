import '../indicator.dart';
import 'cached_indicator.dart';
import 'wma_indicator.dart';

/// Hull Moving Average
class HMAIndicator extends CachedIndicator {

  final int barCount;

   WMAIndicator sqrtWma;

  HMAIndicator(Indicator indicator, this.barCount) : super.fromIndicator(indicator){

    WMAIndicator halfWma = new WMAIndicator(indicator, barCount / 2);
    WMAIndicator origWma = new WMAIndicator(indicator, barCount);

    Indicator indicatorForSqrtWma = new DifferenceIndicator(new MultiplierIndicator(halfWma, 2), origWma);
    sqrtWma = new WMAIndicator(indicatorForSqrtWma, numOf(barCount).sqrt().intValue());
  }

  @Override
  protected Num calculate(int index) {
    return sqrtWma.getValue(index);
  }

  @Override
  public String toString() {
    return getClass().getSimpleName() + " barCount: " + barCount;
  }

}