import 'package:money_milestone/utils/currencies.dart';

/// Singleton that caches the currently selected currency symbol.
/// Updated by [CurrencyCubit]; read by the `.currency()` string extension
/// so no BuildContext is needed at call sites.
class CurrencyService {
  CurrencyService._();
  static final CurrencyService _instance = CurrencyService._();
  static CurrencyService get instance => _instance;

  /// Default: US Dollar
  CurrencyData _current =
      const CurrencyData(code: 'USD', name: 'US Dollar', symbol: '\$');

  CurrencyData get current => _current;
  String get symbol => _current.symbol;

  void update(CurrencyData data) => _current = data;
}
