import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:faurecia/core/theme/app_theme.dart';
import 'package:faurecia/providers/silo_provider.dart';
import 'package:faurecia/screens/silo/silo_teslim_screen.dart';
import 'package:faurecia/data/models/cuval_model.dart';
import 'package:faurecia/core/utils/app_date_utils.dart';

class SiloMainScreen extends ConsumerStatefulWidget {
  const SiloMainScreen({super.key});

  @override
  ConsumerState<SiloMainScreen> createState() => _SiloMainScreenState();
}

class _SiloMainScreenState extends ConsumerState<SiloMainScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(siloProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('RF Gun 3 – Silo Bölgesi'),
            Text(
              'Siloda: ${state.teslimAlinanCuvallar.length} çuval | Bekleyen: ${state.bekleyenCuvallar.length}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(siloProvider.notifier).load(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _tabIndex,
              children: [
                // Silodaki çuvallar
                _buildCuvalList(context, state.teslimAlinanCuvallar, 'Silo teslim listesi boş'),
                // Teslim alma
                const SiloTeslimScreen(),
                // Bekleyenler
                _buildCuvalList(context, state.bekleyenCuvallar, 'Bekleyen çuval yok'),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.warehouse_rounded),
            label: 'Silodakiler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Teslim Al',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hourglass_empty),
            label: 'Bekleyenler',
          ),
        ],
      ),
    );
  }

  Widget _buildCuvalList(BuildContext context, List<CuvalModel> list, String emptyMsg) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 64, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text(emptyMsg, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final cuval = list[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cuval.renk.color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cuval.renk.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.shopping_bag_rounded, color: cuval.renk.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cuval.barkod,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontFamily: 'monospace'),
                    ),
                    Text(
                      'Kutu: ${cuval.kutuBarkod}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      cuval.olusturmaZamani.toDisplayDateTime(),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cuval.durum.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  cuval.durum.label,
                  style: TextStyle(color: cuval.durum.color, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
