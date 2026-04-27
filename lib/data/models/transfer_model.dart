import 'package:faurecia/core/constants/app_constants.dart';

class TransferModel {
  final int? id;
  final String aracId;
  final String kutuBarkod;
  final DateTime yuklemeZamani;
  final DateTime? teslimZamani;
  final bool teslimAlindi;

  const TransferModel({
    this.id,
    required this.aracId,
    required this.kutuBarkod,
    required this.yuklemeZamani,
    this.teslimZamani,
    this.teslimAlindi = false,
  });

  TransferModel copyWith({
    int? id,
    String? aracId,
    String? kutuBarkod,
    DateTime? yuklemeZamani,
    DateTime? teslimZamani,
    bool? teslimAlindi,
  }) {
    return TransferModel(
      id: id ?? this.id,
      aracId: aracId ?? this.aracId,
      kutuBarkod: kutuBarkod ?? this.kutuBarkod,
      yuklemeZamani: yuklemeZamani ?? this.yuklemeZamani,
      teslimZamani: teslimZamani ?? this.teslimZamani,
      teslimAlindi: teslimAlindi ?? this.teslimAlindi,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.colId: id,
      DbConstants.colTransferAracId: aracId,
      DbConstants.colTransferKutuBarkod: kutuBarkod,
      DbConstants.colTransferYuklemeZamani: yuklemeZamani.toUtc().toIso8601String(),
      DbConstants.colTransferTeslimZamani: teslimZamani?.toUtc().toIso8601String(),
      DbConstants.colTransferTeslimAlindi: teslimAlindi ? 1 : 0,
    };
  }

  factory TransferModel.fromMap(Map<String, dynamic> map) {
    return TransferModel(
      id: map[DbConstants.colId] as int?,
      aracId: map[DbConstants.colTransferAracId] as String,
      kutuBarkod: map[DbConstants.colTransferKutuBarkod] as String,
      yuklemeZamani: DateTime.parse(map[DbConstants.colTransferYuklemeZamani] as String).toLocal(),
      teslimZamani: map[DbConstants.colTransferTeslimZamani] != null
          ? DateTime.parse(map[DbConstants.colTransferTeslimZamani] as String).toLocal()
          : null,
      teslimAlindi: (map[DbConstants.colTransferTeslimAlindi] as int) == 1,
    );
  }
}
