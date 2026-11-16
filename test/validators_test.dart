import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/utils/validators.dart';

void main() {
  group('requiredText', () {
    String? v(String? s) =>
        Validators.requiredText(s, fieldName: 'Nama', maxLength: 5);

    test('menolak kosong dan hanya spasi', () {
      expect(v(null), isNotNull);
      expect(v(''), isNotNull);
      expect(v('   '), isNotNull);
    });

    test('menolak isian yang melebihi batas panjang', () {
      expect(v('abcdef'), isNotNull);
    });

    test('menerima isian valid dan mengabaikan spasi di tepi', () {
      expect(v('  abcde  '), isNull);
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

    test('menerima URL http/https', () {
      expect(Validators.optionalUrl('https://github.com/adiradmnk'), isNull);
    });
  });

  group('optionalGpa', () {
    test('menolak bukan angka dan di luar 0-4', () {
      expect(Validators.optionalGpa('abc'), isNotNull);
      expect(Validators.optionalGpa('4.5'), isNotNull);
      expect(Validators.optionalGpa('-1'), isNotNull);
    });

    test('menerima titik maupun koma desimal', () {
      expect(Validators.optionalGpa('3.75'), isNull);
      expect(Validators.optionalGpa('3,75'), isNull);
    });
  });

  group('tanggal', () {
    final today = DateTime(2026, 11, 16);

    test('tanggal mulai wajib dan tidak boleh di masa depan', () {
      expect(Validators.startDate(null, today: today), isNotNull);
      expect(
        Validators.startDate(DateTime(2026, 12, 1), today: today),
        isNotNull,
      );
      expect(Validators.startDate(DateTime(2025, 8, 1), today: today), isNull);
    });

    test('tanggal selesai tidak boleh sebelum tanggal mulai', () {
      final start = DateTime(2025, 8, 1);
      expect(
        Validators.endDate(
          DateTime(2025, 1, 1),
          start: start,
          isOngoing: false,
        ),
        isNotNull,
      );
      expect(
        Validators.endDate(null, start: start, isOngoing: false),
        isNotNull,
      );
      expect(Validators.endDate(null, start: start, isOngoing: true), isNull);
      expect(
        Validators.endDate(
          DateTime(2029, 7, 1),
          start: start,
          isOngoing: false,
        ),
        isNull,
      );
    });
  });
}
