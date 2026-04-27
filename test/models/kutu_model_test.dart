// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:faurecia/core/constants/app_constants.dart';
import 'package:faurecia/data/models/kutu_model.dart';

void main() {
  group('KutuModel Tests', () {
    late KutuModel kutu;

    setUp(() {
      kutu = KutuModel(
        id: 1,
        barkod: 'KT-0001',
        renk: KutuRenk.turuncu,
        okumaBolgesi: 'HAT-1',
        okumaZamani: DateTime(2026, 3, 9, 10, 0),
        durum: KutuDurum.uretimde,
      );
    });

    test('toMap → doğru anahtar/değer üretir', () {
      final map = kutu.toMap();
      expect(map['barkod'], equals('KT-0001'));
      expect(map['renk'], equals('turuncu'));
      expect(map['bolge'], equals('HAT-1'));
      expect(map['durum'], equals('uretimde'));
      expect(map['arac_id'], isNull);
    });

    test('fromMap → KutuModel doğru oluşur', () {
      final map = kutu.toMap();
      final fromMap = KutuModel.fromMap(map);
      expect(fromMap.barkod, equals(kutu.barkod));
      expect(fromMap.renk, equals(kutu.renk));
      expect(fromMap.okumaBolgesi, equals(kutu.okumaBolgesi));
      expect(fromMap.durum, equals(kutu.durum));
    });

    test('toMap → fromMap round-trip tutarlı', () {
      final roundTrip = KutuModel.fromMap(kutu.toMap());
      expect(roundTrip.barkod, equals(kutu.barkod));
      expect(roundTrip.renk, equals(kutu.renk));
      expect(roundTrip.durum, equals(kutu.durum));
    });

    test('copyWith → yalnızca belirtilen alan değişir', () {
      final updated = kutu.copyWith(durum: KutuDurum.aracta, aracId: 'A001');
      expect(updated.durum, equals(KutuDurum.aracta));
      expect(updated.aracId, equals('A001'));
      expect(updated.barkod, equals(kutu.barkod)); // Değişmemeli
      expect(updated.renk, equals(kutu.renk));     // Değişmemeli
    });

    test('eşitlik → barkod üzerinden karşılaştırma çalışır', () {
      final diger = KutuModel(
        barkod: 'KT-0001',  // Aynı barkod
        renk: KutuRenk.mavi,
        okumaBolgesi: 'HAT-2',
        okumaZamani: DateTime.now(),
      );
      expect(kutu, equals(diger));
    });

    test('KutuDurum renk eşleşmeleri doğru', () {
      expect(KutuDurum.uretimde.label, equals('Üretimde'));
      expect(KutuDurum.aracta.label, equals('Araçta'));
      expect(KutuDurum.kirilmada.label, equals('Kırılmada'));
      expect(KutuDurum.tamamlandi.label, equals('Tamamlandı'));
    });

    test('KutuRenk.fromString → geçersiz değerde varsayılan döner', () {
      expect(KutuRenk.fromString('geçersiz'), equals(KutuRenk.turuncu));
      expect(KutuRenk.fromString('mavi'), equals(KutuRenk.mavi));
      expect(KutuRenk.fromString('turuncu'), equals(KutuRenk.turuncu));
    });
  });
}
