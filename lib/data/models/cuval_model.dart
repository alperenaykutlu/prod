import 'package:faurecia/core/constants/app_constants.dart';

class CuvalModel {
  final int? id;
  final String barkod;
  final CuvalRenk renk;
  final String kutuBarkod;
  final DateTime olusturmaZamani;
  final CuvalDurum durum;

  const CuvalModel({
    this.id,
    required this.barkod,
    required this.renk,
    required this.kutuBarkod,
    required this.olusturmaZamani,
    this.durum = CuvalDurum.olusturuldu,
  });

  CuvalModel copyWith({
    int? id,
    String? barkod,
    CuvalRenk? renk,
    String? kutuBarkod,
    DateTime? olusturmaZamani,
    CuvalDurum? durum,
  }) {
    return CuvalModel(
      id: id ?? this.id,
      barkod: barkod ?? this.barkod,
      renk: renk ?? this.renk,
      kutuBarkod: kutuBarkod ?? this.kutuBarkod,
      olusturmaZamani: olusturmaZamani ?? this.olusturmaZamani,
      durum: durum ?? this.durum,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.colId: id,
      DbConstants.colBarkod: barkod,
      DbConstants.colCuvalRenk: renk.name,
      DbConstants.colCuvalKutuBarkod: kutuBarkod,
      DbConstants.colZaman: olusturmaZamani.toUtc().toIso8601String(),
      DbConstants.colCuvalDurum: durum.name,
    };
  }

  factory CuvalModel.fromMap(Map<String, dynamic> map) {
    return CuvalModel(
      id: map[DbConstants.colId] as int?,
      barkod: map[DbConstants.colBarkod] as String,
      renk: CuvalRenk.fromString(map[DbConstants.colCuvalRenk] as String),
      kutuBarkod: map[DbConstants.colCuvalKutuBarkod] as String,
      olusturmaZamani: DateTime.parse(map[DbConstants.colZaman] as String).toLocal(),
      durum: CuvalDurum.fromString(map[DbConstants.colCuvalDurum] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CuvalModel && barkod == other.barkod;

  @override
  int get hashCode => barkod.hashCode;
}
