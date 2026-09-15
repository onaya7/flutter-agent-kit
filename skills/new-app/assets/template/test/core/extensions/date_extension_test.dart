import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/core/extensions/date_extension.dart';

void main() {
  group('DateTimeAgoX.timeAgo', () {
    DateTime ago(Duration d) => DateTime.now().subtract(d);

    test('renders sub-minute ages as "just now"', () {
      expect(ago(const Duration(seconds: 5)).timeAgo, 'just now');
    });

    test('singularises one minute and one hour', () {
      expect(ago(const Duration(minutes: 1)).timeAgo, '1 minute ago');
      expect(ago(const Duration(hours: 1)).timeAgo, '1 hour ago');
    });

    test('pluralises minutes and hours', () {
      expect(ago(const Duration(minutes: 3)).timeAgo, '3 minutes ago');
      expect(ago(const Duration(hours: 5)).timeAgo, '5 hours ago');
    });

    test('rolls over from minutes to hours at 60 minutes', () {
      expect(ago(const Duration(minutes: 59)).timeAgo, '59 minutes ago');
      expect(ago(const Duration(minutes: 60)).timeAgo, '1 hour ago');
    });

    test('names the previous day "Yesterday", then counts days', () {
      expect(ago(const Duration(hours: 24)).timeAgo, 'Yesterday');
      expect(ago(const Duration(days: 3)).timeAgo, '3 days ago');
      expect(ago(const Duration(days: 6)).timeAgo, '6 days ago');
    });

    test('falls back to an absolute date beyond a week', () {
      expect(DateTime(2026, 6, 12).timeAgo, '12 Jun 2026');
    });

    test('renders future timestamps as an absolute date', () {
      expect(DateTime(2099, 1, 2).timeAgo, '2 Jan 2099');
    });
  });

  group('DateTimeAgoX.timeUntil', () {
    // Noon-anchored so a test running near midnight can't slip a day.
    DateTime inDays(int days) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day + days, 12);
    }

    test('names today and tomorrow', () {
      expect(inDays(0).timeUntil, 'today');
      expect(inDays(1).timeUntil, 'tomorrow');
    });

    test('counts the days in between', () {
      expect(inDays(2).timeUntil, 'in 2 days');
      expect(inDays(29).timeUntil, 'in 29 days');
    });

    test('counts whole calendar days, not 24-hour spans', () {
      final now = DateTime.now();
      final justAfterMidnight = DateTime(
        now.year,
        now.month,
        now.day + 1,
        0,
        1,
      );
      expect(justAfterMidnight.timeUntil, 'tomorrow');
    });

    test('falls back to an absolute date beyond a month', () {
      expect(DateTime(2099, 1, 2).timeUntil, '2 Jan 2099');
    });

    test('falls back to an absolute date for a past date', () {
      expect(DateTime(2020, 3, 4).timeUntil, '4 Mar 2020');
    });
  });

  group('DateStringX', () {
    test('parses an ISO-8601 timestamp with microseconds', () {
      final parsed = '2026-07-28T15:34:30.814159'.asDateTime;
      expect(parsed, isNotNull);
      expect(parsed!.year, 2026);
      expect(parsed.month, 7);
      expect(parsed.day, 28);
    });

    test('returns null rather than throwing on a non-timestamp', () {
      expect('Tuesday, July 28, 2026'.asDateTime, isNull);
    });

    test('timeAgo passes a non-timestamp through untouched', () {
      expect('Tuesday, July 28, 2026'.timeAgo, 'Tuesday, July 28, 2026');
    });

    test('timeAgo formats a parseable timestamp', () {
      expect('2026-06-12T09:00:00.000'.timeAgo, '12 Jun 2026');
    });

    test('timeUntil passes a non-timestamp through untouched', () {
      expect('Tuesday, July 28, 2026'.timeUntil, 'Tuesday, July 28, 2026');
    });
  });
}
