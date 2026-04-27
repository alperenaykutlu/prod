import 'package:faurecia/data/database/app_database.dart';
import 'package:faurecia/data/database/transfer_dao.dart';
import 'package:faurecia/data/models/transfer_model.dart';

class TransferRepository {
  final AppDatabase _db;
  TransferRepository(this._db);

  Future<TransferDao> get _dao async => TransferDao(await _db.database);

  Future<void> aracaYukle({
    required String kutuBarkod,
  }) async {
    final dao = await _dao;
    final transfer = TransferModel(
      aracId: "Araçta",
      kutuBarkod: kutuBarkod,
      yuklemeZamani: DateTime.now(),
    );
    await dao.insert(transfer);
  }

  Future<bool> teslimAl(String kutuBarkod) async {
    final dao = await _dao;
    final transfer = await dao.getByKutuBarkod(kutuBarkod);
    if (transfer == null || transfer.id == null) return false;
    await dao.teslimAl(transfer.id!);
    return true;
  }

  Future<List<TransferModel>> getActive() =>
      _dao.then((d) => d.getActive());

  Future<List<TransferModel>> getAll() =>
      _dao.then((d) => d.getAll());

  Future<int> countActive() =>
      _dao.then((d) => d.countActive());
}
