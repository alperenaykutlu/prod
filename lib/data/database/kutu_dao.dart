import 'package:sqflite/sqflite.dart';
import 'package:faurecia/core/constants/app_constants.dart';
import 'package:faurecia/data/models/kutu_model.dart';

class KutuDao {
  final Database db;
  KutuDao(this.db);

  Future<int> insert(KutuModel kutu) async {
    return db.insert(
      DbConstants.kutuTable,
      kutu.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<KutuModel?> getByBarkod(String barkod) async {
    final rows = await db.query(
      DbConstants.kutuTable,
      where: '${DbConstants.colBarkod} = ?',
      whereArgs: [barkod],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return KutuModel.fromMap(rows.first);
  }

  Future<List<KutuModel>> getAll() async {
    final rows = await db.query(
      DbConstants.kutuTable,
      orderBy: '${DbConstants.colZaman} DESC',
    );
    return rows.map(KutuModel.fromMap).toList();
  }

  Future<List<KutuModel>> getByBolge(String bolgeCode) async {
    final rows = await db.query(
      DbConstants.kutuTable,
      where: '${DbConstants.colKutuBolge} = ?',
      whereArgs: [bolgeCode],
      orderBy: '${DbConstants.colZaman} DESC',
    );
    return rows.map(KutuModel.fromMap).toList();
  }

  Future<List<KutuModel>> getByDurum(KutuDurum durum) async {
    final rows = await db.query(
      DbConstants.kutuTable,
      where: '${DbConstants.colKutuDurum} = ?',
      whereArgs: [durum.name],
      orderBy: '${DbConstants.colZaman} DESC',
    );
    return rows.map(KutuModel.fromMap).toList();
  }

Future<int> updateDurum(String barkod, KutuDurum yeniDurum) async {
  return db.update(
    DbConstants.kutuTable,
    {DbConstants.colKutuDurum: yeniDurum.name},
    where: '${DbConstants.colBarkod} = ?',
    whereArgs: [barkod],
  );
}

  Future<int> countByDurum(KutuDurum durum) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM ${DbConstants.kutuTable} WHERE ${DbConstants.colKutuDurum} = ?',
      [durum.name],
    );
    return result.first['cnt'] as int;
  }

  Future<int> countToday() async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).toUtc().toIso8601String();
    final end = DateTime(today.year, today.month, today.day, 23, 59, 59).toUtc().toIso8601String();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM ${DbConstants.kutuTable} WHERE ${DbConstants.colZaman} BETWEEN ? AND ?',
      [start, end],
    );
    return result.first['cnt'] as int;
  }
}
