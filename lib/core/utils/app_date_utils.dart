import 'package:intl/intl.dart';

extension DateTimeFormatExt on DateTime {
  String toDisplayDateTime() => DateFormat('dd.MM.yyyy HH:mm', 'tr_TR').format(toLocal());
  String toDisplayDate() => DateFormat('dd.MM.yyyy', 'tr_TR').format(toLocal());
  String toDisplayTime() => DateFormat('HH:mm:ss', 'tr_TR').format(toLocal());
  String toIso() => toUtc().toIso8601String();
}

extension StringBarkodExt on String {
  bool get isKutuBarkod => startsWith('KT-') || startsWith('BOX-');
  bool get isCuvalBarkod => startsWith('CV-') || startsWith('SAC-');
  String get sanitized => trim().toUpperCase();
}
