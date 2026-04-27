import 'package:flutter/material.dart';
import 'package:faurecia/core/constants/app_constants.dart';
import 'package:faurecia/core/theme/app_theme.dart';
import 'package:faurecia/core/utils/app_date_utils.dart';
import 'package:faurecia/data/models/kutu_model.dart';

class KutuKartWidget extends StatelessWidget {
  final KutuModel kutu;
  final VoidCallback? onTap;

  const KutuKartWidget({super.key, required this.kutu, this.onTap});

  @override
  Widget build(BuildContext context) {
    final renk = kutu.renk;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: renk.color.withOpacity(0.35), width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Renk göstergesi
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: renk.color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.inventory_2_rounded, color: renk.color, size: 24),
              ),
              const SizedBox(width: 14),
              // Barkod & Bölge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kutu.barkod,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontFamily: 'monospace',
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 13, color: AppTheme.textMuted),
                        const SizedBox(width: 3),
                        Text(kutu.okumaBolgesi, style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(width: 10),
                        Icon(Icons.access_time, size: 13, color: AppTheme.textMuted),
                        const SizedBox(width: 3),
                        Text(
                          kutu.okumaZamani.toDisplayDateTime(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Renk & Durum
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _ColorChip(label: renk.label, color: renk.color),
                  const SizedBox(height: 6),
                  _DurumChip(durum: kutu.durum),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CuvalKartWidget extends StatelessWidget {
  final kutu;
  final VoidCallback? onTap;

  const CuvalKartWidget({super.key, required this.kutu, this.onTap});

  @override
  Widget build(BuildContext context) {
    final renk = kutu.renk as CuvalRenk;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: renk.color.withOpacity(0.35), width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: renk.color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.shopping_bag_rounded, color: renk.color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kutu.barkod as String,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontFamily: 'monospace',
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kutu: ${kutu.kutuBarkod}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              _ColorChip(label: renk.label, color: renk.color),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  final String label;
  final Color color;
  const _ColorChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _DurumChip extends StatelessWidget {
  final KutuDurum durum;
  const _DurumChip({required this.durum});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: durum.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        durum.label,
        style: TextStyle(color: durum.color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
