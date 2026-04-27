import 'package:flutter/material.dart';

// ─── Enum: Kutu Rengi ───────────────────────────────────────────────────────
enum KutuRenk {
  turuncu('Turuncu', Color(0xFFFF6D00)),
  mavi('Mavi', Color(0xFF1565C0));

  const KutuRenk(this.label, this.color);
  final String label;
  final Color color;

  static KutuRenk fromString(String s) =>
      KutuRenk.values.firstWhere((e) => e.name == s, orElse: () => KutuRenk.turuncu);
}

// ─── Enum: Çuval Rengi ──────────────────────────────────────────────────────
enum CuvalRenk {
  sari('Sarı', Color(0xFFFFD600)),
  mavi('Mavi', Color(0xFF1565C0));

  const CuvalRenk(this.label, this.color);
  final String label;
  final Color color;

  static CuvalRenk fromString(String s) =>
      CuvalRenk.values.firstWhere((e) => e.name == s, orElse: () => CuvalRenk.sari);

  /// Turuncu kutu → Sarı çuval, Mavi kutu → Mavi çuval
  static CuvalRenk fromKutuRenk(KutuRenk kutuRenk) =>
      kutuRenk == KutuRenk.turuncu ? CuvalRenk.sari : CuvalRenk.mavi;
}

// ─── Enum: Bölge ────────────────────────────────────────────────────────────
enum Bolge {
  uretim('Üretim Bölgesi', 'URETIM'),
  arac('Araç / Taşıma', 'ARAC'),
  kirilma('Kırılma Bölgesi', 'KIRILMA'),
  silo('Silo Bölgesi', 'SILO');

  const Bolge(this.label, this.code);
  final String label;
  final String code;

  static Bolge fromCode(String code) =>
      Bolge.values.firstWhere((e) => e.code == code, orElse: () => Bolge.uretim);
}

// ─── Enum: İşlem Tipi ───────────────────────────────────────────────────────
enum IslemTipi {
  kutuOkuma('Kutu Okuma'),
  aracaYukleme('Araca Yükleme'),
  kirilmaTeslimAlma('Kırılma Teslim Alma'),
  cuvalOkuma('Çuval Okuma'),
  siloTeslimAlma('Silo Teslim Alma');

  const IslemTipi(this.label);
  final String label;

  static IslemTipi fromString(String s) =>
      IslemTipi.values.firstWhere((e) => e.name == s, orElse: () => IslemTipi.kutuOkuma);
}

// ─── Enum: Kutu Durumu ───────────────────────────────────────────────────────
enum KutuDurum {
  uretimde('Üretimde', Color(0xFF43A047)),
  aracta('Araçta', Color(0xFFFF8F00)),
  kirilmada('Kırılmada', Color(0xFF1E88E5)),
  tamamlandi('Tamamlandı', Color(0xFF6D4C41));

  const KutuDurum(this.label, this.color);
  final String label;
  final Color color;

  static KutuDurum fromString(String s) =>
      KutuDurum.values.firstWhere((e) => e.name == s, orElse: () => KutuDurum.uretimde);
}

// ─── Enum: Çuval Durumu ──────────────────────────────────────────────────────
enum CuvalDurum {
  olusturuldu('Oluşturuldu', Color(0xFF43A047)),
  sevkte('Sevkte', Color(0xFFFF8F00)),
  siloda('Siloda', Color(0xFF6D4C41));

  const CuvalDurum(this.label, this.color);
  final String label;
  final Color color;

  static CuvalDurum fromString(String s) =>
      CuvalDurum.values.firstWhere((e) => e.name == s, orElse: () => CuvalDurum.olusturuldu);
}

// ─── RF Gun Numaraları ───────────────────────────────────────────────────────
class RfGun {
  static const int uretim = 1;
  static const int kirilma = 2;
  static const int silo = 3;

  static String label(int no) {
    switch (no) {
      case 1: return 'RF Gun 1 – Üretim Bölgesi';
      case 2: return 'RF Gun 2 – Kırılma Bölgesi';
      case 3: return 'RF Gun 3 – Silo Bölgesi';
      default: return 'RF Gun $no';
    }
  }
}

// ─── DB Tablo & Kolon Sabitleri ──────────────────────────────────────────────
class DbConstants {
  // Tables
  static const String kutuTable = 'kutular';
  static const String cuvalTable = 'cuvallar';
  static const String transferTable = 'transferler';
  static const String islemKayitTable = 'islem_kayitlari';

  // Common
  static const String colId = 'id';
  static const String colBarkod = 'barkod';
  static const String colZaman = 'zaman';

  // Kutu
  static const String colKutuRenk = 'renk';
  static const String colKutuBolge = 'bolge';
  static const String colKutuDurum = 'durum';
  static const String colKutuAracId = 'arac_id';

  // Cuval
  static const String colCuvalRenk = 'renk';
  static const String colCuvalKutuBarkod = 'kutu_barkod';
  static const String colCuvalDurum = 'durum';

  // Transfer
  static const String colTransferAracId = 'arac_id';
  static const String colTransferKutuBarkod = 'kutu_barkod';
  static const String colTransferYuklemeZamani = 'yukleme_zamani';
  static const String colTransferTeslimZamani = 'teslim_zamani';
  static const String colTransferTeslimAlindi = 'teslim_alindi';

  // İşlem Kayıt
  static const String colIslemTip = 'tip';
  static const String colIslemBolge = 'bolge';
  static const String colIslemRfGunNo = 'rf_gun_no';
  static const String colIslemAciklama = 'aciklama';
}
