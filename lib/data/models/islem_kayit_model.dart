import 'package:faurecia/core/constants/app_constants.dart';

class IslemKayitModel {
  final int? id;
  final IslemTipi tip;
  final String barkod;
  final Bolge bolge;
  final int rfGunNo;
  final DateTime zaman;
  final String? aciklama;

  const IslemKayitModel({
    this.id,
    required this.tip,
    required this.barkod,
    required this.bolge,
    required this.rfGunNo,
    required this.zaman,
    this.aciklama,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.colId: id,
      DbConstants.colIslemTip: tip.name,
      DbConstants.colBarkod: barkod,
      DbConstants.colIslemBolge: bolge.code,
      DbConstants.colIslemRfGunNo: rfGunNo,
      DbConstants.colZaman: zaman.toUtc().toIso8601String(),
      DbConstants.colIslemAciklama: aciklama,
    };
  }

  factory IslemKayitModel.fromMap(Map<String, dynamic> map) {
    return IslemKayitModel(
      id: map[DbConstants.colId] as int?,
      tip: IslemTipi.fromString(map[DbConstants.colIslemTip] as String),
      barkod: map[DbConstants.colBarkod] as String,
      bolge: Bolge.fromCode(map[DbConstants.colIslemBolge] as String),
      rfGunNo: map[DbConstants.colIslemRfGunNo] as int,
      zaman: DateTime.parse(map[DbConstants.colZaman] as String).toLocal(),
      aciklama: map[DbConstants.colIslemAciklama] as String?,
    );
  }
}
