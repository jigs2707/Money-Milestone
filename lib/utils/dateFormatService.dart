import 'package:intl/intl.dart';
import 'package:money_milestone/utils/dateFormats.dart';

/// Singleton that caches the user's selected display date format.
/// Updated by [DateFormatCubit]; read directly at call sites so no
/// BuildContext is needed — mirrors [CurrencyService].
class DateFormatService {
  DateFormatService._();
  static final DateFormatService _instance = DateFormatService._();
  static DateFormatService get instance => _instance;

  DateFormatOption _current = defaultDateFormat;

  DateFormatOption get current => _current;
  String get pattern => _current.pattern;

  void update(DateFormatOption option) => _current = option;

  /// Formats a [DateTime] in the user's chosen display format.
  String format(DateTime date) => DateFormat(_current.pattern).format(date);

  /// Formats a date stored as `yyyy-MM-dd` (the database format).
  /// Returns an empty string for null/blank, and the raw value unchanged if it
  /// cannot be parsed — never throws, so a bad row can't break a screen.
  String formatStored(String? stored) {
    if (stored == null || stored.trim().isEmpty) return '';
    final parsed = DateTime.tryParse(stored.trim());
    return parsed == null ? stored : format(parsed);
  }

  /// Renders [date] in an arbitrary pattern — used by the picker to preview
  /// each option without mutating the current selection.
  static String preview(String pattern, DateTime date) =>
      DateFormat(pattern).format(date);
}
