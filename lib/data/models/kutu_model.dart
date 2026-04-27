import 'package:faurecia/core/constants/app_constants.dart';

class KutuModel {
  final int? id;
  final String barkod;
  final KutuRenk renk;
  final String okumaBolgesi;
  final DateTime okumaZamani;
  final KutuDurum durum;
  final String? aracId;

  const KutuModel({
    this.id,
    required this.barkod,
    required this.renk,
    required this.okumaBolgesi,
    required this.okumaZamani,
    this.durum = KutuDurum.uretimde,
    this.aracId,
  });

  KutuModel copyWith({
    int? id,
    String? barkod,
    KutuRenk? renk,
    String? okumaBolgesi,
    DateTime? okumaZamani,
    KutuDurum? durum,
    String? aracId,
  }) {
    return KutuModel(
      id: id ?? this.id,
      barkod: barkod ?? this.barkod,
      renk: renk ?? this.renk,
      okumaBolgesi: okumaBolgesi ?? this.okumaBolgesi,
      okumaZamani: okumaZamani ?? this.okumaZamani,
      durum: durum ?? this.durum,
      aracId: aracId ?? this.aracId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.colId: id,
      DbConstants.colBarkod: barkod,
      DbConstants.colKutuRenk: renk.name,
      DbConstants.colKutuBolge: okumaBolgesi,
      DbConstants.colZaman: okumaZamani.toUtc().toIso8601String(),
      DbConstants.colKutuDurum: durum.name,
      DbConstants.colKutuAracId: aracId,
    };
  }

  factory KutuModel.fromMap(Map<String, dynamic> map) {
    return KutuModel(
      id: map[DbConstants.colId] as int?,
      barkod: map[DbConstants.colBarkod] as String,
      renk: KutuRenk.fromString(map[DbConstants.colKutuRenk] as String),
      okumaBolgesi: map[DbConstants.colKutuBolge] as String,
      okumaZamani: DateTime.parse(map[DbConstants.colZaman] as String).toLocal(),
      durum: KutuDurum.fromString(map[DbConstants.colKutuDurum] as String),
      aracId: map[DbConstants.colKutuAracId] as String?,
    );
  }

  @override
  String toString() =>
      'KutuModel(id: $id, barkod: $barkod, renk: ${renk.name}, durum: ${durum.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is KutuModel && barkod == other.barkod;

  @override
  int get hashCode => barkod.hashCode;
}
