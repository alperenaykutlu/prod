import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:faurecia/core/theme/app_theme.dart';
import 'package:faurecia/providers/uretim_provider.dart';
import 'package:faurecia/providers/kirilma_provider.dart';
import 'package:faurecia/providers/silo_provider.dart';
import 'package:faurecia/widgets/feedback_widgets.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uretim = ref.watch(uretimProvider);
    final kirilma = ref.watch(kirilmaProvider);
    final silo = ref.watch(siloProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(uretimProvider.notifier).loadKutular();
              ref.read(kirilmaProvider.notifier).load();
              ref.read(siloProvider.notifier).load();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryBlue,
        onRefresh: () async {
          ref.read(uretimProvider.notifier).loadKutular();
          ref.read(kirilmaProvider.notifier).load();
          ref.read(siloProvider.notifier).load();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Genel Durum',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Tüm bölgeler anlık özet',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              // Stat kartları
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.1,
                children: [
                  SummaryCardWidget(
                    title: 'Üretimde Kutu',
                    value: '${uretim.todayCount}',
                    icon: Icons.inventory_2_rounded,
                    color: AppTheme.accentOrange,
                    subtitle: 'Bugün',
                  ),
                  SummaryCardWidget(
                    title: 'Bekleyen Transfer',
                    value: '${kirilma.bekleyenKutular.length}',
                    icon: Icons.local_shipping_rounded,
                    color: AppTheme.accentAmber,
                    subtitle: 'Araçta',
                  ),
                  SummaryCardWidget(
                    title: 'Çuval Kırılmada',
                    value: '${kirilma.cuvallar.length}',
                    icon: Icons.shopping_bag_rounded,
                    color: AppTheme.warningYellow,
                    subtitle: 'İşlemde',
                  ),
                  SummaryCardWidget(
                    title: 'Silo Teslim',
                    value: '${silo.teslimAlinanCuvallar.length}',
                    icon: Icons.warehouse_rounded,
                    color: AppTheme.successGreen,
                    subtitle: 'Toplam',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // İşlem akışı özeti
              Text('İşlem Akışı', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              _FlowStep(
                step: 1,
                label: 'Üretim Bölgesi',
                desc: 'RF Gun 1 kutu barkodlarını okuttu',
                color: AppTheme.accentOrange,
                icon: Icons.factory_rounded,
                count: uretim.kutular.length,
              ),
              _Arrow(),
              _FlowStep(
                step: 2,
                label: 'Araç Transferi',
                desc: 'Kutular araca yüklendi',
                color: AppTheme.accentAmber,
                icon: Icons.local_shipping_rounded,
                count: kirilma.bekleyenKutular.length,
              ),
              _Arrow(),
              _FlowStep(
                step: 3,
                label: 'Kırılma Bölgesi',
                desc: 'RF Gun 2 teslim aldı, çuval oluşturdu',
                color: AppTheme.warningYellow,
                icon: Icons.precision_manufacturing_rounded,
                count: kirilma.cuvallar.length,
              ),
              _Arrow(),
              _FlowStep(
                step: 4,
                label: 'Silo Bölgesi',
                desc: 'RF Gun 3 çuvalları teslim aldı',
                color: AppTheme.successGreen,
                icon: Icons.warehouse_rounded,
                count: silo.teslimAlinanCuvallar.length,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  final int step;
  final String label;
  final String desc;
  final Color color;
  final IconData icon;
  final int count;

  const _FlowStep({
    required this.step,
    required this.label,
    required this.desc,
    required this.color,
    required this.icon,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$step', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.headlineSmall),
                Text(desc, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }
}

class _Arrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Icon(Icons.arrow_downward, color: AppTheme.textMuted, size: 20),
      ),
    );
  }
}
