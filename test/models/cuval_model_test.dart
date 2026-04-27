// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:faurecia/core/constants/app_constants.dart';
import 'package:faurecia/data/models/cuval_model.dart';

void main() {
  group('CuvalModel Tests', () {
    late CuvalModel cuval;

    setUp(() {
      cuval = CuvalModel(
        id: 1,
        barkod: 'CV-0001',
        renk: CuvalRenk.sari,
        kutuBarkod: 'KT-0001',
        olusturmaZamani: DateTime(2026, 3, 9, 11, 0),
        durum: CuvalDurum.olusturuldu,
      );
    });

    test('toMap → doğru anahtar/değer üretir', () {
      final map = cuval.toMap();
      expect(map['barkod'], equals('CV-0001'));
      expect(map['renk'], equals('sari'));
      expect(map['kutu_barkod'], equals('KT-0001'));
      expect(map['durum'], equals('olusturuldu'));
    });

    test('fromMap → CuvalModel doğru oluşur', () {
      final map = cuval.toMap();
      final fromMap = CuvalModel.fromMap(map);
      expect(fromMap.barkod, equals(cuval.barkod));
      expect(fromMap.renk, equals(cuval.renk));
      expect(fromMap.kutuBarkod, equals(cuval.kutuBarkod));
      expect(fromMap.durum, equals(cuval.durum));
    });

    test('round-trip serialize/deserialize tutarlı', () {
      final result = CuvalModel.fromMap(cuval.toMap());
      expect(result.barkod, equals(cuval.barkod));
      expect(result.renk, equals(cuval.renk));
    });

    test('CuvalRenk.fromKutuRenk → turuncu kutu = sarı çuval', () {
      expect(CuvalRenk.fromKutuRenk(KutuRenk.turuncu), equals(CuvalRenk.sari));
    });

    test('CuvalRenk.fromKutuRenk → mavi kutu = mavi çuval', () {
      expect(CuvalRenk.fromKutuRenk(KutuRenk.mavi), equals(CuvalRenk.mavi));
    });

    test('CuvalRenk.fromString → geçersiz değerde sarı döner', () {
      expect(CuvalRenk.fromString('geçersiz'), equals(CuvalRenk.sari));
      expect(CuvalRenk.fromString('mavi'), equals(CuvalRenk.mavi));
    });

    test('copyWith → yalnızca durum değişir', () {
      final updated = cuval.copyWith(durum: CuvalDurum.siloda);
      expect(updated.durum, equals(CuvalDurum.siloda));
      expect(updated.barkod, equals(cuval.barkod));
      expect(updated.renk, equals(cuval.renk));
    });
  });
}
