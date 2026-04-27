import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:faurecia/core/constants/app_constants.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'faurecia.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Kutular tablosu
    await db.execute('''
      CREATE TABLE ${DbConstants.kutuTable} (
        ${DbConstants.colId}          INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colBarkod}      TEXT    NOT NULL UNIQUE,
        ${DbConstants.colKutuRenk}    TEXT    NOT NULL,
        ${DbConstants.colKutuBolge}   TEXT    NOT NULL,
        ${DbConstants.colZaman}       TEXT    NOT NULL,
        ${DbConstants.colKutuDurum}   TEXT    NOT NULL DEFAULT 'uretimde',
        ${DbConstants.colKutuAracId}  TEXT
      )
    ''');

    // Çuvallar tablosu
    await db.execute('''
      CREATE TABLE ${DbConstants.cuvalTable} (
        ${DbConstants.colId}                INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colBarkod}            TEXT    NOT NULL UNIQUE,
        ${DbConstants.colCuvalRenk}         TEXT    NOT NULL,
        ${DbConstants.colCuvalKutuBarkod}   TEXT    NOT NULL,
        ${DbConstants.colZaman}             TEXT    NOT NULL,
        ${DbConstants.colCuvalDurum}        TEXT    NOT NULL DEFAULT 'olusturuldu',
        FOREIGN KEY(${DbConstants.colCuvalKutuBarkod}) 
          REFERENCES ${DbConstants.kutuTable}(${DbConstants.colBarkod})
      )
    ''');

    // Transferler tablosu
    await db.execute('''
      CREATE TABLE ${DbConstants.transferTable} (
        ${DbConstants.colId}                      INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colTransferAracId}           TEXT    NOT NULL,
        ${DbConstants.colTransferKutuBarkod}       TEXT    NOT NULL,
        ${DbConstants.colTransferYuklemeZamani}    TEXT    NOT NULL,
        ${DbConstants.colTransferTeslimZamani}     TEXT,
        ${DbConstants.colTransferTeslimAlindi}     INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(${DbConstants.colTransferKutuBarkod}) 
          REFERENCES ${DbConstants.kutuTable}(${DbConstants.colBarkod})
      )
    ''');

    // İşlem kayıtları tablosu (audit log)
    await db.execute('''
      CREATE TABLE ${DbConstants.islemKayitTable} (
        ${DbConstants.colId}            INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colIslemTip}      TEXT    NOT NULL,
        ${DbConstants.colBarkod}        TEXT    NOT NULL,
        ${DbConstants.colIslemBolge}    TEXT    NOT NULL,
        ${DbConstants.colIslemRfGunNo}  INTEGER NOT NULL,
        ${DbConstants.colZaman}         TEXT    NOT NULL,
        ${DbConstants.colIslemAciklama} TEXT
      )
    ''');

    // İndeksler
    await db.execute('CREATE INDEX idx_kutu_barkod ON ${DbConstants.kutuTable}(${DbConstants.colBarkod})');
    await db.execute('CREATE INDEX idx_cuval_barkod ON ${DbConstants.cuvalTable}(${DbConstants.colBarkod})');
    await db.execute('CREATE INDEX idx_islem_gun ON ${DbConstants.islemKayitTable}(${DbConstants.colIslemRfGunNo})');
    await db.execute('CREATE INDEX idx_islem_bolge ON ${DbConstants.islemKayitTable}(${DbConstants.colIslemBolge})');
  }

  /// Test için: veritabanını sıfırla
  Future<void> resetForTest() async {
    final db = await database;
    await db.delete(DbConstants.islemKayitTable);
    await db.delete(DbConstants.transferTable);
    await db.delete(DbConstants.cuvalTable);
    await db.delete(DbConstants.kutuTable);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
