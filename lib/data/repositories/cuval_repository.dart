import 'package:faurecia/core/constants/app_constants.dart';
import 'package:faurecia/data/database/app_database.dart';
import 'package:faurecia/data/database/cuval_dao.dart';
import 'package:faurecia/data/database/islem_kayit_dao.dart';
import 'package:faurecia/data/models/cuval_model.dart';
import 'package:faurecia/data/models/islem_kayit_model.dart';

class CuvalRepository {
  final AppDatabase _db;
  CuvalRepository(this._db);

  Future<CuvalDao> get _dao async => CuvalDao(await _db.database);
  Future<IslemKayitDao> get _logDao async => IslemKayitDao(await _db.database);

  /// RF Gun 2: Kırılma bölgesinde çuval barkodunu kaydet
  Future<void> cuvalOku({
    required String barkod,
    required CuvalRenk renk,
    required String kutuBarkod,
    required int rfGunNo,
  }) async {
    final dao = await _dao;
    final logDao = await _logDao;
    final now = DateTime.now();

    final cuval = CuvalModel(
      barkod: barkod,
      renk: renk,
      kutuBarkod: kutuBarkod,
      olusturmaZamani: now,
      durum: CuvalDurum.olusturuldu,
    );
    await dao.insert(cuval);

    await logDao.insert(IslemKayitModel(
      tip: IslemTipi.cuvalOkuma,
      barkod: barkod,
      bolge: Bolge.kirilma,
      rfGunNo: rfGunNo,
      zaman: now,
      aciklama: '${renk.label} çuval – Kutu: $kutuBarkod',
    ));
  }

  /// RF Gun 3: Silo bölgesinde çuval teslim alındı
  Future<void> siloTeslimAl({
    required String barkod,
    required int rfGunNo,
  }) async {
    final dao = await _dao;
    final logDao = await _logDao;
    await dao.updateDurum(barkod, CuvalDurum.siloda);
    await logDao.insert(IslemKayitModel(
      tip: IslemTipi.siloTeslimAlma,
      barkod: barkod,
      bolge: Bolge.silo,
      rfGunNo: rfGunNo,
      zaman: DateTime.now(),
      aciklama: 'Silo teslim alındı',
    ));
  }

  Future<CuvalModel?> getByBarkod(String barkod) =>
      _dao.then((d) => d.getByBarkod(barkod));

  Future<List<CuvalModel>> getAll() =>
      _dao.then((d) => d.getAll());

  Future<List<CuvalModel>> getByDurum(CuvalDurum durum) =>
      _dao.then((d) => d.getByDurum(durum));

  Future<int> countToday() =>
      _dao.then((d) => d.countToday());
}
