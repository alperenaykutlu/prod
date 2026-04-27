import 'package:faurecia/core/constants/app_constants.dart';
import 'package:faurecia/data/database/app_database.dart';
import 'package:faurecia/data/database/kutu_dao.dart';
import 'package:faurecia/data/database/islem_kayit_dao.dart';
import 'package:faurecia/data/models/kutu_model.dart';
import 'package:faurecia/data/models/islem_kayit_model.dart';

class KutuRepository {
  final AppDatabase _db;

  KutuRepository(this._db);

  Future<KutuDao> get _dao async => KutuDao(await _db.database);
  Future<IslemKayitDao> get _logDao async => IslemKayitDao(await _db.database);

  /// RF Gun 1: Üretim bölgesinde kutu barkodunu kaydet
  Future<void> kutuOku({
    required String barkod,
    required KutuRenk renk,
    required String bolge,
    required int rfGunNo,
  }) async {
    final dao = await _dao;
    final logDao = await _logDao;
    final now = DateTime.now();

    // Zaten kayıtlıysa üstüne yazma, sadece loglama yap
    final mevcut = await dao.getByBarkod(barkod);
    if (mevcut == null) {
      final kutu = KutuModel(
        barkod: barkod,
        renk: renk,
        okumaBolgesi: bolge,
        okumaZamani: now,
        durum: KutuDurum.uretimde,
      );
      await dao.insert(kutu);
    }

    await logDao.insert(IslemKayitModel(
      tip: IslemTipi.kutuOkuma,
      barkod: barkod,
      bolge: Bolge.uretim,
      rfGunNo: rfGunNo,
      zaman: now,
      aciklama: '${renk.label} kutu – $bolge',
    ));
  }

  /// RF Gun 1: Kutuyu araca yükle
  Future<void> aracaYukle({
    required String barkod,
    required int rfGunNo,
  }) async {
    final dao = await _dao;
    final logDao = await _logDao;
    await dao.updateDurum(barkod, KutuDurum.aracta);
    await logDao.insert(IslemKayitModel(
      tip: IslemTipi.aracaYukleme,
      barkod: barkod,
      bolge: Bolge.arac,
      rfGunNo: rfGunNo,
      zaman: DateTime.now(),
      aciklama: 'Araca Yüklendi',
    ));
  }

  /// RF Gun 2: Kırılma bölgesine kutu teslim alındı
  Future<void> kirilmaTeslimAl({
    required String barkod,
    required int rfGunNo,
  }) async {
    final dao = await _dao;
    final logDao = await _logDao;
    await dao.updateDurum(barkod, KutuDurum.kirilmada);
    await logDao.insert(IslemKayitModel(
      tip: IslemTipi.kirilmaTeslimAlma,
      barkod: barkod,
      bolge: Bolge.kirilma,
      rfGunNo: rfGunNo,
      zaman: DateTime.now(),
      aciklama: 'Kırılma bölgesi teslim alındı',
    ));
  }

  /// RF Gun 2: Çuvala aktarıldı, kutu üretime geri döner
  Future<void> uretimeGonder({
    required String barkod,
    required int rfGunNo,
  }) async {
    final dao = await _dao;
    final logDao = await _logDao;
    await dao.updateDurum(barkod, KutuDurum.uretimde);
    await logDao.insert(IslemKayitModel(
      tip: IslemTipi.kutuOkuma,
      barkod: barkod,
      bolge: Bolge.kirilma,
      rfGunNo: rfGunNo,
      zaman: DateTime.now(),
      aciklama: 'Çuvala aktarıldı – üretime döndü',
    ));
  }

  Future<KutuModel?> getByBarkod(String barkod) =>
      _dao.then((d) => d.getByBarkod(barkod));

  Future<List<KutuModel>> getAll() =>
      _dao.then((d) => d.getAll());

  Future<List<KutuModel>> getByBolge(String bolgeCode) =>
      _dao.then((d) => d.getByBolge(bolgeCode));

  Future<List<KutuModel>> getByDurum(KutuDurum durum) =>
      _dao.then((d) => d.getByDurum(durum));

  Future<int> countToday() =>
      _dao.then((d) => d.countToday());
}