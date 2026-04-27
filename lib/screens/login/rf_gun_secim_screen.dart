import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:faurecia/core/constants/app_constants.dart';
import 'package:faurecia/core/theme/app_theme.dart';
import 'package:faurecia/providers/database_provider.dart';
import 'package:faurecia/providers/uretim_provider.dart';
import 'package:faurecia/providers/kirilma_provider.dart';
import 'package:faurecia/providers/silo_provider.dart';
import 'package:faurecia/screens/uretim/uretim_main_screen.dart';
import 'package:faurecia/screens/kirilma/kirilma_main_screen.dart';
import 'package:faurecia/screens/silo/silo_main_screen.dart';

class RfGunSecimScreen extends ConsumerStatefulWidget {
  const RfGunSecimScreen({super.key});

  @override
  ConsumerState<RfGunSecimScreen> createState() => _RfGunSecimScreenState();
}

class _RfGunSecimScreenState extends ConsumerState<RfGunSecimScreen> {
  void _navigate(int gunNo) {
    Widget screen = switch (gunNo) {
      RfGun.uretim => const UretimMainScreen(),
      RfGun.kirilma => const KirilmaMainScreen(),
      RfGun.silo => const SiloMainScreen(),
      _ => const UretimMainScreen(),
    };
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> _sifirlamaOnay() async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: AppTheme.errorRed),
            SizedBox(width: 10),
            Text('Veritabanını Sıfırla'),
          ],
        ),
        content: const Text(
          'Tüm kutu, çuval, transfer ve işlem kayıtları kalıcı olarak silinecek.\n\nDevam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );

    if (onay != true) return;

    try {
      final db = ref.read(appDatabaseProvider);
      await db.resetForTest();

      // Bellekteki tüm provider state'lerini sıfırla
      ref.invalidate(uretimProvider);
      ref.invalidate(kirilmaProvider);
      ref.invalidate(siloProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Veritabanı sıfırlandı'),
            backgroundColor: AppTheme.successGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: AppTheme.errorRed),
            tooltip: 'Veritabanını Sıfırla',
            onPressed: _sifirlamaOnay,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.primaryBlueDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 44),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text(
                'Faurecia',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ).animate().fadeIn(delay: 200.ms),
              Text(
                'Barkod Takip Sistemi',
                style: Theme.of(context).textTheme.titleMedium,
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 48),
              Text(
                'RF Gun Seçimi',
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 8),
              Text(
                'Hangi bölgede çalışıyorsunuz?',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(delay: 450.ms),
              const SizedBox(height: 32),
              Column(
                children: [
                  _GunCard(
                    gunNo: RfGun.uretim,
                    title: 'RF Gun 1',
                    subtitle: 'Üretim Bölgesi',
                    desc: 'Kutu barkodu okuma ve araç yükleme',
                    icon: Icons.factory_rounded,
                    color: AppTheme.accentOrange,
                    delay: 500,
                    onTap: () => _navigate(RfGun.uretim),
                  ),
                  const SizedBox(height: 14),
                  _GunCard(
                    gunNo: RfGun.kirilma,
                    title: 'RF Gun 2',
                    subtitle: 'Kırılma Bölgesi',
                    desc: 'Teslim alma, çuval okuma ve kayıt',
                    icon: Icons.precision_manufacturing_rounded,
                    color: AppTheme.accentAmber,
                    delay: 600,
                    onTap: () => _navigate(RfGun.kirilma),
                  ),
                  const SizedBox(height: 14),
                  _GunCard(
                    gunNo: RfGun.silo,
                    title: 'RF Gun 3',
                    subtitle: 'Silo Bölgesi',
                    desc: 'Çuval teslim alma ve silo kaydı',
                    icon: Icons.warehouse_rounded,
                    color: AppTheme.primaryBlue,
                    delay: 700,
                    onTap: () => _navigate(RfGun.silo),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _GunCard extends StatelessWidget {
  final int gunNo;
  final String title;
  final String subtitle;
  final String desc;
  final IconData icon;
  final Color color;
  final int delay;
  final VoidCallback onTap;

  const _GunCard({
    required this.gunNo,
    required this.title,
    required this.subtitle,
    required this.desc,
    required this.icon,
    required this.color,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1.2),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.08), AppTheme.cardDark],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: color),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            subtitle,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(desc, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppTheme.textMuted, size: 16),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.1);
  }
}