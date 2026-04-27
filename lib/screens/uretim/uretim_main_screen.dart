import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:faurecia/core/constants/app_constants.dart';
import 'package:faurecia/core/theme/app_theme.dart';
import 'package:faurecia/providers/uretim_provider.dart';
import 'package:faurecia/screens/uretim/kutu_okuma_screen.dart';
import 'package:faurecia/screens/uretim/arac_yukleme_screen.dart';
import 'package:faurecia/screens/dashboard/dashboard_screen.dart';
import 'package:faurecia/widgets/kart_widgets.dart';

class UretimMainScreen extends ConsumerStatefulWidget {
  const UretimMainScreen({super.key});

  @override
  ConsumerState<UretimMainScreen> createState() => _UretimMainScreenState();
}

class _UretimMainScreenState extends ConsumerState<UretimMainScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uretimProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('RF Gun 1 – Üretim Bölgesi'),
            Text(
              'Bugün: ${state.todayCount} kutu okutuldu',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(uretimProvider.notifier).loadKutular(),
          ),
        ],
      ),
      body: _buildBody(state),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Kayıtlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Kutu Oku',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Araç Yükle',
          ),
        ],
      ),
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => setState(() => _tabIndex = 1),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Barkod Okut'),
              backgroundColor: AppTheme.primaryBlue,
            )
          : null,
    );
  }

  Widget _buildBody(UretimState state) {
    return IndexedStack(
      index: _tabIndex,
      children: [
        // Kayıtlar listesi
        state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.kutular.isEmpty
                ? _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.kutular.length,
                    itemBuilder: (_, i) => KutuKartWidget(kutu: state.kutular[i]),
                  ),
        // Kutu okuma
        const KutuOkumaScreen(),
        // Araç yükleme
        const AracYuklemeScreen(),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 64, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text('Henüz kayıt yok', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Bir kutu barkodu okutarak başlayın.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
