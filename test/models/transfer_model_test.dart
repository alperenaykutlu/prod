// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:faurecia/data/models/transfer_model.dart';

void main() {
  group('TransferModel Tests', () {
    late TransferModel transfer;

    setUp(() {
      transfer = TransferModel(
        id: 1,
        aracId: 'A001',
        kutuBarkod: 'KT-0001',
        yuklemeZamani: DateTime(2026, 3, 9, 9, 0),
        teslimAlindi: false,
      );
    });

    test('toMap → teslimAlindi false → 0 olarak saklanır', () {
      final map = transfer.toMap();
      expect(map['teslim_alindi'], equals(0));
      expect(map['arac_id'], equals('A001'));
      expect(map['kutu_barkod'], equals('KT-0001'));
    });

    test('fromMap → teslimAlindi 0 → false döner', () {
      final map = {
        'id': 1,
        'arac_id': 'A001',
        'kutu_barkod': 'KT-0001',
        'yukleme_zamani': DateTime(2026, 3, 9, 9, 0).toUtc().toIso8601String(),
        'teslim_zamani': null,
        'teslim_alindi': 0,
      };
      final model = TransferModel.fromMap(map);
      expect(model.teslimAlindi, isFalse);
      expect(model.teslimZamani, isNull);
    });

    test('fromMap → teslimAlindi 1 → true döner', () {
      final map = {
        'id': 2,
        'arac_id': 'A002',
        'kutu_barkod': 'KT-0002',
        'yukleme_zamani': DateTime(2026, 3, 9, 9, 0).toUtc().toIso8601String(),
        'teslim_zamani': DateTime(2026, 3, 9, 10, 0).toUtc().toIso8601String(),
        'teslim_alindi': 1,
      };
      final model = TransferModel.fromMap(map);
      expect(model.teslimAlindi, isTrue);
      expect(model.teslimZamani, isNotNull);
    });

    test('copyWith → teslimAlindi güncelleme', () {
      final updated = transfer.copyWith(
        teslimAlindi: true,
        teslimZamani: DateTime(2026, 3, 9, 12, 0),
      );
      expect(updated.teslimAlindi, isTrue);
      expect(updated.aracId, equals('A001')); // Değişmemeli
    });

    test('round-trip serialize/deserialize tutarlı', () {
      final map = transfer.toMap();
      final result = TransferModel.fromMap(map);
      expect(result.aracId, equals(transfer.aracId));
      expect(result.kutuBarkod, equals(transfer.kutuBarkod));
      expect(result.teslimAlindi, equals(transfer.teslimAlindi));
    });
  });
}
