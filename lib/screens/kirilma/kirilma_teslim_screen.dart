import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:faurecia/providers/kirilma_provider.dart';
import 'package:faurecia/widgets/barkod_scan_widget.dart';
import 'package:faurecia/widgets/feedback_widgets.dart';
import 'package:faurecia/core/theme/app_theme.dart';

class KirilmaTeslimScreen extends ConsumerWidget {
  const KirilmaTeslimScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(kirilmaProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // ── Geri bildirim mesajları ──────────────────────────────────────
          if (state.successMessage != null)
            ScanResultWidget(
              type: ScanResultType.success,
              message: state.successMessage!,
              onDismiss: () => ref.read(kirilmaProvider.notifier).clearMessages(),
            ),
          if (state.errorMessage != null)
            ScanResultWidget(
              type: ScanResultType.error,
              message: state.errorMessage!,
              onDismiss: () => ref.read(kirilmaProvider.notifier).clearMessages(),
            ),
          if (state.successMessage != null || state.errorMessage != null)
            const SizedBox(height: 16),

          // ── Bilgi banner ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.accentAmber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.accentAmber.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_rounded,
                    color: AppTheme.accentAmber, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Araçtan gelen kutuyu okutun.\n'
                    'Transfer otomatik kapatılır, kırılma bölgesine teslim alınır.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.accentAmber,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Barkod tarama ────────────────────────────────────────────────
          Text('Kutu Teslim Alma',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            'Araçtan indirilen kutu barkodunu okutun',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          BarkodScanWidget(
            hint: 'Gelen kutu barkodunu okutun...',
            acceptLabel: 'Teslim Al',
            onScanned: (barkod) {
              ref.read(kirilmaProvider.notifier).kutuTeslimAl(barkod: barkod);
            },
          ),

          // ── 1. Liste: Araçta – Teslim Alınmayı Bekliyor ─────────────────
          if (state.bekleyenKutular.isNotEmpty) ...[
            const SizedBox(height: 28),
            _SectionHeader(
              icon: Icons.local_shipping_rounded,
              color: AppTheme.accentAmber,
              title: 'Araçta – Teslim Bekliyor',
              count: state.bekleyenKutular.length,
            ),
            const SizedBox(height: 10),
            ...state.bekleyenKutular.map(
              (kutu) => _KutuSatir(
                kutu: kutu,
                iconData: Icons.inventory_2_rounded,
                borderColor: AppTheme.accentAmber,
              ),
            ),
          ],

          // ── 2. Liste: Kırılmada – Çuval Atanmayı Bekliyor ───────────────
          if (state.kirilmadaKutular.isNotEmpty) ...[
            const SizedBox(height: 28),
            _SectionHeader(
              icon: Icons.hourglass_top_rounded,
              color: AppTheme.primaryBlue,
              title: 'Kırılmada – Çuval Bekliyor',
              count: state.kirilmadaKutular.length,
            ),
            const SizedBox(height: 10),
            ...state.kirilmadaKutular.map(
              (kutu) => _KutuSatir(
                kutu: kutu,
                iconData: Icons.hourglass_top_rounded,
                borderColor: AppTheme.primaryBlue,
              ),
            ),
          ],

          // ── 3. Liste: Oluşturulmuş Çuvallar – Silo Bekliyor ─────────────
          if (state.cuvallar.isNotEmpty) ...[
            const SizedBox(height: 28),
            _SectionHeader(
              icon: Icons.shopping_bag_rounded,
              color: AppTheme.successGreen,
              title: 'Çuvallar – Silo Bekliyor',
              count: state.cuvallar.length,
            ),
            const SizedBox(height: 10),
            ...state.cuvallar.map((cuval) => _CuvalSatir(cuval: cuval)),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Yardımcı widget'lar ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final int count;

  const _SectionHeader({
    required this.icon,
    required this.color,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          '$title ($count)',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _KutuSatir extends StatelessWidget {
  final dynamic kutu;
  final IconData iconData;
  final Color borderColor;

  const _KutuSatir({
    required this.kutu,
    required this.iconData,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(iconData, color: kutu.renk.color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kutu.barkod as String,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontFamily: 'monospace'),
                ),
                if (kutu.okumaBolgesi != null && (kutu.okumaBolgesi as String).isNotEmpty)
                  Text(
                    kutu.okumaBolgesi as String,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: kutu.renk.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              kutu.renk.label as String,
              style: TextStyle(color: kutu.renk.color as Color, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _CuvalSatir extends StatelessWidget {
  final dynamic cuval;

  const _CuvalSatir({required this.cuval});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: (cuval.renk.color as Color).withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.shopping_bag_rounded,
              color: cuval.renk.color as Color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cuval.barkod as String,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontFamily: 'monospace'),
                ),
                Text(
                  'Kutu: ${cuval.kutuBarkod}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (cuval.renk.color as Color).withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              cuval.renk.label as String,
              style: TextStyle(
                  color: cuval.renk.color as Color, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}