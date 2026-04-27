import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:faurecia/core/constants/app_constants.dart';
import 'package:faurecia/data/database/kutu_dao.dart';
import 'package:faurecia/data/models/kutu_model.dart';

void main() {
  late Database db;
  late KutuDao dao;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE ${DbConstants.kutuTable} (
              id          INTEGER PRIMARY KEY AUTOINCREMENT,
              barkod      TEXT    NOT NULL UNIQUE,
              renk        TEXT    NOT NULL,
              bolge       TEXT    NOT NULL,
              zaman       TEXT    NOT NULL,
              durum       TEXT    NOT NULL DEFAULT 'uretimde',
              arac_id     TEXT
            )
          ''');
        },
      ),
    );
    dao = KutuDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('KutuDao Tests', () {
    test('insert → getByBarkod → kaydı getirir', () async {
      final kutu = KutuModel(
        barkod: 'KT-0001',
        renk: KutuRenk.turuncu,
        okumaBolgesi: 'HAT-1',
        okumaZamani: DateTime.now(),
      );
      await dao.insert(kutu);

      final result = await dao.getByBarkod('KT-0001');
      expect(result, isNotNull);
      expect(result!.barkod, equals('KT-0001'));
      expect(result.renk, equals(KutuRenk.turuncu));
      expect(result.durum, equals(KutuDurum.uretimde));
    });

    test('getByBarkod → olmayan barkod → null döner', () async {
      final result = await dao.getByBarkod('YOK-9999');
      expect(result, isNull);
    });

    test('updateDurum → durum güncellenir', () async {
      final kutu = KutuModel(
        barkod: 'KT-0002',
        renk: KutuRenk.mavi,
        okumaBolgesi: 'HAT-2',
        okumaZamani: DateTime.now(),
      );
      await dao.insert(kutu);
      await dao.updateDurum('KT-0002', KutuDurum.aracta, aracId: 'A001');

      final result = await dao.getByBarkod('KT-0002');
      expect(result!.durum, equals(KutuDurum.aracta));
      expect(result.aracId, equals('A001'));
    });

    test('getAll → tüm kayıtları döner', () async {
      for (var i = 1; i <= 3; i++) {
        await dao.insert(KutuModel(
          barkod: 'KT-00$i',
          renk: KutuRenk.turuncu,
          okumaBolgesi: 'HAT-$i',
          okumaZamani: DateTime.now(),
        ));
      }
      final all = await dao.getAll();
      expect(all.length, equals(3));
    });

    test('getByDurum → yalnızca eşleşen durumu döner', () async {
      await dao.insert(KutuModel(
        barkod: 'KT-A1',
        renk: KutuRenk.turuncu,
        okumaBolgesi: 'HAT-1',
        okumaZamani: DateTime.now(),
        durum: KutuDurum.uretimde,
      ));
      await dao.insert(KutuModel(
        barkod: 'KT-A2',
        renk: KutuRenk.mavi,
        okumaBolgesi: 'HAT-2',
        okumaZamani: DateTime.now(),
        durum: KutuDurum.aracta,
      ));

      final uretimde = await dao.getByDurum(KutuDurum.uretimde);
      expect(uretimde.every((k) => k.durum == KutuDurum.uretimde), isTrue);

      final aracta = await dao.getByDurum(KutuDurum.aracta);
      expect(aracta.every((k) => k.durum == KutuDurum.aracta), isTrue);
    });

    test('duplicate barkod → conflict replace çalışır', () async {
      final kutu = KutuModel(
        barkod: 'KT-DUP',
        renk: KutuRenk.turuncu,
        okumaBolgesi: 'HAT-1',
        okumaZamani: DateTime.now(),
      );
      await dao.insert(kutu);
      // Aynı barkod tekrar eklense replace ile 1 kayıt olmalı
      await dao.insert(kutu.copyWith(okumaBolgesi: 'HAT-2'));
      final all = await dao.getAll();
      expect(all.length, equals(1));
    });
  });
}
