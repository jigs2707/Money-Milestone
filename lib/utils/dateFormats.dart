/// The display date formats a user can choose from in Profile → Date Format.
///
/// This is a *display* concern only. Dates are always stored as `yyyy-MM-dd`
/// (see [storageDateFormat]) so the database contract never changes with the
/// user's preference.
class DateFormatOption {
  final String pattern; // intl DateFormat pattern
  final String label; // what the picker shows

  const DateFormatOption({required this.pattern, required this.label});
}

/// The on-disk / database format. Never user-configurable.
const String storageDateFormat = 'yyyy-MM-dd';

const DateFormatOption defaultDateFormat =
    DateFormatOption(pattern: 'dd/MM/yyyy', label: 'DD/MM/YYYY');

const List<DateFormatOption> allDateFormats = [
  defaultDateFormat,
  DateFormatOption(pattern: 'MM/dd/yyyy', label: 'MM/DD/YYYY'),
  DateFormatOption(pattern: 'yyyy-MM-dd', label: 'YYYY-MM-DD'),
  DateFormatOption(pattern: 'dd MMM yyyy', label: 'DD MMM YYYY'),
  DateFormatOption(pattern: 'MMM d, yyyy', label: 'MMM D, YYYY'),
  DateFormatOption(pattern: 'd MMMM yyyy', label: 'D MMMM YYYY'),
];

DateFormatOption dateFormatByPattern(String pattern) =>
    allDateFormats.firstWhere((f) => f.pattern == pattern,
        orElse: () => defaultDateFormat);
