import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:faurecia/core/theme/app_theme.dart';
import 'package:faurecia/services/datawedge_service.dart';

/// Zebra DataWedge veya HID klavye (RF gun) girişini destekleyen birleşik tarama widget'ı.
///
/// Öncelik sırası:
///   1. DataWedge Intent stream (gerçek Zebra cihaz)
///   2. HardwareKeyboard HID input (RF gun klavye modu)
///   3. Manuel TextField girişi (test / fallback)
class BarkodScanWidget extends StatefulWidget {
  final String hint;
  final void Function(String barkod) onScanned;
  final bool autoFocus;
  final String? acceptLabel;

  const BarkodScanWidget({
    super.key,
    required this.onScanned,
    this.hint = 'Barkodu okutun veya girin...',
    this.autoFocus = true,
    this.acceptLabel,
  });

  @override
  State<BarkodScanWidget> createState() => _BarkodScanWidgetState();
}

class _BarkodScanWidgetState extends State<BarkodScanWidget>
    with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  // DataWedge stream aboneliği — dispose'da mutlaka iptal edilmeli
  StreamSubscription<String>? _scanSubscription;

  // HID klavye buffer — RF gun karakterleri arka arkaya gönderir
  final StringBuffer _hidBuffer = StringBuffer();
  Timer? _hidDebounce;

  bool _scanning = false;

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 1. DataWedge Intent akışını dinle
    _scanSubscription = DataWedgeService.barkodStream.listen(
      _onDataWedgeScan,
      onError: (_) {/* DataWedge yoksa sessizce geç */},
    );

    // 2. HID klavye handler'ı kaydet (RF gun fallback)
    HardwareKeyboard.instance.addHandler(_onHidKey);

    // 3. Otomatik focus
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _requestFocus());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Stream aboneliğini kapat — yoksa bellek sızıntısı olur!
    _scanSubscription?.cancel();
    _scanSubscription = null;

    // HID handler'ı kaldır
    HardwareKeyboard.instance.removeHandler(_onHidKey);

    _hidDebounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Uygulama arka plandan öne gelince focus'u geri al
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.autoFocus) {
      _requestFocus();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Focus yönetimi
  // ─────────────────────────────────────────────────────────────────────────

  void _requestFocus() {
    if (mounted && !_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DataWedge callback
  // ─────────────────────────────────────────────────────────────────────────

  void _onDataWedgeScan(String barkod) {
    if (!mounted) return;
    _controller.text = barkod;
    _submit(barkod);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HID klavye handler (RF gun klavye modunda çalışır)
  // ─────────────────────────────────────────────────────────────────────────

  bool _onHidKey(KeyEvent event) {
    // Sadece KeyDownEvent işle
    if (event is! KeyDownEvent) return false;

    // TextField zaten odakta ise HardwareKeyboard'u devreye alma;
    // TextField kendi onSubmitted'ını çağıracak.
    if (_focusNode.hasFocus) return false;

    final key = event.logicalKey;

    // Enter veya Tab → barkod tamamlandı
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.tab) {
      _hidDebounce?.cancel();
      final value = _hidBuffer.toString().trim();
      _hidBuffer.clear();
      if (value.isNotEmpty) {
        _controller.text = value;
        _submit(value);
      }
      return true;
    }

    // Yazdırılabilir karakter
    final char = event.character;
    if (char != null && char.isNotEmpty) {
      _hidBuffer.write(char);

      // 150 ms içinde Enter gelmezse yine de işle
      _hidDebounce?.cancel();
      _hidDebounce = Timer(const Duration(milliseconds: 150), () {
        final value = _hidBuffer.toString().trim();
        _hidBuffer.clear();
        if (value.isNotEmpty && mounted) {
          _controller.text = value;
          _submit(value);
        }
      });
      return true;
    }

    return false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Submit
  // ─────────────────────────────────────────────────────────────────────────

  void _submit(String value) {
    final barkod = value.trim().toUpperCase();
    if (barkod.isEmpty) return;

    setState(() => _scanning = true);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _scanning = false);
      widget.onScanned(barkod);
      _controller.clear();

      // ÖNEMLİ: Okuma bittikten sonra TextField'a focus ver
      // Böylece bir sonraki RF gun okuması anında TextField'a düşer
      _requestFocus();
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _scanning ? AppTheme.primaryBlue : AppTheme.dividerDark,
          width: _scanning ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _scanning ? Icons.radar : Icons.qr_code_scanner,
                  color: AppTheme.primaryBlue,
                  size: 22,
                ),
              )
                  .animate(target: _scanning ? 1 : 0)
                  .scaleXY(end: 1.1)
                  .then()
                  .scaleXY(end: 1.0),
              const SizedBox(width: 12),
              Text(
                _scanning ? 'Okunuyor...' : 'Barkod Tarama',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              if (_scanning)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryBlue,
                  ),
                ).animate().fadeIn(),
            ],
          ),
          const SizedBox(height: 16),


          GestureDetector(
            onTap: _requestFocus,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autoFocus,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.characters,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: 'monospace',
                    letterSpacing: 1.5,
                    fontSize: 16,
                  ),
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon:
                    const Icon(Icons.barcode_reader, color: AppTheme.textMuted),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: AppTheme.textMuted),
                  onPressed: () {
                    _controller.clear();
                    _requestFocus();
                  },
                ),
              ),
              onSubmitted: _submit, // Enter tuşu → submit
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _scanning ? null : () => _submit(_controller.text),
              icon: const Icon(Icons.check_circle_outline),
              label: Text(widget.acceptLabel ?? 'Onayla'),
            ),
          ),
        ],
      ),
    );
  }
}