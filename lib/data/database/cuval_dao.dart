import 'package:sqflite/sqflite.dart';
import 'package:faurecia/core/constants/app_constants.dart';
import 'package:faurecia/data/models/cuval_model.dart';

class CuvalDao {
  final Database db;
  CuvalDao(this.db);

  Future<int> insert(CuvalModel cuval) async {
    return db.insert(
      DbConstants.cuvalTable,
      cuval.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<CuvalModel?> getByBarkod(String barkod) async {
    final rows = await db.query(
      DbConstants.cuvalTable,
      where: '${DbConstants.colBarkod} = ?',
      whereArgs: [barkod],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return CuvalModel.fromMap(rows.first);
  }

  Future<List<CuvalModel>> getAll() async {
    final rows = await db.query(
      DbConstants.cuvalTable,
      orderBy: '${DbConstants.colZaman} DESC',
    );
    return rows.map(CuvalModel.fromMap).toList();
  }

  Future<List<CuvalModel>> getByDurum(CuvalDurum durum) async {
    final rows = await db.query(
      DbConstants.cuvalTable,
      where: '${DbConstants.colCuvalDurum} = ?',
      whereArgs: [durum.name],
      orderBy: '${DbConstants.colZaman} DESC',
    );
    return rows.map(CuvalModel.fromMap).toList();
  }

  Future<int> updateDurum(String barkod, CuvalDurum yeniDurum) async {
    return db.update(
      DbConstants.cuvalTable,
      {DbConstants.colCuvalDurum: yeniDurum.name},
      where: '${DbConstants.colBarkod} = ?',
      whereArgs: [barkod],
    );
  }

  Future<int> countToday() async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).toUtc().toIso8601String();
    final end = DateTime(today.year, today.month, today.day, 23, 59, 59).toUtc().toIso8601String();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM ${DbConstants.cuvalTable} WHERE ${DbConstants.colZaman} BETWEEN ? AND ?',
      [start, end],
    );
    return result.first['cnt'] as int;
  }
}
