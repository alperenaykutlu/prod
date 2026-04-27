import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:faurecia/data/database/app_database.dart';
import 'package:faurecia/data/repositories/kutu_repository.dart';
import 'package:faurecia/data/repositories/cuval_repository.dart';
import 'package:faurecia/data/repositories/transfer_repository.dart';
import 'package:faurecia/data/database/islem_kayit_dao.dart';

// ─── Database ────────────────────────────────────────────────────────────────
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

// ─── Repositories ────────────────────────────────────────────────────────────
final kutuRepositoryProvider = Provider<KutuRepository>((ref) {
  return KutuRepository(ref.watch(appDatabaseProvider));
});

final cuvalRepositoryProvider = Provider<CuvalRepository>((ref) {
  return CuvalRepository(ref.watch(appDatabaseProvider));
});

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return TransferRepository(ref.watch(appDatabaseProvider));
});

// ─── Audit Log ───────────────────────────────────────────────────────────────
final islemKayitDaoProvider = FutureProvider<IslemKayitDao>((ref) async {
  final db = await ref.watch(appDatabaseProvider).database;
  return IslemKayitDao(db);
});
