# MyPortfolio Mobile

Aplikasi mobile Flutter untuk portofolio pribadi milik **Adriana Ainurrahmah Damanik** (NPM 2506656375, kelas PBP E). Aplikasi ini adalah perluasan dari website portofolio Django ke ranah mobile, dikerjakan untuk mata kuliah Pemrograman Berbasis Platform (PBP) Fasilkom UI, Gasal 2026/2027.

## Fitur Saat Ini

**Halaman utama (`MyHomePage`, `lib/screens/menu.dart`)**
- Tiga `InfoCard` berisi NPM, Name, dan Class. Lebarnya dibagi rata dengan `Expanded` dan tingginya disamakan dengan `IntrinsicHeight`, jadi tetap muat di layar ponsel.
- Empat `ItemCard` dalam `GridView` dengan warna latar berbeda yang disimpan di model `ItemHomepage` (`name`, `icon`, `color`, `destination`):
  - **Lihat Proyek** (`Icons.folder`, biru): menampilkan SnackBar.
  - **Tambah Proyek** (`Icons.add_circle`, hijau): SnackBar, lalu membuka `ProjectFormPage` dengan `Navigator.push()`.
  - **Tambah Pengalaman** (`Icons.work`, ungu): SnackBar, lalu membuka `ExperienceFormPage` dengan `Navigator.push()`.
  - **Logout** (`Icons.logout`, merah): menampilkan SnackBar.
- Setiap tombol menampilkan SnackBar "Kamu telah menekan tombol [Nama Tombol]!".

**Drawer (`LeftDrawer`, `lib/widgets/left_drawer.dart`)**
- Opsi **Home**, **Add Project**, dan **Add Experience**. Drawer yang sama dipakai di halaman utama dan kedua halaman formulir.
- Berpindah halaman memakai `Navigator.pushReplacement()`. Opsi halaman yang sedang aktif disorot (`selected`), dan jika ditekan hanya menutup drawer tanpa membuat halaman baru.

**Formulir Tambah Proyek (`ProjectFormPage`, `lib/screens/project_form.dart`)**
- Field dari Tutorial 09: Nama Proyek, Deskripsi Proyek, Kategori Proyek (dropdown), Teknologi yang Digunakan, dan Tautan Proyek. Ditambah **Peran / Posisi** karena field `role` ada di model `Project` milikku.
- Validasi mengikuti model `Project`: Nama Proyek dan Peran wajib diisi, maks. 255 karakter (`CharField(max_length=255)`). Deskripsi wajib diisi tanpa batas panjang (`TextField`). Teknologi opsional (maks. 200). Tautan opsional, tetapi jika diisi harus berupa URL `http`/`https` dan maks. 200 karakter (`URLField`).

**Formulir Tambah Pengalaman (`ExperienceFormPage`, `lib/screens/experience_form.dart`)**

Field dan aturannya mengikuti model `Experience` dan `ExperienceForm` di repositori Django [`myportofolio`](https://github.com/adiradmnk/myportofolio) (`main/models.py`, `main/forms.py`):

| Field Flutter | Field model | Input | Validasi |
| --- | --- | --- | --- |
| Judul Pengalaman | `title` (`CharField(max_length=255)`) | `TextFormField` | Wajib, tidak boleh hanya spasi, maks. 255 karakter |
| Kategori | `category` (`EXPERIENCE_CHOICES`, default `full-time`) | `DropdownButtonFormField` | Pilihan sama dengan model: Internship, Research, Volunteer, Part-Time, Full-Time, Freelance |
| Deskripsi | `description` (`TextField`) | `TextFormField` multiline | Wajib, tidak boleh hanya spasi |
| URL Thumbnail / Logo | `thumbnail` (`URLField(blank=True)`) | `TextFormField` + keyboard URL | Opsional; jika diisi harus URL `http`/`https`, maks. 200 karakter |
| Masih berlangsung + Tanggal Selesai | `ended_at` (`blank=True`, kosong = `is_ongoing`) | `SwitchListTile` + `showDatePicker()` | Wajib dipilih jika tidak sedang berlangsung, tidak boleh di masa depan |

`started_at` tidak dimasukkan ke formulir karena di model diisi otomatis (`auto_now_add=True`).

**Perilaku kedua formulir**
- Isian kosong atau yang hanya berisi spasi ditolak, dan pesan kesalahan tampil di bawah kolom terkait.
- Tombol **Simpan** memanggil `FormState.validate()`. Ringkasan isian tampil dalam `AlertDialog` (lewat `showDialog()`) hanya jika semua input valid.
- Tombol **OK** menutup dialog dan pengguna kembali ke formulir dengan isian yang masih utuh.
- Seluruh isi formulir dibungkus `SingleChildScrollView`, jadi semua input dan tombol Simpan tetap bisa dijangkau di layar sempit atau saat keyboard tampil.

**Tambahan di luar checklist**
- Validator dipisah ke `lib/utils/validators.dart` dan diuji dengan unit test.
- Tombol Simpan (`SaveButton`) dan dialog ringkasan (`showSummaryDialog`) dipakai bersama oleh kedua formulir (`lib/widgets/form_widgets.dart`).
- Penghitung karakter (`maxLength`), keyboard URL untuk field tautan dan thumbnail, serta `textInputAction: next`.
- Widget test mensimulasikan layar ponsel 390×844 dan menguji alur kartu, drawer, tombol kembali perangkat, input valid/tidak valid, dan dialog.
- Perbaikan overflow di layar sempit pada `InfoCard`, `ItemCard` (dengan `FittedBox`), dan header drawer.

## Struktur Proyek

```
lib/
├── main.dart                 # MyApp: MaterialApp + tema (seed color indigo)
├── screens/
│   ├── menu.dart             # MyHomePage (halaman utama)
│   ├── project_form.dart     # ProjectFormPage
│   └── experience_form.dart  # ExperienceFormPage
├── widgets/
│   ├── info_card.dart        # InfoCard
│   ├── project_card.dart     # ItemHomepage (model) + ItemCard
│   ├── left_drawer.dart      # LeftDrawer + enum DrawerPage
│   └── form_widgets.dart     # SaveButton + showSummaryDialog
└── utils/
    └── validators.dart       # Validators (logika validasi formulir)
test/
├── widget_test.dart          # uji UI, navigasi, dan formulir
└── validators_test.dart      # unit test validator
```

## Cara Menjalankan

Membutuhkan Flutter 3.50 atau lebih baru (proyek memakai paket `material_ui`).

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
| Tutorial 09 | Navigation, Layouts, Forms | Migrasi ke `material_ui`, `LeftDrawer`, `ProjectFormPage` dengan dialog ringkasan, navigasi kartu, refactor ke `screens/` dan `widgets/` |
| Tugas 8 | Navigation, Layouts, Forms | `ExperienceFormPage` sesuai model `Experience` (date picker, switch masih berlangsung, validasi panjang/URL/tanggal), field `role` di formulir proyek sesuai model `Project`, opsi drawer Add Experience, validator terpisah dan teruji, perbaikan layout layar sempit |

## AI Disclosure

- **Tools:** Claude (Anthropic).
- **Bagian yang dibantu:**
  - Tugas 7: menambahkan atribut `color` pada `ItemHomepage` dan memakainya di `ItemCard`, serta komentar dokumentasi (`///`) pada class.
  - Tutorial 09 & Tugas 8: refactor ke `lib/screens/` dan `lib/widgets/`, migrasi impor ke `material_ui`, `LeftDrawer`, `ProjectFormPage`, `ExperienceFormPage`, `Validators`, `SaveButton`/`showSummaryDialog`, serta unit test dan widget test.
  - Menyusun draf README, termasuk draf jawaban pertanyaan reflektif Tugas 7 dan Tugas 8.
- **Strategi prompting:** Saya memberikan seluruh teks tugas (checklist, petunjuk, rubrik, pertanyaan reflektif) dan teks Tutorial 09, lalu meminta agar implementasi mengikuti pola tutorial (nama field, `pushReplacement` di drawer, `push` di kartu, struktur folder), agar isi README sesuai dengan kode yang ada, dan agar fitur diuji di layar selebar ponsel.
- **Log prompting (ringkas):**
  1. "Kerjakan Tugas 7 sesuai checklist ini; README harus sesuai dengan kode." → warna per tombol + README.
  2. "Apakah ini sudah memenuhi Tugas 8? Aku ingin nilai 4." → AI mengonfirmasi bahwa Tutorial 09 dan Tugas 8 belum dikerjakan, lalu membuat drawer dan kedua formulir.
  3. Saya menempelkan teks Tutorial 09 → AI menyesuaikan diri: impor diganti ke `material_ui`, `item_card.dart` diganti nama menjadi `project_card.dart`, dan field formulir proyek disamakan dengan tutorial.
  4. "Apakah sudah mengikuti repo `myportofolio` aku?" → AI membaca `main/models.py` dan `main/forms.py`, lalu menemukan bahwa tidak ada model Education. Formulir Edukasi diganti menjadi Formulir Pengalaman (`Experience`), formulir proyek ditambahi field `role`, dan batas validasi disesuaikan dengan model.
- **Keterbatasan AI & perbaikan manual/iteratif:**
  - Versi pertama AI masih memakai `package:flutter/material.dart`, sehingga `flutter analyze` di Flutter 3.50 memberi peringatan deprecated. Masalah ini baru diperbaiki setelah saya memberikan teks Tutorial 09 yang menjelaskan migrasi ke `material_ui`. Pelajarannya, AI tidak selalu tahu perubahan SDK terbaru.
  - Kesalahan terbesar: AI awalnya membuat formulir **Edukasi** dengan field umum (institusi, jenjang, IPK) tanpa mengecek repositori Django-ku, padahal di sana tidak ada model Education. Hal ini baru ketahuan setelah saya bertanya apakah formulirnya sudah mengikuti repo `myportofolio`. Formulir lalu diganti menjadi **Pengalaman** sesuai model `Experience`. Pelajarannya, AI cenderung mengarang struktur data yang masuk akal kalau tidak diberi sumber yang sebenarnya, jadi model data harus selalu dicek ke kode aslinya.
  - Field formulir proyek versi awal buatan AI (judul, URL, switch unggulan) tidak sama dengan tutorial, jadi saya minta disesuaikan.
  - Widget test di layar 390×844 menemukan overflow yang tidak terlihat dari kode saja: `InfoCard` yang memakai lebar tetap `width / 3.5` (sudah ada sejak Tugas 7), teks `ItemCard`, dan `DrawerHeader` yang tingginya tetap. Ketiganya diperbaiki dengan `Expanded`, `FittedBox`, dan `Container`.
  - Test awal buatan AI gagal karena mengira formulir memiliki tombol back di AppBar, padahal AppBar menampilkan ikon drawer. Test diubah agar mensimulasikan tombol kembali perangkat (`handlePopRoute`).
  - Saya mengecek bahwa nama tombol, field, batasan validasi, dan struktur folder di README cocok dengan kode, lalu menjalankan `flutter analyze` (No issues found) dan `flutter test`. Jawaban reflektif saya baca ulang dan sesuaikan dengan pemahaman saya sendiri.

## Pertanyaan Reflektif

### Tugas 7

> Catatan: jawaban ini ditulis berdasarkan kode saat Tugas 7. Sejak Tutorial 09, `menu.dart` dipindah ke `lib/screens/`, dan `InfoCard` tidak lagi memakai `Container` dengan lebar `MediaQuery` melainkan dibungkus `Expanded`.

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

### Tugas 8

1. **`push()`, `pushReplacement()`, dan `pop()`.**
   `Navigator` menyimpan halaman (route) sebagai stack. `Navigator.push()` menaruh route baru di atas stack, sehingga halaman lama tetap ada di bawahnya dan pengguna bisa kembali. `Navigator.pushReplacement()` mengganti route paling atas dengan route baru, sehingga halaman lama dibuang dan tidak bisa dikunjungi lagi dengan tombol kembali. `Navigator.pop()` membuang route paling atas sehingga halaman di bawahnya tampil lagi; di proyek ini `pop` juga dipakai untuk menutup drawer dan menutup `AlertDialog`, karena keduanya juga berupa route. Kartu **Tambah Proyek** dan **Tambah Pengalaman** memakai `Navigator.push()` (di `ItemCard`, berdasarkan atribut `destination` milik `ItemHomepage`), sehingga stack berisi `[MyHomePage, Form]` dan tombol kembali perangkat/browser membawa pengguna ke menu. Opsi **Home** di `LeftDrawer` pertama-tama memanggil `Navigator.pop(context)` untuk menutup drawer, lalu `Navigator.pushReplacement()` dengan `MyHomePage()`, sehingga halaman formulir yang sedang terbuka diganti oleh halaman utama. Jika pengguna sudah berada di halaman tersebut (dicek dengan enum `DrawerPage`), drawer hanya ditutup agar tidak membuat halaman duplikat.

2. **Konsistensi lewat `Scaffold`, `AppBar`, dan `Drawer`.**
   `Scaffold` memberi kerangka yang sama untuk setiap halaman: slot `appBar` di atas, `drawer` di kiri, dan `body` untuk konten. Ketiga halaman (`MyHomePage`, `ProjectFormPage`, `ExperienceFormPage`) memakai susunan yang sama: `AppBar` dengan judul putih tebal dan ikon putih, serta widget `LeftDrawer` yang sama (hanya parameter `current` yang berbeda). Karena drawer berupa satu widget di `lib/widgets/left_drawer.dart`, menambah opsi baru (seperti Add Experience) cukup dilakukan sekali dan langsung muncul di semua halaman. Contoh warna tema: `Theme.of(context).colorScheme.primary`, yang berasal dari `ColorScheme.fromSeed(seedColor: Colors.indigo)` di `main.dart`, dipakai sebagai `backgroundColor` `AppBar` di ketiga halaman, sebagai latar header drawer, dan sebagai warna tombol Simpan (`SaveButton`) di kedua formulir. Jika seed color diganti, semua bagian itu ikut berubah.

3. **Pemilihan tata letak formulir.**
   Formulir disusun dalam satu `Column` vertikal dengan `crossAxisAlignment: CrossAxisAlignment.stretch`, sehingga setiap input dan tombol Simpan selebar layar. Urutan field mengikuti cara orang membaca dari atas ke bawah, dan tombol Simpan diletakkan paling bawah setelah semua isian, yang paling mudah dijangkau di ponsel. `SizedBox(height: 12)` di antara field memberi jarak yang konsisten agar input tidak berdempetan, sedangkan `padding: EdgeInsets.all(16)` pada `SingleChildScrollView` memberi jarak dari tepi layar. `SingleChildScrollView` menjadi kunci di layar sempit: `Column` sendiri tidak bisa digulir, sehingga saat keyboard muncul dan tinggi layar yang tersisa mengecil, isi formulir akan overflow. Dengan penggulir, pengguna tetap bisa menggulir sampai Simpan. Formulir pengalaman bisa bertambah panjang karena field Tanggal Selesai muncul jika switch "Masih berlangsung" dimatikan, dan penggulir menampung perubahan itu. Hal ini diuji di `test/widget_test.dart` dengan ukuran layar 390×844 dan `ensureVisible` pada tombol Simpan.

4. **`GlobalKey<FormState>`, `validator`, dan `validate()`.**
   `GlobalKey<FormState>` (`_formKey`) dipasang pada widget `Form` sehingga state formulir bisa diakses dari luar field, misalnya dari tombol Simpan, lewat `_formKey.currentState`. Setiap `TextFormField` memiliki `validator` yang mengembalikan `null` jika valid atau sebuah pesan kesalahan. Saat Simpan ditekan, `_formKey.currentState!.validate()` menjalankan semua validator sekaligus, menampilkan pesan kesalahan di bawah field yang gagal, dan mengembalikan `true` hanya jika semuanya lolos. Setelah itu `save()` memanggil `onSaved` tiap field untuk menyimpan nilai yang sudah di-`trim()`, lalu `showSummaryDialog()` menampilkan `AlertDialog`. Contoh nilai yang ditolak: `github.com/adiradmnk` di field URL Thumbnail / Logo. Walaupun field ini memakai `TextInputType.url`, keyboard hanya sekadar saran tampilan (misalnya menampilkan tombol `/` dan `.com`). Keyboard tidak memaksa adanya `https://`, dan di browser atau dengan keyboard fisik pengguna tetap bisa mengetik atau menempel teks apa saja. Contoh lainnya: isian `   ` (hanya spasi) di Judul Pengalaman yang secara teknis tidak kosong, atau judul lebih dari 255 karakter yang tidak akan muat di `CharField(max_length=255)` milik model Django. Begitu juga date picker: ia memang membatasi pilihan tanggal, tetapi aturan "wajib diisi kecuali masih berlangsung" tetap harus dicek oleh validator. Aturan seperti ini hanya bisa ditegakkan oleh `validator` (di proyek ini dipusatkan di `Validators`).
