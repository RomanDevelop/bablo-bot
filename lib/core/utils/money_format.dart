import 'package:intl/intl.dart';

class MoneyFormat {
  MoneyFormat._();

  static final _pct = NumberFormat('+0.00;-0.00');
  static final _pctPlain = NumberFormat('0.00');

  static String trim(String? raw, {int maxDecimals = 8}) {
    if (raw == null || raw.isEmpty) return '—';
    final value = double.tryParse(raw);
    if (value == null) return raw;
    if (value == 0) return '0';

    var s = value.toStringAsFixed(maxDecimals);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '');
      s = s.replaceFirst(RegExp(r'\.$'), '');
    }
    return s;
  }

  static String usd(String? raw, {int decimals = 2}) {
    if (raw == null || raw.isEmpty) return '—';
    final value = double.tryParse(raw);
    if (value == null) return raw;
    final formatted = NumberFormat('#,##0.${'0' * decimals}', 'en_US').format(value);
    return '\$$formatted';
  }

  static String signedUsd(String? raw, {int decimals = 2}) {
    if (raw == null || raw.isEmpty) return '—';
    final value = double.tryParse(raw);
    if (value == null) return raw;
    final abs = NumberFormat('#,##0.${'0' * decimals}', 'en_US').format(value.abs());
    if (value > 0) return '+\$$abs';
    if (value < 0) return '-\$$abs';
    return '\$$abs';
  }

  static String pct(String? raw, {bool signed = true}) {
    if (raw == null || raw.isEmpty) return '—';
    final value = double.tryParse(raw);
    if (value == null) return raw;
    final formatted = signed ? _pct.format(value) : _pctPlain.format(value);
    return '$formatted%';
  }

  static bool isPositive(String? raw) {
    final value = double.tryParse(raw ?? '');
    return value != null && value > 0;
  }

  static bool isNegative(String? raw) {
    final value = double.tryParse(raw ?? '');
    return value != null && value < 0;
  }

  static DateTime? parseUtc(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  static String dateTime(String? raw) {
    final dt = parseUtc(raw);
    if (dt == null) return '—';
    return DateFormat('dd MMM HH:mm', 'ru').format(dt);
  }

  static String dateTimeFull(String? raw) {
    final dt = parseUtc(raw);
    if (dt == null) return '—';
    return DateFormat('dd MMM yyyy, HH:mm', 'ru').format(dt);
  }
}
