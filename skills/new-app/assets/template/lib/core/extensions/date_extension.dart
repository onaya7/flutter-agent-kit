import 'package:intl/intl.dart';

/// Relative-time rendering for ISO-8601 timestamp strings.
extension DateStringX on String {
  /// Parses an ISO-8601 timestamp, or `null` when this isn't one.
  DateTime? get asDateTime => DateTime.tryParse(this);

  /// Falls back to the raw string when this isn't a parseable timestamp.
  String get timeAgo => asDateTime?.timeAgo ?? this;

  /// Falls back to the raw string when this isn't a parseable timestamp.
  String get timeUntil => asDateTime?.timeUntil ?? this;
}

extension DateTimeAgoX on DateTime {
  /// Older than a week, or in the future, renders as an absolute date.
  String get timeAgo {
    final elapsed = DateTime.now().difference(this);
    if (elapsed.isNegative) return DateFormat('d MMM y').format(this);

    final minutes = elapsed.inMinutes;
    if (minutes < 1) return 'just now';
    if (minutes < 60) return '$minutes ${_plural(minutes, 'minute')} ago';

    final hours = elapsed.inHours;
    if (hours < 24) return '$hours ${_plural(hours, 'hour')} ago';

    final days = elapsed.inDays;
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';

    return DateFormat('d MMM y').format(this);
  }

  /// Counts whole calendar days; past or over a month out goes absolute.
  String get timeUntil {
    final now = DateTime.now();
    final days = DateTime(
      year,
      month,
      day,
    ).difference(DateTime(now.year, now.month, now.day)).inDays;

    if (days < 0 || days > 30) return DateFormat('d MMM y').format(this);
    if (days == 0) return 'today';
    if (days == 1) return 'tomorrow';
    return 'in $days days';
  }
}

String _plural(int value, String unit) => value == 1 ? unit : '${unit}s';
