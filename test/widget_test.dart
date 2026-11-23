import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';

/// Ukuran layar selebar ponsel agar pengujian mencakup layar sempit.
Future<void> _usePhoneSize(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> _openDrawerItem(WidgetTester tester, String label) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Halaman menu menampilkan identitas dan tombol aksi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(find.text('2506656375'), findsOneWidget);
    expect(find.text('PBP E'), findsOneWidget);
    expect(find.text('Lihat Proyek'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Tambah Pengalaman'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('Menekan tombol aksi menampilkan SnackBar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Lihat Proyek'));
    await tester.pump();

    expect(
      find.text('Kamu telah menekan tombol Lihat Proyek!'),
      findsOneWidget,
    );
  });

  testWidgets('Kartu Tambah Pengalaman membuka formulir dan bisa kembali', (
    WidgetTester tester,
  ) async {
    await _usePhoneSize(tester);
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Tambah Pengalaman'));
    await tester.pumpAndSettle();
    expect(find.text('Judul Pengalaman'), findsOneWidget);

    // Simulasi tombol kembali bawaan perangkat (Android back button).
    // Bisa kembali karena formulir dibuka dengan Navigator.push().
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('2506656375'), findsOneWidget);
  });

  testWidgets('Drawer membuka formulir dan opsi Home kembali ke menu', (
    WidgetTester tester,
  ) async {
    await _usePhoneSize(tester);
    await tester.pumpWidget(const MyApp());

    await _openDrawerItem(tester, 'Add Experience');
    expect(find.text('Judul Pengalaman'), findsOneWidget);

    await _openDrawerItem(tester, 'Add Project');
    expect(find.text('Nama Proyek'), findsOneWidget);

    await _openDrawerItem(tester, 'Home');
    expect(find.text('2506656375'), findsOneWidget);
  });

  testWidgets(
    'Formulir pengalaman menolak input kosong lalu menampilkan dialog',
    (WidgetTester tester) async {
      await _usePhoneSize(tester);
      await tester.pumpWidget(const MyApp());
      await _openDrawerItem(tester, 'Add Experience');

      final save = find.text('Simpan');

      // Input tidak valid: judul hanya spasi, deskripsi dan tanggal kosong.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Judul Pengalaman'),
        '   ',
      );
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.text('Judul pengalaman tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Deskripsi tidak boleh kosong!'), findsOneWidget);
      expect(
        find.text('Pilih tanggal selesai atau tandai "Masih berlangsung"!'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);

      // Input valid.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Judul Pengalaman'),
        'Software Engineer Intern',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Deskripsi'),
        'Membangun fitur aplikasi mobile.',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'URL Thumbnail / Logo (opsional)'),
        'https://github.com/adiradmnk',
      );
      await tester.ensureVisible(find.text('Masih berlangsung'));
      await tester.tap(find.text('Masih berlangsung'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();

      Finder inDialog(String text) => find.descendant(
        of: find.byType(AlertDialog),
        matching: find.textContaining(text, findRichText: true),
      );
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        inDialog('Judul Pengalaman: Software Engineer Intern'),
        findsOneWidget,
      );
      expect(inDialog('Kategori: Full-Time'), findsOneWidget);
      expect(inDialog('Tanggal Selesai: Masih berlangsung'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Add Experience Form'), findsOneWidget);
    },
  );

  testWidgets('Formulir proyek menolak URL tidak valid', (
    WidgetTester tester,
  ) async {
    await _usePhoneSize(tester);
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama Proyek'),
      'MyPortfolio',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Peran / Posisi'),
      'Fullstack Developer',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Deskripsi Proyek'),
      'Website portofolio pribadi berbasis Django.',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tautan Proyek'),
      'github.com/adiradmnk',
    );

    final save = find.text('Simpan');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tautan Proyek'),
      'https://github.com/adiradmnk',
    );
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.textContaining(
          'Nama Proyek: MyPortfolio',
          findRichText: true,
        ),
      ),
      findsOneWidget,
    );
  });
}
