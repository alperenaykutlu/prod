import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:faurecia/core/constants/app_constants.dart';
import 'package:faurecia/core/theme/app_theme.dart';
import 'package:faurecia/core/utils/app_date_utils.dart';
import 'package:faurecia/providers/database_provider.dart';
import 'package:faurecia/data/models/islem_kayit_model.dart';

class RaporScreen extends ConsumerStatefulWidget {
  const RaporScreen({super.key});

  @override
  ConsumerState<RaporScreen> createState() => _RaporScreenState();
}

class _RaporScreenState extends ConsumerState<RaporScreen> {
  int? _filterRfGun; // null = tümü
  String? _filterBolge;

  @override
  Widget build(BuildContext context) {
    final islemDaoAsync = ref.watch(islemKayitDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('İşlem Raporu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: islemDaoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (dao) {
          return FutureBuilder<List<IslemKayitModel>>(
            future: _filterRfGun != null
                ? dao.getByRfGun(_filterRfGun!)
                : _filterBolge != null
                    ? dao.getByBolge(_filterBolge!)
                    : dao.getAll(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final kayitlar = snapshot.data ?? [];
              return Column(
                children: [
                  _FilterBar(
                    rfGun: _filterRfGun,
                    bolge: _filterBolge,
                    onClear: () => setState(() {
                      _filterRfGun = null;
                      _filterBolge = null;
                    }),
                  ),
                  Expanded(
                    child: kayitlar.isEmpty
                        ? const _EmptyRapor()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: kayitlar.length,
                            itemBuilder: (_, i) => _KayitRow(kayit: kayitlar[i]),
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filtrele', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text('RF Gun', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [1, 2, 3].map((gun) => FilterChip(
                label: Text('RF Gun $gun'),
                selected: _filterRfGun == gun,
                onSelected: (v) {
                  setState(() => _filterRfGun = v ? gun : null);
                  Navigator.pop(context);
                },
                selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Text('Bölge', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: Bolge.values.map((b) => FilterChip(
                label: Text(b.label),
                selected: _filterBolge == b.code,
                onSelected: (v) {
                  setState(() => _filterBolge = v ? b.code : null);
                  Navigator.pop(context);
                },
                selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final int? rfGun;
  final String? bolge;
  final VoidCallback onClear;

  const _FilterBar({required this.rfGun, required this.bolge, required this.onClear});

  @override
  Widget build(BuildContext context) {
    if (rfGun == null && bolge == null) return const SizedBox.shrink();
    return Container(
      color: AppTheme.surfaceDark,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 16, color: AppTheme.primaryBlue),
          const SizedBox(width: 6),
          if (rfGun != null)
            Text('RF Gun $rfGun', style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 13)),
          if (bolge != null)
            Text(
              Bolge.fromCode(bolge!).label,
              style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 13),
            ),
          const Spacer(),
          GestureDetector(
            onTap: onClear,
            child: const Text('Temizle', style: TextStyle(color: AppTheme.errorRed, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _KayitRow extends StatelessWidget {
  final IslemKayitModel kayit;
  const _KayitRow({required this.kayit});

  @override
  Widget build(BuildContext context) {
    final color = switch (kayit.tip) {
      IslemTipi.kutuOkuma => AppTheme.accentOrange,
      IslemTipi.aracaYukleme => AppTheme.accentAmber,
      IslemTipi.kirilmaTeslimAlma => AppTheme.warningYellow,
      IslemTipi.cuvalOkuma => AppTheme.primaryBlue,
      IslemTipi.siloTeslimAlma => AppTheme.successGreen,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'G${kayit.rfGunNo}',
                style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kayit.tip.label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color)),
                Text(
                  kayit.barkod,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontFamily: 'monospace'),
                ),
                if (kayit.aciklama != null)
                  Text(kayit.aciklama!, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(kayit.bolge.label, style: Theme.of(context).textTheme.labelSmall),
              Text(kayit.zaman.toDisplayTime(), style: Theme.of(context).textTheme.labelSmall),
              Text(kayit.zaman.toDisplayDate(), style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyRapor extends StatelessWidget {
  const _EmptyRapor();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment_outlined, size: 64, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text('Kayıt bulunamadı', style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
    );
  }
}
