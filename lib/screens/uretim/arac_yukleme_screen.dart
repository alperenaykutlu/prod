import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:faurecia/core/theme/app_theme.dart';
import 'package:faurecia/providers/uretim_provider.dart';
import 'package:faurecia/widgets/barkod_scan_widget.dart';
import 'package:faurecia/widgets/feedback_widgets.dart';

class AracYuklemeScreen extends ConsumerStatefulWidget {
  const AracYuklemeScreen({super.key});

  @override
  ConsumerState<AracYuklemeScreen> createState() => _AracYuklemeScreenState();
}

class _AracYuklemeScreenState extends ConsumerState<AracYuklemeScreen> {
  final List<String> _yuklenenBarkodlar = [];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uretimProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Feedback
          if (state.successMessage != null)
            ScanResultWidget(
              type: ScanResultType.success,
              message: state.successMessage!,
              onDismiss: () => ref.read(uretimProvider.notifier).clearMessages(),
            ),
          if (state.errorMessage != null)
            ScanResultWidget(
              type: ScanResultType.error,
              message: state.errorMessage!,
              onDismiss: () => ref.read(uretimProvider.notifier).clearMessages(),
            ),
          if (state.successMessage != null || state.errorMessage != null)
            const SizedBox(height: 16),

          // Bilgi banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.accentOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.accentOrange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_rounded,
                    color: AppTheme.accentOrange, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Kutu barkodunu okutun, araca yüklensin.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.accentOrange,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Barkod tarama
          Text('Kutu Barkodu Yükle',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          BarkodScanWidget(
            hint: 'Araca yüklenecek kutuyu okutun...',
            acceptLabel: 'Araca Yükle',
            autoFocus: false,
            onScanned: (barkod) {
              setState(() => _yuklenenBarkodlar.add(barkod));
              ref.read(uretimProvider.notifier).aracaYukle(barkod: barkod);
            },
          ),

          // Yükleme listesi
          if (_yuklenenBarkodlar.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Bu Seferde Yüklenenler (${_yuklenenBarkodlar.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            ..._yuklenenBarkodlar.map(
              (b) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.successGreen.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppTheme.successGreen, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      b,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontFamily: 'monospace'),
                    ),
                    const Spacer(),
                    const Text('Yüklendi',
                        style: TextStyle(
                            color: AppTheme.successGreen, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => setState(() => _yuklenenBarkodlar.clear()),
              icon: const Icon(Icons.clear_all),
              label: const Text('Listeyi Temizle'),
            ),
          ],
        ],
      ),
    );
  }
}