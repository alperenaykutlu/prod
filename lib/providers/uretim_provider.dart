import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:faurecia/core/constants/app_constants.dart';
import 'package:faurecia/data/models/kutu_model.dart';
import 'package:faurecia/data/repositories/kutu_repository.dart';
import 'package:faurecia/data/repositories/transfer_repository.dart';
import 'package:faurecia/providers/database_provider.dart';

// ─── State ───────────────────────────────────────────────────────────────────
class UretimState {
  final List<KutuModel> kutular;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final int todayCount;

  const UretimState({
    this.kutular = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.todayCount = 0,
  });

  UretimState copyWith({
    List<KutuModel>? kutular,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    int? todayCount,
  }) {
    return UretimState(
      kutular: kutular ?? this.kutular,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      todayCount: todayCount ?? this.todayCount,
    );
  }
}

// ─── Notifier ────────────────────────────────────────────────────────────────
class UretimNotifier extends StateNotifier<UretimState> {
  final KutuRepository _kutuRepo;
  final TransferRepository _transferRepo;

  UretimNotifier(this._kutuRepo, this._transferRepo) : super(const UretimState()) {
    loadKutular();
  }

  Future<void> loadKutular() async {
    state = state.copyWith(isLoading: true);
    try {
      final kutular = await _kutuRepo.getAll();
      final count = await _kutuRepo.countToday();
      state = state.copyWith(kutular: kutular, isLoading: false, todayCount: count);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Veri yüklenemedi: $e');
    }
  }

  /// RF Gun 1: Üretim bölgesinde kutu barkodunu kaydet
  Future<void> kutuOku({
    required String barkod,
    required KutuRenk renk,
    required String bolge,
    int rfGunNo = RfGun.uretim,
  }) async {
    if (barkod.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Barkod boş olamaz!');
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      await _kutuRepo.kutuOku(
        barkod: barkod.trim().toUpperCase(),
        renk: renk,
        bolge: bolge,
        rfGunNo: rfGunNo,
      );
      await loadKutular();
      state = state.copyWith(
        isLoading: false,
        successMessage: '✓ ${renk.label} kutu kaydedildi: $barkod',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Hata: $e');
    }
  }

 /// RF Gun 1: Kutuyu araca yükle — araç ID sabit
   Future<void> aracaYukle({required String barkod}) async {
     if (barkod.trim().isEmpty) {
       state = state.copyWith(errorMessage: 'Barkod boş olamaz!');
       return;
     }
     state = state.copyWith(isLoading: true);
     try {
       final b = barkod.trim().toUpperCase();
       await _kutuRepo.aracaYukle(barkod: b, rfGunNo: RfGun.uretim);
       await _transferRepo.aracaYukle(kutuBarkod: b);
       await loadKutular();
       state = state.copyWith(
         isLoading: false,
         successMessage: '✓ Kutu araca yüklendi: $b',
       );
     } catch (e) {
       state = state.copyWith(
           isLoading: false, errorMessage: 'Araç yükleme hatası: $e');
     }
   }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

// ─── Provider ────────────────────────────────────────────────────────────────
final uretimProvider = StateNotifierProvider<UretimNotifier, UretimState>((ref) {
  return UretimNotifier(
    ref.watch(kutuRepositoryProvider),
    ref.watch(transferRepositoryProvider),
  );
});
