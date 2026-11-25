import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';

import 'helpers/fake_backend.dart';

/// Ukuran layar selebar ponsel agar pengujian mencakup layar sempit.
Future<void> _usePhoneSize(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<FakeBackend> _pumpApp(WidgetTester tester) async {
  await _usePhoneSize(tester);
  final backend = FakeBackend();
  await tester.pumpWidget(MyApp(apiClient: backend.client));
  return backend;
}

Future<void> _openDrawerItem(WidgetTester tester, String label) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// Mengisi dan mengirim [LoginScreen].
Future<void> _login(
  WidgetTester tester, {
  String password = FakeBackend.password,
}) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Username'),
    FakeBackend.username,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Password'),
    password,
  );
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();
}

Finder _inDialog(String text) => find.descendant(
  of: find.byType(AlertDialog),
  matching: find.textContaining(text, findRichText: true),
);

void main() {
  testWidgets('Halaman menu menampilkan identitas dan tombol aksi', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester);

    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(find.text('2506656375'), findsOneWidget);
    expect(find.text('Adriana Ainurrahmah Damanik'), findsOneWidget);
    expect(find.text('PBP E'), findsOneWidget);
    expect(find.text('Lihat Proyek'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Tambah Pengalaman'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('Lihat Proyek menampilkan data API tanpa login dan detailnya', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Lihat Proyek'));
    await tester.pump();
    expect(
      find.text('Kamu telah menekan tombol Lihat Proyek!'),
      findsOneWidget,
    );
    await tester.pumpAndSettle();

    expect(find.text('Daftar Proyek'), findsOneWidget);
    expect(find.text('MyPortfolio Web'), findsOneWidget);

    await tester.tap(find.text('MyPortfolio Web'));
    await tester.pumpAndSettle();
    expect(find.text('Detail Proyek'), findsOneWidget);
    expect(find.text('Fullstack Developer'), findsOneWidget);
    expect(find.text('2 bintang'), findsOneWidget);
  });

  testWidgets('Daftar proyek menampilkan pesan ramah dan tombol Coba Lagi', (
    WidgetTester tester,
  ) async {
    final backend = await _pumpApp(tester);
    backend.failProjects = true;

    await _openDrawerItem(tester, 'Project List');
    expect(find.textContaining('Server sedang bermasalah'), findsOneWidget);
    // Body HTML mentah dari server tidak ditampilkan ke pengguna.
    expect(find.textContaining('<h1>'), findsNothing);

    backend.failProjects = false;
    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();
    expect(find.text('MyPortfolio Web'), findsOneWidget);
  });

  testWidgets('Tambah Proyek tanpa login diarahkan ke layar login', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    // Login kosong ditolak validator.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.text('Username tidak boleh kosong!'), findsOneWidget);

    // Password salah: 400 dari DRF ditampilkan di SnackBar.
    await _login(tester, password: 'salah');
    expect(find.textContaining('Login gagal (400)'), findsOneWidget);

    // Login benar: langsung masuk ke formulir.
    await _login(tester);
    expect(find.text('Add Project Form'), findsOneWidget);

    // Kembali ke menu dengan tombol kembali perangkat.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('2506656375'), findsOneWidget);

    // Sudah login: formulir langsung terbuka tanpa layar login.
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(find.text('Add Project Form'), findsOneWidget);
  });

  testWidgets('Formulir proyek memvalidasi lalu POST ke API (201)', (
    WidgetTester tester,
  ) async {
    final backend = await _pumpApp(tester);
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    await _login(tester);

    final save = find.text('Simpan');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Link Proyek (opsional)'),
      'github.com/adiradmnk',
    );
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Peran / posisi tidak boleh kosong!'), findsOneWidget);
    expect(find.textContaining('Masukkan URL yang valid'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama Proyek'),
      'MyPortfolio Mobile',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Peran / Posisi'),
      'Mobile Developer',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Deskripsi Proyek'),
      'Aplikasi Flutter portofolio.',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Link Proyek (opsional)'),
      'https://github.com/adiradmnk/myportofolio_mobile',
    );
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(_inDialog('Nama Proyek: MyPortfolio Mobile'), findsOneWidget);
    expect(_inDialog('Peran / Posisi: Mobile Developer'), findsOneWidget);
    expect(backend.projects, hasLength(2));
    expect(
      backend.requests.last.headers['Authorization'],
      'Token ${FakeBackend.validToken}',
    );

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('POST dengan token kedaluwarsa (401) meminta login ulang', (
    WidgetTester tester,
  ) async {
    final backend = await _pumpApp(tester);
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    await _login(tester);

    // Token dicabut di server (mis. logout dari perangkat lain).
    backend.activeTokens.clear();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama Proyek'),
      'Proyek',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Peran / Posisi'),
      'Dev',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Deskripsi Proyek'),
      'Deskripsi',
    );
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.textContaining('Silakan login ulang'), findsOneWidget);
  });

  testWidgets('Drawer: guard Add Experience, Login/Logout, dan Home', (
    WidgetTester tester,
  ) async {
    final backend = await _pumpApp(tester);

    await _openDrawerItem(tester, 'Add Experience');
    await _login(tester);
    expect(find.text('Add Experience Form'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Login'), findsNothing);
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    // Setelah logout dari halaman terlindungi, pengguna dikembalikan ke Home.
    expect(find.text('Kamu berhasil logout.'), findsOneWidget);
    expect(find.text('2506656375'), findsOneWidget);
    expect(backend.activeTokens, isEmpty);

    await _openDrawerItem(tester, 'Project List');
    expect(find.text('Daftar Proyek'), findsOneWidget);
    await _openDrawerItem(tester, 'Home');
    expect(find.text('2506656375'), findsOneWidget);
  });

  testWidgets('Kartu Logout mencabut token', (WidgetTester tester) async {
    final backend = await _pumpApp(tester);

    await tester.tap(find.text('Logout'));
    await tester.pump();
    expect(find.text('Kamu belum login.'), findsOneWidget);

    await _openDrawerItem(tester, 'Login');
    await _login(tester);
    expect(find.text('Login berhasil!'), findsOneWidget);

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Berhasil logout'), findsOneWidget);
    expect(backend.activeTokens, isEmpty);
  });

  testWidgets(
    'Formulir pengalaman menolak input kosong lalu menampilkan dialog',
    (WidgetTester tester) async {
      await _pumpApp(tester);
      await tester.tap(find.text('Tambah Pengalaman'));
      await tester.pumpAndSettle();
      await _login(tester);

      final save = find.text('Simpan');

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

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Judul Pengalaman'),
        'Software Engineer Intern',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Deskripsi'),
        'Membangun fitur aplikasi mobile.',
      );
      await tester.ensureVisible(find.text('Masih berlangsung'));
      await tester.tap(find.text('Masih berlangsung'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();

      expect(
        _inDialog('Judul Pengalaman: Software Engineer Intern'),
        findsOneWidget,
      );
      expect(_inDialog('Kategori: Full-Time'), findsOneWidget);
      expect(_inDialog('Tanggal Selesai: Masih berlangsung'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Add Experience Form'), findsOneWidget);
    },
  );
}
