import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:faurecia/core/constants/app_constants.dart';
import 'package:faurecia/data/database/transfer_dao.dart';
import 'package:faurecia/data/models/transfer_model.dart';

void main() {
  late Database db;
  late TransferDao dao;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, v) async {
          await db.execute('''
            CREATE TABLE ${DbConstants.transferTable} (
              id                INTEGER PRIMARY KEY AUTOINCREMENT,
              arac_id           TEXT NOT NULL,
              kutu_barkod       TEXT NOT NULL,
              yukleme_zamani    TEXT NOT NULL,
              teslim_zamani     TEXT,
              teslim_alindi     INTEGER NOT NULL DEFAULT 0
            )
          ''');
        },
      ),
    );
    dao = TransferDao(db);
  });

  tearDown(() async => db.close());

  group('TransferDao Tests', () {
    test('insert → getActive → teslim alınmamış kayıt döner', () async {
      final transfer = TransferModel(
        aracId: 'A001',
        kutuBarkod: 'KT-0001',
        yuklemeZamani: DateTime.now(),
      );
      await dao.insert(transfer);

      final active = await dao.getActive();
      expect(active.length, equals(1));
      expect(active.first.kutuBarkod, equals('KT-0001'));
      expect(active.first.teslimAlindi, isFalse);
    });

    test('teslimAl → aktif sayısı azalır', () async {
      final t = TransferModel(aracId: 'A002', kutuBarkod: 'KT-0002', yuklemeZamani: DateTime.now());
      final id = await dao.insert(t);

      expect(await dao.countActive(), equals(1));
      await dao.teslimAl(id);
      expect(await dao.countActive(), equals(0));
    });

    test('getByKutuBarkod → doğru transfer döner', () async {
      await dao.insert(TransferModel(aracId: 'A003', kutuBarkod: 'KT-FIND', yuklemeZamani: DateTime.now()));
      final result = await dao.getByKutuBarkod('KT-FIND');
      expect(result, isNotNull);
      expect(result!.aracId, equals('A003'));
    });

    test('getByKutuBarkod → teslim alınanı aramaz', () async {
      final id = await dao.insert(TransferModel(
        aracId: 'A004',
        kutuBarkod: 'KT-DONE',
        yuklemeZamani: DateTime.now(),
      ));
      await dao.teslimAl(id);
      final result = await dao.getByKutuBarkod('KT-DONE');
      expect(result, isNull);
    });

    test('countActive → birden fazla transfer sayar', () async {
      for (var i = 1; i <= 4; i++) {
        await dao.insert(TransferModel(
          aracId: 'A00$i',
          kutuBarkod: 'KT-CNT$i',
          yuklemeZamani: DateTime.now(),
        ));
      }
      expect(await dao.countActive(), equals(4));
    });
  });
}
