import 'package:sqflite/sqflite.dart';
import 'package:faurecia/core/constants/app_constants.dart';
import 'package:faurecia/data/models/islem_kayit_model.dart';

class IslemKayitDao {
  final Database db;
  IslemKayitDao(this.db);

  Future<int> insert(IslemKayitModel kayit) async {
    return db.insert(DbConstants.islemKayitTable, kayit.toMap());
  }

  Future<List<IslemKayitModel>> getAll({int limit = 100}) async {
    final rows = await db.query(
      DbConstants.islemKayitTable,
      orderBy: '${DbConstants.colZaman} DESC',
      limit: limit,
    );
    return rows.map(IslemKayitModel.fromMap).toList();
  }

  Future<List<IslemKayitModel>> getByRfGun(int rfGunNo, {int limit = 50}) async {
    final rows = await db.query(
      DbConstants.islemKayitTable,
      where: '${DbConstants.colIslemRfGunNo} = ?',
      whereArgs: [rfGunNo],
      orderBy: '${DbConstants.colZaman} DESC',
      limit: limit,
    );
    return rows.map(IslemKayitModel.fromMap).toList();
  }

  Future<List<IslemKayitModel>> getByBolge(String bolgeCode, {int limit = 50}) async {
    final rows = await db.query(
      DbConstants.islemKayitTable,
      where: '${DbConstants.colIslemBolge} = ?',
      whereArgs: [bolgeCode],
      orderBy: '${DbConstants.colZaman} DESC',
      limit: limit,
    );
    return rows.map(IslemKayitModel.fromMap).toList();
  }

  Future<List<IslemKayitModel>> getByDateRange(DateTime from, DateTime to) async {
    final rows = await db.query(
      DbConstants.islemKayitTable,
      where: '${DbConstants.colZaman} BETWEEN ? AND ?',
      whereArgs: [from.toUtc().toIso8601String(), to.toUtc().toIso8601String()],
      orderBy: '${DbConstants.colZaman} DESC',
    );
    return rows.map(IslemKayitModel.fromMap).toList();
  }

  Future<int> countToday() async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).toUtc().toIso8601String();
    final end = DateTime(today.year, today.month, today.day, 23, 59, 59).toUtc().toIso8601String();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM ${DbConstants.islemKayitTable} WHERE ${DbConstants.colZaman} BETWEEN ? AND ?',
      [start, end],
    );
    return result.first['cnt'] as int;
  }
}
