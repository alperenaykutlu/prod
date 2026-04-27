import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:faurecia/core/theme/app_theme.dart';
import 'package:faurecia/providers/silo_provider.dart';
import 'package:faurecia/widgets/barkod_scan_widget.dart';
import 'package:faurecia/widgets/feedback_widgets.dart';

class SiloTeslimScreen extends ConsumerWidget {
  const SiloTeslimScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(siloProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          if (state.successMessage != null)
            ScanResultWidget(
              type: ScanResultType.success,
              message: state.successMessage!,
              onDismiss: () => ref.read(siloProvider.notifier).clearMessages(),
            ),
          if (state.errorMessage != null)
            ScanResultWidget(
              type: ScanResultType.error,
              message: state.errorMessage!,
              onDismiss: () => ref.read(siloProvider.notifier).clearMessages(),
            ),
          if (state.successMessage != null || state.errorMessage != null)
            const SizedBox(height: 16),

          // Bilgi banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warehouse_rounded, color: AppTheme.primaryBlue, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Kırılma bölgesinden gelen çuvalı okutun.\n'
                    'Çuval silo bölgesine teslim alınır.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Çuval Teslim Alma', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            'Kırılma bölgesinden gelen çuval barkodunu okutun',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          BarkodScanWidget(
            hint: 'Çuval barkodunu okutun (ör: CV-0001)',
            acceptLabel: 'Siloya Teslim Al',
            onScanned: (barkod) {
              ref.read(siloProvider.notifier).cuvalTeslimAl(barkod: barkod);
            },
          ),

          if (state.bekleyenCuvallar.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Beklenen Çuvallar (${state.bekleyenCuvallar.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...state.bekleyenCuvallar.take(5).map((cuval) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cuval.renk.color.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.shopping_bag_rounded, color: cuval.renk.color, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      cuval.barkod,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontFamily: 'monospace'),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cuval.renk.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cuval.renk.label,
                      style: TextStyle(color: cuval.renk.color, fontSize: 11),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
}
