import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/utils/validators.dart';

void main() {
  group('requiredText', () {
    String? v(String? s) =>
        Validators.requiredText(s, fieldName: 'Judul', maxLength: 5);

    test('menolak kosong dan hanya spasi', () {
      expect(v(null), isNotNull);
      expect(v(''), isNotNull);
      expect(v('   '), isNotNull);
      expect(Validators.requiredText('  ', fieldName: 'Deskripsi'), isNotNull);
    });

    test('menolak isian yang melebihi batas panjang', () {
      expect(v('abcdef'), isNotNull);
    });

    test('menerima isian valid dan mengabaikan spasi di tepi', () {
      expect(v('  abcde  '), isNull);
    });

    test('tanpa maxLength (TextField) tidak membatasi panjang', () {
      expect(
        Validators.requiredText('a' * 5000, fieldName: 'Deskripsi'),
        isNull,
      );
    });
  });

  group('optionalUrl', () {
    test('kosong dianggap valid', () {
      expect(Validators.optionalUrl(''), isNull);
    });

    test('menolak format URL yang salah', () {
      expect(Validators.optionalUrl('github.com/user'), isNotNull);
      expect(Validators.optionalUrl('ftp://github.com'), isNotNull);
      expect(Validators.optionalUrl('https://localhost'), isNotNull);
    });

    test('menolak URL lebih dari 200 karakter (batas URLField)', () {
      expect(
        Validators.optionalUrl('https://example.com/${'a' * 200}'),
        isNotNull,
      );
    });

    test('menerima URL http/https', () {
      expect(Validators.optionalUrl('https://github.com/adiradmnk'), isNull);
    });
  });

  group('endDate', () {
    final today = DateTime(2026, 11, 23);

    test('tidak wajib jika masih berlangsung', () {
      expect(Validators.endDate(null, isOngoing: true, today: today), isNull);
    });

    test('wajib dipilih jika sudah selesai', () {
      expect(
        Validators.endDate(null, isOngoing: false, today: today),
        isNotNull,
      );
    });

    test('tidak boleh di masa depan', () {
      expect(
        Validators.endDate(
          DateTime(2026, 12, 1),
          isOngoing: false,
          today: today,
        ),
        isNotNull,
      );
      expect(Validators.endDate(today, isOngoing: false, today: today), isNull);
    });
  });
}
