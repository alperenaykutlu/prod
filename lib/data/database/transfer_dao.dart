import 'package:sqflite/sqflite.dart';
import 'package:faurecia/core/constants/app_constants.dart';
import 'package:faurecia/data/models/transfer_model.dart';

class TransferDao {
  final Database db;
  TransferDao(this.db);

  Future<int> insert(TransferModel transfer) async {
    return db.insert(DbConstants.transferTable, transfer.toMap());
  }

  Future<List<TransferModel>> getActive() async {
    final rows = await db.query(
      DbConstants.transferTable,
      where: '${DbConstants.colTransferTeslimAlindi} = ?',
      whereArgs: [0],
      orderBy: '${DbConstants.colTransferYuklemeZamani} DESC',
    );
    return rows.map(TransferModel.fromMap).toList();
  }

  Future<List<TransferModel>> getAll() async {
    final rows = await db.query(
      DbConstants.transferTable,
      orderBy: '${DbConstants.colTransferYuklemeZamani} DESC',
    );
    return rows.map(TransferModel.fromMap).toList();
  }

  Future<TransferModel?> getByKutuBarkod(String kutuBarkod) async {
    final rows = await db.query(
      DbConstants.transferTable,
      where: '${DbConstants.colTransferKutuBarkod} = ? AND ${DbConstants.colTransferTeslimAlindi} = 0',
      whereArgs: [kutuBarkod],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return TransferModel.fromMap(rows.first);
  }

  Future<int> teslimAl(int transferId) async {
    return db.update(
      DbConstants.transferTable,
      {
        DbConstants.colTransferTeslimAlindi: 1,
        DbConstants.colTransferTeslimZamani: DateTime.now().toUtc().toIso8601String(),
      },
      where: '${DbConstants.colId} = ?',
      whereArgs: [transferId],
    );
  }

  Future<int> countActive() async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM ${DbConstants.transferTable} WHERE ${DbConstants.colTransferTeslimAlindi} = 0',
    );
    return result.first['cnt'] as int;
  }
}
