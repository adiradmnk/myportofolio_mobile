# MyPortfolio Mobile

Aplikasi mobile Flutter untuk portofolio pribadi milik **Adriana Ainurrahmah Damanik** (NPM 2506656375, kelas PBP E). Aplikasi ini adalah perluasan dari website portofolio Django ke ranah mobile, dikerjakan untuk mata kuliah Pemrograman Berbasis Platform (PBP) Fasilkom UI, Gasal 2026/2027.

## Fitur Saat Ini

- Halaman utama (`MyHomePage`) berupa `StatelessWidget` yang dipisah ke `lib/menu.dart`, sedangkan `lib/main.dart` hanya berisi bootstrap aplikasi (`MyApp`).
- Tiga `InfoCard` di bagian atas yang menampilkan NPM, Name, dan Class.
- Tiga `ItemCard` dalam `GridView` dengan warna latar berbeda:
  - **Lihat Proyek** (`Icons.folder`, biru)
  - **Tambah Proyek** (`Icons.add_circle`, hijau)
  - **Logout** (`Icons.logout`, merah)
- Setiap tombol menampilkan `SnackBar` bertuliskan "Kamu telah menekan tombol [Nama Tombol]!".
- Warna tombol disimpan di model `ItemHomepage` (`name`, `icon`, `color`), sehingga `ItemCard` cukup memakai `item.color` tanpa percabangan.
- Widget test di `test/widget_test.dart` untuk memastikan identitas, tombol, dan SnackBar tampil.

## Struktur Proyek

```
lib/
├── main.dart   # MyApp: MaterialApp + tema (seed color indigo)
└── menu.dart   # MyHomePage, InfoCard, ItemHomepage, ItemCard
test/
└── widget_test.dart
```

## Cara Menjalankan

```bash
git clone https://github.com/adiradmnk/myportofolio_mobile.git
cd myportofolio_mobile
flutter pub get
flutter run
```

Pemeriksaan kualitas kode dan test:

```bash
flutter analyze
flutter test
```

## Progres Mingguan

| Minggu | Tugas | Progres |
| --- | --- | --- |
| Tutorial 08 | Basic Flutter | Inisialisasi proyek, pemisahan `menu.dart`, `MyHomePage` menjadi `StatelessWidget`, `InfoCard` & `ItemCard`, SnackBar |
| Tugas 7 | Basic Flutter | Data profil asli, warna unik per tombol via atribut `color` di `ItemHomepage`, dokumentasi kode, README & jawaban reflektif |

## AI Disclosure

- **Tools:** Claude (Anthropic).
- **Bagian yang dibantu:**
  - Menambahkan atribut `color` pada `ItemHomepage` dan memakainya di `ItemCard` (`lib/menu.dart`), serta menambahkan komentar dokumentasi (`///`) pada class.
  - Menyusun draf README ini, termasuk draf jawaban pertanyaan reflektif Tugas 7.
- **Strategi prompting:** Saya memberikan seluruh deskripsi tugas (checklist, petunjuk implementasi, rubrik, dan pertanyaan reflektif) beserta kode hasil Tutorial 08, lalu meminta agar perubahan mengikuti petunjuk resmi dan isi README benar-benar sesuai dengan kode yang ada di repositori.
- **Keterbatasan & pemeriksaan manual:** Keluaran AI tidak langsung saya terima. Saya mengecek ulang bahwa nama tombol, ikon, warna, dan data profil di README cocok dengan `lib/menu.dart`, menjalankan `flutter analyze` dan `flutter test`, serta mencoba aplikasi untuk memastikan SnackBar dan warna tombol tampil sesuai. Jawaban reflektif saya baca ulang dan sesuaikan dengan pemahaman saya sendiri, karena AI cenderung menulis penjelasan umum yang belum tentu mencerminkan widget yang benar-benar dipakai di proyek ini.

## Pertanyaan Reflektif

### Tugas 7

1. **Widget tree dan hubungan parent-child.**
   Di Flutter, seluruh UI disusun dari widget yang saling bersarang membentuk struktur pohon (widget tree). Setiap widget bisa memiliki satu anak (`child`) atau banyak anak (`children`). Parent menentukan konteks dan batasan (constraints) bagi anaknya, misalnya ukuran maksimal, posisi, padding, atau tema; anak kemudian menentukan ukurannya sendiri di dalam batasan itu lalu melaporkannya ke parent ("constraints go down, sizes go up, parent sets position"). Data seperti `Theme` dan `ScaffoldMessenger` juga diwariskan dari atas ke bawah sehingga dapat diakses oleh widget keturunan. Di proyek ini pohonnya kira-kira: `MyApp` → `MaterialApp` → `MyHomePage` → `Scaffold` → (`AppBar`, `Padding` → `Column` → (`Row` berisi 3 `InfoCard`, `SizedBox`, `Center` → `Column` → (`Text`, `GridView` berisi 3 `ItemCard`))).

2. **Widget yang digunakan beserta fungsinya.**
   - `MyApp` (StatelessWidget buatan sendiri): root aplikasi yang mengembalikan `MaterialApp`.
   - `MaterialApp`: menyediakan tema, navigasi, dan konfigurasi Material Design untuk seluruh aplikasi.
   - `MyHomePage` (StatelessWidget buatan sendiri): halaman utama yang menyusun seluruh tampilan menu.
   - `Scaffold`: kerangka halaman Material, menyediakan slot `appBar` dan `body` serta tempat SnackBar muncul.
   - `AppBar`: bilah judul di atas halaman berisi teks "MyPortfolio" dengan warna primary tema.
   - `Text`: menampilkan teks (judul, isi kartu, nama tombol, pesan SnackBar).
   - `Padding`: memberi jarak di sekitar child.
   - `Column`: menyusun child secara vertikal.
   - `Row`: menyusun tiga `InfoCard` secara horizontal dengan `spaceEvenly`.
   - `SizedBox`: memberi jarak kosong dengan ukuran tetap.
   - `Center`: menempatkan child di tengah.
   - `GridView.count`: menampilkan `ItemCard` dalam grid 3 kolom (`shrinkWrap: true` agar bisa berada di dalam `Column`).
   - `InfoCard` (StatelessWidget buatan sendiri): kartu berisi judul dan isi informasi profil.
   - `Card`: kontainer bergaya Material dengan elevasi/bayangan, dipakai di `InfoCard`.
   - `Container`: mengatur lebar (sepertiga layar via `MediaQuery`) dan padding isi kartu.
   - `ItemCard` (StatelessWidget buatan sendiri): kartu tombol aksi yang berwarna sesuai `item.color`.
   - `Material`: memberi warna latar dan sudut membulat pada `ItemCard`, sekaligus permukaan untuk efek ripple.
   - `InkWell`: membuat area kartu bisa ditekan (`onTap`) dengan efek ripple.
   - `Icon`: menampilkan ikon tombol (`folder`, `add_circle`, `logout`).
   - `SnackBar`: pesan singkat di bawah layar, ditampilkan lewat `ScaffoldMessenger.of(context)`.
   - `ItemHomepage` bukan widget, melainkan class model berisi `name`, `icon`, dan `color`.

3. **Fungsi `MaterialApp` dan alasan dipakai sebagai root.**
   `MaterialApp` adalah widget pembungkus yang menyiapkan semua hal yang dibutuhkan aplikasi bergaya Material Design: `ThemeData` (di proyek ini `ColorScheme.fromSeed` dengan seed indigo dan `useMaterial3: true`), `Navigator` dan routing, `title` aplikasi, `home` sebagai halaman awal, lokalisasi, serta `ScaffoldMessenger` tingkat atas. Ia dipakai sebagai root karena widget Material lain seperti `Scaffold`, `AppBar`, `Card`, `InkWell`, dan `SnackBar` bergantung pada data yang diwariskan `MaterialApp` lewat widget tree (tema, arah teks, media query, navigator). Dengan meletakkannya di root, seluruh widget di bawahnya bisa mengakses data tersebut melalui `BuildContext`, misalnya `Theme.of(context)` yang dipakai di `AppBar` halaman ini.

4. **`StatelessWidget` vs `StatefulWidget`.**
   `StatelessWidget` tidak memiliki state internal yang dapat berubah; tampilannya hanya bergantung pada konfigurasi (atribut `final`) dari parent, sehingga ia hanya dibangun ulang jika parent memberi data baru. `StatefulWidget` berpasangan dengan objek `State` yang menyimpan data yang bisa berubah selama widget hidup; memanggil `setState()` akan memicu `build` ulang agar UI mengikuti perubahan. Pilih `StatelessWidget` jika tampilan statis atau seluruh datanya berasal dari luar, seperti `MyHomePage`, `InfoCard`, dan `ItemCard` di proyek ini (SnackBar tidak membutuhkan state karena dikelola oleh `ScaffoldMessenger`). Gunakan `StatefulWidget` jika widget harus mengingat dan mengubah data sendiri, misalnya counter, input form, checkbox, animasi, atau data yang diambil secara asinkron.

5. **`BuildContext`.**
   `BuildContext` adalah referensi ke posisi sebuah widget di dalam widget tree (secara teknis, element milik widget tersebut). Ia penting karena menjadi cara widget "melihat ke atas" untuk mengambil data yang disediakan ancestor-nya. Di metode `build(BuildContext context)`, context dipakai untuk memanggil fungsi `.of(context)`. Di proyek ini: `Theme.of(context).colorScheme.primary` untuk warna `AppBar` di `MyHomePage`, `MediaQuery.of(context).size.width` untuk menghitung lebar `InfoCard`, dan `ScaffoldMessenger.of(context)` di `ItemCard` untuk menampilkan `SnackBar`. Karena context menunjuk posisi widget, context yang dipakai harus berada di bawah ancestor yang dicari (misalnya harus di bawah `MaterialApp`/`Scaffold`).

6. **Hot reload vs hot restart.**
   Hot reload menyuntikkan kode Dart yang telah diubah ke Dart VM yang sedang berjalan lalu membangun ulang widget tree, sehingga perubahan UI terlihat dalam hitungan detik **tanpa menghapus state** (misalnya isi form atau nilai counter tetap). Hot restart memuat ulang seluruh kode dan menjalankan aplikasi dari awal (`main()` dipanggil lagi), sehingga **state hilang**, tetapi masih lebih cepat daripada build ulang penuh. Hot reload tidak cukup ketika perubahan tidak tercermin lewat `build` ulang, misalnya: mengubah `main()` atau `initState()`, mengubah inisialisasi variabel global/static, mengganti `StatelessWidget` menjadi `StatefulWidget` (atau sebaliknya), mengubah tipe generic atau mengubah class menjadi enum; pada kasus ini perlu hot restart. Full restart (stop lalu `flutter run` lagi) diperlukan saat mengubah kode native (Android/iOS), menambah dependency/plugin di `pubspec.yaml`, atau mengubah aset dan konfigurasi platform.
