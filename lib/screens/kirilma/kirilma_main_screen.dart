import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:faurecia/core/theme/app_theme.dart';
import 'package:faurecia/providers/kirilma_provider.dart';
import 'package:faurecia/screens/kirilma/kirilma_teslim_screen.dart';
import 'package:faurecia/screens/kirilma/cuval_okuma_screen.dart';

class KirilmaMainScreen extends ConsumerStatefulWidget {
  const KirilmaMainScreen({super.key});

  @override
  ConsumerState<KirilmaMainScreen> createState() => _KirilmaMainScreenState();
}

class _KirilmaMainScreenState extends ConsumerState<KirilmaMainScreen> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Ekran açılınca veriyi yenile
    Future.microtask(
      () => ref.read(kirilmaProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kirilmaProvider);

    final toplamBekleyen =
        state.bekleyenKutular.length + state.kirilmadaKutular.length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('2. Adım – Kırılma Bölgesi'),
            Text(
              '$toplamBekleyen kutu bekliyor · ${state.cuvallar.length} çuval hazır',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(kirilmaProvider.notifier).load(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          // ── Tab 0: Bekleyen Listesi ──────────────────────────────────
          _BekleyenListesi(state: state),
          // ── Tab 1: Kutu Teslim Al ────────────────────────────────────
          const KirilmaTeslimScreen(),
          // ── Tab 2: Çuval Oku ─────────────────────────────────────────
          const CuvalOkumaScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        items: [
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: toplamBekleyen > 0,
              label: Text('$toplamBekleyen'),
              child: const Icon(Icons.list_alt),
            ),
            label: 'Bekleyenler',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Teslim Al',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Çuval Oku',
          ),
        ],
      ),
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => setState(() => _tabIndex = 1),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Kutu Teslim Al'),
              backgroundColor: AppTheme.accentAmber,
            )
          : null,
    );
  }
}

// ── Bekleyen Listesi Widget ──────────────────────────────────────────────────

class _BekleyenListesi extends StatelessWidget {
  final KirilmaState state;
  const _BekleyenListesi({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final hepsiBos = state.bekleyenKutular.isEmpty &&
        state.kirilmadaKutular.isEmpty &&
        state.cuvallar.isEmpty;

    if (hepsiBos) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 64, color: AppTheme.successGreen),
            const SizedBox(height: 16),
            Text('Bekleyen kayıt yok',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Tüm kutular ve çuvallar işlendi.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Araçta – Teslim Alınmayı Bekleyen Kutular ─────────────────
        if (state.bekleyenKutular.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.local_shipping_rounded,
            color: AppTheme.accentAmber,
            title: 'Araçta – Teslim Bekliyor',
            count: state.bekleyenKutular.length,
          ),
          const SizedBox(height: 10),
          ...state.bekleyenKutular.map(
            (kutu) => _KutuKart(
              barkod: kutu.barkod,
              renkLabel: kutu.renk.label,
              renkColor: kutu.renk.color,
              altBilgi: kutu.okumaBolgesi,
              icon: Icons.local_shipping_rounded,
              borderColor: AppTheme.accentAmber,
            ),
          ),
          const SizedBox(height: 20),
        ],

        // ── Kırılmada – Çuval Atanmayı Bekleyen Kutular ───────────────
        if (state.kirilmadaKutular.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.hourglass_top_rounded,
            color: AppTheme.primaryBlue,
            title: 'Kırılmada – Çuval Bekliyor',
            count: state.kirilmadaKutular.length,
          ),
          const SizedBox(height: 10),
          ...state.kirilmadaKutular.map(
            (kutu) => _KutuKart(
              barkod: kutu.barkod,
              renkLabel: kutu.renk.label,
              renkColor: kutu.renk.color,
              altBilgi: kutu.okumaBolgesi,
              icon: Icons.hourglass_top_rounded,
              borderColor: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 20),
        ],

        // ── Oluşturulmuş Çuvallar – Silo Bekliyor ─────────────────────
        if (state.cuvallar.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.shopping_bag_rounded,
            color: AppTheme.successGreen,
            title: 'Çuvallar – Silo Bekliyor',
            count: state.cuvallar.length,
          ),
          const SizedBox(height: 10),
          ...state.cuvallar.map(
            (cuval) => _KutuKart(
              barkod: cuval.barkod,
              renkLabel: cuval.renk.label,
              renkColor: cuval.renk.color,
              altBilgi: 'Kutu: ${cuval.kutuBarkod}',
              icon: Icons.shopping_bag_rounded,
              borderColor: AppTheme.successGreen,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Ortak kart widget ────────────────────────────────────────────────────────

class _KutuKart extends StatelessWidget {
  final String barkod;
  final String renkLabel;
  final Color renkColor;
  final String altBilgi;
  final IconData icon;
  final Color borderColor;

  const _KutuKart({
    required this.barkod,
    required this.renkLabel,
    required this.renkColor,
    required this.altBilgi,
    required this.icon,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: renkColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: renkColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  barkod,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'monospace',
                        letterSpacing: 1.1,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  altBilgi,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: renkColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: renkColor.withOpacity(0.4)),
            ),
            child: Text(
              renkLabel,
              style: TextStyle(
                color: renkColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          '$title ($count)',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: color, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}