import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:faurecia/core/constants/app_constants.dart';
import 'package:faurecia/data/models/cuval_model.dart';
import 'package:faurecia/data/repositories/cuval_repository.dart';
import 'package:faurecia/providers/database_provider.dart';

class SiloState {
  final List<CuvalModel> bekleyenCuvallar;
  final List<CuvalModel> teslimAlinanCuvallar;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const SiloState({
    this.bekleyenCuvallar = const [],
    this.teslimAlinanCuvallar = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  SiloState copyWith({
    List<CuvalModel>? bekleyenCuvallar,
    List<CuvalModel>? teslimAlinanCuvallar,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return SiloState(
      bekleyenCuvallar: bekleyenCuvallar ?? this.bekleyenCuvallar,
      teslimAlinanCuvallar: teslimAlinanCuvallar ?? this.teslimAlinanCuvallar,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class SiloNotifier extends StateNotifier<SiloState> {
  final CuvalRepository _cuvalRepo;

  SiloNotifier(this._cuvalRepo) : super(const SiloState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final bekleyen = await _cuvalRepo.getByDurum(CuvalDurum.olusturuldu);
      final siloda = await _cuvalRepo.getByDurum(CuvalDurum.siloda);
      state = state.copyWith(
        bekleyenCuvallar: bekleyen,
        teslimAlinanCuvallar: siloda,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Yükleme hatası: $e');
    }
  }

  /// RF Gun 3: Çuvalı silo'da teslim al
  Future<void> cuvalTeslimAl({
    required String barkod,
    int rfGunNo = RfGun.silo,
  }) async {
    if (barkod.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Barkod boş olamaz!');
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final b = barkod.trim().toUpperCase();
      await _cuvalRepo.siloTeslimAl(barkod: b, rfGunNo: rfGunNo);
      await load();
      state = state.copyWith(
        isLoading: false,
        successMessage: '✓ Çuval silo teslim alındı: $b',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Silo teslim hatası: $e');
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

final siloProvider = StateNotifierProvider<SiloNotifier, SiloState>((ref) {
  return SiloNotifier(ref.watch(cuvalRepositoryProvider));
});
