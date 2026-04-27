import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:faurecia/core/constants/app_constants.dart';
import 'package:faurecia/data/models/cuval_model.dart';
import 'package:faurecia/data/models/kutu_model.dart';
import 'package:faurecia/data/repositories/cuval_repository.dart';
import 'package:faurecia/data/repositories/kutu_repository.dart';
import 'package:faurecia/data/repositories/transfer_repository.dart';
import 'package:faurecia/providers/database_provider.dart';

class KirilmaState {
  final List<KutuModel> bekleyenKutular;
  final List<KutuModel> kirilmadaKutular;
  final List<CuvalModel> cuvallar;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const KirilmaState({
    this.bekleyenKutular = const [],
    this.kirilmadaKutular = const [],
    this.cuvallar = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  KirilmaState copyWith({
    List<KutuModel>? bekleyenKutular,
    List<KutuModel>? kirilmadaKutular,
    List<CuvalModel>? cuvallar,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return KirilmaState(
      bekleyenKutular: bekleyenKutular ?? this.bekleyenKutular,
      kirilmadaKutular: kirilmadaKutular ?? this.kirilmadaKutular,
      cuvallar: cuvallar ?? this.cuvallar,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class KirilmaNotifier extends StateNotifier<KirilmaState> {
  final KutuRepository _kutuRepo;
  final CuvalRepository _cuvalRepo;
  final TransferRepository _transferRepo;

  KirilmaNotifier(this._kutuRepo, this._cuvalRepo, this._transferRepo)
      : super(const KirilmaState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final bekleyenKutular  = await _kutuRepo.getByDurum(KutuDurum.aracta);
      final kirilmadaKutular = await _kutuRepo.getByDurum(KutuDurum.kirilmada);
      final cuvallar         = await _cuvalRepo.getByDurum(CuvalDurum.olusturuldu);
      state = state.copyWith(
        bekleyenKutular: bekleyenKutular,
        kirilmadaKutular: kirilmadaKutular,
        cuvallar: cuvallar,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Yükleme hatası: $e');
    }
  }

  /// RF Gun 2: Gelen kutuyu teslim al (araçtan kırılma bölgesine)
  Future<void> kutuTeslimAl({
    required String barkod,
    int rfGunNo = RfGun.kirilma,
  }) async {
    if (barkod.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Barkod boş olamaz!');
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final b = barkod.trim().toUpperCase();
      await _transferRepo.teslimAl(b);
      await _kutuRepo.kirilmaTeslimAl(barkod: b, rfGunNo: rfGunNo);
      await load();
      state = state.copyWith(
        isLoading: false,
        successMessage: '✓ Kutu teslim alındı: $b',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Teslim alma hatası: $e');
    }
  }

  /// RF Gun 2: Çuval barkodunu kaydet ve kutuyu üretime geri gönder
  Future<void> cuvalOku({
    required String barkod,
    required CuvalRenk renk,
    required String kutuBarkod,
    int rfGunNo = RfGun.kirilma,
  }) async {
    if (barkod.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Barkod boş olamaz!');
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final b = barkod.trim().toUpperCase();
      final kb = kutuBarkod.trim().toUpperCase();

      await _cuvalRepo.cuvalOku(
        barkod: b,
        renk: renk,
        kutuBarkod: kb,
        rfGunNo: rfGunNo,
      );

      // Çuval atandı → kutu kırılma listesinden çıkar, üretime döner
      await _kutuRepo.uretimeGonder(barkod: kb, rfGunNo: rfGunNo);

      await load();
      state = state.copyWith(
        isLoading: false,
        successMessage: '✓ ${renk.label} çuval kaydedildi: $b',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Çuval kayıt hatası: $e');
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

final kirilmaProvider = StateNotifierProvider<KirilmaNotifier, KirilmaState>((ref) {
  return KirilmaNotifier(
    ref.watch(kutuRepositoryProvider),
    ref.watch(cuvalRepositoryProvider),
    ref.watch(transferRepositoryProvider),
  );
});