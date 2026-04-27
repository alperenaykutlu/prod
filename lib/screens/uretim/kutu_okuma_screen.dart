import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:faurecia/core/constants/app_constants.dart';
import 'package:faurecia/core/theme/app_theme.dart';
import 'package:faurecia/providers/uretim_provider.dart';
import 'package:faurecia/widgets/barkod_scan_widget.dart';
import 'package:faurecia/widgets/feedback_widgets.dart';

class KutuOkumaScreen extends ConsumerStatefulWidget {
  const KutuOkumaScreen({super.key});

  @override
  ConsumerState<KutuOkumaScreen> createState() => _KutuOkumaScreenState();
}

class _KutuOkumaScreenState extends ConsumerState<KutuOkumaScreen> {
  KutuRenk _selectedRenk = KutuRenk.turuncu;
  String _selectedBolge = 'HAT-1';

  final List<String> _bolgeler = ['UAP-1', 'UAP-2', 'UAP-3', 'UAP4'];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(uretimProvider.notifier).clearMessages(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uretimProvider);

    ref.listen<UretimState>(uretimProvider, (prev, next) {
      if (next.successMessage != null) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) ref.read(uretimProvider.notifier).clearMessages();
        });
      }
    });

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

          // Renk seçimi
          Text('Kutu Rengi', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Row(
            children: KutuRenk.values.map((renk) {
              final selected = _selectedRenk == renk;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRenk = renk),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: selected ? renk.color.withOpacity(0.2) : AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? renk.color : AppTheme.dividerDark,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_rounded, color: renk.color, size: 28),
                        const SizedBox(height: 6),
                        Text(
                          renk.label,
                          style: TextStyle(
                            color: selected ? renk.color : AppTheme.textSecondary,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Bölge seçimi
          Text('Alan / Hat', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _bolgeler.map((bolge) {
              final sel = _selectedBolge == bolge;
              return GestureDetector(
                onTap: () => setState(() => _selectedBolge = bolge),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.primaryBlue.withOpacity(0.15) : AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel ? AppTheme.primaryBlue : AppTheme.dividerDark,
                      width: sel ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    bolge,
                    style: TextStyle(
                      color: sel ? AppTheme.primaryBlue : AppTheme.textSecondary,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Barkod tarama
          BarkodScanWidget(
            hint: 'Kutu barkodunu okutun (ör: KT-0001)',
            acceptLabel: 'Kaydet',
            onScanned: (barkod) {
              ref.read(uretimProvider.notifier).kutuOku(
                barkod: barkod,
                renk: _selectedRenk,
                bolge: _selectedBolge,
              );
            },
          ),

          const SizedBox(height: 16),
          // Bilgi
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.primaryBlue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Seçilen renk: ${_selectedRenk.label} | Alan: $_selectedBolge\n'
                    'Kutu barkodunu okutunca otomatik kaydedilir.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
