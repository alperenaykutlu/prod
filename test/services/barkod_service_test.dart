import 'package:flutter_test/flutter_test.dart';
import 'package:faurecia/core/constants/app_constants.dart';
import 'package:faurecia/services/datawedge_service.dart';

void main() {
  group('BarkodService Tests', () {
    test('isKutuBarkod → KT- prefix tanır', () {
      expect(BarkodService.isKutuBarkod('KT-0001'), isTrue);
      expect(BarkodService.isKutuBarkod('BOX-999'), isTrue);
      expect(BarkodService.isKutuBarkod('K00123'), isTrue);
    });

    test('isCuvalBarkod → CV- prefix tanır', () {
      expect(BarkodService.isCuvalBarkod('CV-0001'), isTrue);
      expect(BarkodService.isCuvalBarkod('SAC-999'), isTrue);
      expect(BarkodService.isCuvalBarkod('C00123'), isTrue);
    });

    test('isKutuBarkod → çuval barkodunu reddeder', () {
      expect(BarkodService.isKutuBarkod('CV-0001'), isFalse);
    });

    test('isCuvalBarkod → kutu barkodunu reddeder', () {
      expect(BarkodService.isCuvalBarkod('KT-0001'), isFalse);
    });

    test('normalize → büyük harfe dönüştürür ve boşluk keser', () {
      expect(BarkodService.normalize('  kt-0001  '), equals('KT-0001'));
      expect(BarkodService.normalize('cv-0099'), equals('CV-0099'));
    });

    test('isValid → geçerli barkodlar için true döner', () {
      expect(BarkodService.isValid('KT-001'), isTrue);
      expect(BarkodService.isValid('CV-001'), isTrue);
    });

    test('isValid → kısa barkod için false döner', () {
      expect(BarkodService.isValid('AB'), isFalse);
      expect(BarkodService.isValid(''), isFalse);
    });
  });

  group('Enum / Constant Tests', () {
    test('RfGun.label → doğru etiket döner', () {
      expect(RfGun.label(1), contains('Üretim'));
      expect(RfGun.label(2), contains('Kırılma'));
      expect(RfGun.label(3), contains('Silo'));
    });

    test('Bolge.fromCode → geçersiz kod varsayılanı döner', () {
      expect(Bolge.fromCode('UNKNOWN'), equals(Bolge.uretim));
    });

    test('IslemTipi.fromString → tüm tipler çözümlenir', () {
      for (final tip in IslemTipi.values) {
        expect(IslemTipi.fromString(tip.name), equals(tip));
      }
    });

    test('KutuDurum.fromString → tüm durumlar çözümlenir', () {
      for (final durum in KutuDurum.values) {
        expect(KutuDurum.fromString(durum.name), equals(durum));
      }
    });

    test('CuvalDurum.fromString → tüm durumlar çözümlenir', () {
      for (final durum in CuvalDurum.values) {
        expect(CuvalDurum.fromString(durum.name), equals(durum));
      }
    });
  });
}
