import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:faurecia/core/constants/app_constants.dart';
import 'package:faurecia/core/theme/app_theme.dart';
import 'package:faurecia/providers/kirilma_provider.dart';
import 'package:faurecia/widgets/barkod_scan_widget.dart';
import 'package:faurecia/widgets/feedback_widgets.dart';

class CuvalOkumaScreen extends ConsumerStatefulWidget {
  const CuvalOkumaScreen({super.key});

  @override
  ConsumerState<CuvalOkumaScreen> createState() => _CuvalOkumaScreenState();
}

class _CuvalOkumaScreenState extends ConsumerState<CuvalOkumaScreen> {
  final _kutuBarkodController = TextEditingController();
  // Çuval rengi kutu renginden otomatik belirlenir, ancak manuel seçim de mümkün
  CuvalRenk _selectedCuvalRenk = CuvalRenk.sari;
  bool _autoRenk = true; // Turuncu → Sarı, Mavi → Mavi otomatik eşleşme

  @override
  void dispose() {
    _kutuBarkodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kirilmaProvider);

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

          // Renk kuralı bilgisi
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.dividerDark),
            ),
            child: Column(
              children: [
                _RenkKuralRow(
                  kutu: KutuRenk.turuncu,
                  cuval: CuvalRenk.sari,
                ),
                const Divider(height: 16),
                _RenkKuralRow(
                  kutu: KutuRenk.mavi,
                  cuval: CuvalRenk.mavi,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Kutu barkodu referansı
          Text('İlgili Kutu Barkodu', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _kutuBarkodController,
            decoration: const InputDecoration(
              hintText: 'Kutu barkodunu girin (ör: KT-0001)',
              prefixIcon: Icon(Icons.inventory_2_outlined),
            ),
            textCapitalization: TextCapitalization.characters,
            onChanged: (val) {
              // Kutu barkoduna göre çuval rengini bul
              if (_autoRenk && state.bekleyenKutular.isNotEmpty) {
                final kutu = state.bekleyenKutular
                    .where((k) => k.barkod == val.trim().toUpperCase())
                    .firstOrNull;
                if (kutu != null) {
                  setState(() {
                    _selectedCuvalRenk = CuvalRenk.fromKutuRenk(kutu.renk);
                  });
                }
              }
            },
          ),
          const SizedBox(height: 16),

          // Çuval rengi
          Row(
            children: [
              Text('Çuval Rengi', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              Row(
                children: [
                  Text('Otomatik', style: Theme.of(context).textTheme.bodyMedium),
                  Switch(
                    value: _autoRenk,
                    onChanged: (v) => setState(() => _autoRenk = v),
                    activeColor: AppTheme.primaryBlue,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: CuvalRenk.values.map((renk) {
              final selected = _selectedCuvalRenk == renk;
              return Expanded(
                child: Opacity(
                  opacity: _autoRenk ? 0.6 : 1.0,
                  child: GestureDetector(
                    onTap: _autoRenk ? null : () => setState(() => _selectedCuvalRenk = renk),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: selected ? renk.color.withOpacity(0.18) : AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? renk.color : AppTheme.dividerDark,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.shopping_bag_rounded, color: renk.color, size: 28),
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
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Çuval barkod tarama
          Text('Çuval Barkodu', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          BarkodScanWidget(
            hint: 'Çuval barkodunu okutun (ör: CV-0001)',
            acceptLabel: 'Çuvalı Kaydet',
            autoFocus: false,
            onScanned: (barkod) {
              final kutuBarkod = _kutuBarkodController.text.trim().toUpperCase();
              if (kutuBarkod.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Önce ilgili kutu barkodunu girin!')),
                );
                return;
              }
              ref.read(kirilmaProvider.notifier).cuvalOku(
                barkod: barkod,
                renk: _selectedCuvalRenk,
                kutuBarkod: kutuBarkod,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RenkKuralRow extends StatelessWidget {
  final KutuRenk kutu;
  final CuvalRenk cuval;
  const _RenkKuralRow({required this.kutu, required this.cuval});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.inventory_2_rounded, color: kutu.color, size: 18),
        const SizedBox(width: 6),
        Text(kutu.label, style: TextStyle(color: kutu.color, fontWeight: FontWeight.w600)),
        const Text(' Kutu'),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward, color: AppTheme.textMuted, size: 16),
        const SizedBox(width: 8),
        Icon(Icons.shopping_bag_rounded, color: cuval.color, size: 18),
        const SizedBox(width: 6),
        Text(cuval.label, style: TextStyle(color: cuval.color, fontWeight: FontWeight.w600)),
        const Text(' Çuval'),
      ],
    );
  }
}
