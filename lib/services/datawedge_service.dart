import 'package:flutter/services.dart';

/// Zebra DataWedge entegrasyonu.
///
/// Gerçek Zebra cihazlarda barkodlar Intent broadcast üzerinden EventChannel'a gelir.
/// Zebra olmayan cihazlarda stream boş döner; [BarkodScanWidget] HID klavye
/// moduna otomatik geçer.
class DataWedgeService {
  DataWedgeService._(); // instantiate edilemesin

  static const MethodChannel _channel =
      MethodChannel('com.faurecia.rfgun/datawedge');

  static const EventChannel _eventChannel =
      EventChannel('com.faurecia.rfgun/barkod_stream');

  // Tekil broadcast stream — birden fazla listener olabilir
  static Stream<String>? _broadcastStream;

  /// DataWedge profili oluştur / etkinleştir.
  /// main() içinden bir kez çağrılmalı.
  static Future<void> initialize() async {
    try {
      await _channel.invokeMethod<void>('enableDataWedge', {'enable': true});
    } on MissingPluginException {
      // Kanal yok → Zebra cihaz değil, sorun değil
    } catch (_) {
      // Diğer hatalar da sessizce geç
    }
  }

  /// DataWedge barkod akışı.
  ///
  /// - Gerçek Zebra cihazda Intent üzerinden barkod string'i yayınlar.
  /// - Zebra olmayan cihazda boş stream döner (hata fırlatmaz).
  ///
  /// Stream bir kez oluşturulur ve broadcast olarak paylaşılır;
  /// her [listen] çağrısı yeni bir native stream açmaz.
  static Stream<String> get barkodStream {
    _broadcastStream ??= _eventChannel
        .receiveBroadcastStream()
        .where((event) => event != null)
        .map<String>((event) => event.toString().trim())
        .where((s) => s.isNotEmpty)
        // Hata olursa stream'i bitirmek yerine sadece o eventi atla
        .handleError((_) {})
        .asBroadcastStream();

    return _broadcastStream!;
  }

  /// DataWedge'i devre dışı bırak (ekrandan çıkınca çağrılabilir).
  static Future<void> disable() async {
    try {
      await _channel.invokeMethod<void>('enableDataWedge', {'enable': false});
    } on MissingPluginException {
      // Kanal yok → sessizce geç
    } catch (_) {}
  }
}

/// Barkod validasyon ve tip ayırt etme yardımcısı.
class BarkodService {
  BarkodService._();

  static bool isKutuBarkod(String barkod) {
    final b = normalize(barkod);
    return b.startsWith('KT-') ||
        b.startsWith('BOX-') ||
        RegExp(r'^K\d{4,}$').hasMatch(b);
  }

  static bool isCuvalBarkod(String barkod) {
    final b = normalize(barkod);
    return b.startsWith('CV-') ||
        b.startsWith('SAC-') ||
        RegExp(r'^C\d{4,}$').hasMatch(b);
  }

  static String normalize(String barkod) => barkod.trim().toUpperCase();

  static bool isValid(String barkod) {
    final b = normalize(barkod);
    return b.length >= 3 && (isKutuBarkod(b) || isCuvalBarkod(b));
  }
}