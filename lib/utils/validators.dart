/// Kumpulan validator formulir yang dipakai bersama oleh halaman formulir.
///
/// Aturan validasi mengikuti model Django di repositori `myportofolio`
/// (`main/models.py`), misalnya `CharField(max_length=255)` dan `URLField`.
///
/// Setiap fungsi mengembalikan `null` jika nilai valid, atau pesan kesalahan
/// yang akan ditampilkan di bawah kolom terkait jika tidak valid. Logika ini
/// dipisahkan dari widget agar mudah diuji dengan unit test.
class Validators {
  Validators._();

  /// Batas panjang `URLField` bawaan Django.
  static const int urlMaxLength = 200;

  /// Menolak isian kosong atau yang hanya berisi spasi. Jika [maxLength]
  /// diisi (untuk `CharField`), isian yang lebih panjang juga ditolak.
  /// `TextField` tidak punya batas panjang, jadi [maxLength] boleh `null`.
  static String? requiredText(
    String? value, {
    required String fieldName,
    int? maxLength,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return '$fieldName tidak boleh kosong!';
    }
    if (maxLength != null && text.length > maxLength) {
      return '$fieldName maksimal $maxLength karakter!';
    }
    return null;
  }

  /// Memvalidasi URL opsional (`URLField(blank=True)`). Isian kosong dianggap
  /// valid, tetapi jika diisi harus berupa URL `http`/`https` dengan host
  /// yang jelas dan paling banyak [urlMaxLength] karakter.
  static String? optionalUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (text.length > urlMaxLength) {
      return 'URL maksimal $urlMaxLength karakter!';
    }
    final uri = Uri.tryParse(text);
    final isValid =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.contains('.');
    if (!isValid) {
      return 'Masukkan URL yang valid, contoh: https://github.com/username';
    }
    return null;
  }

  /// Memvalidasi tanggal selesai pengalaman (`ended_at`).
  ///
  /// Di model, `ended_at` kosong berarti pengalaman masih berlangsung
  /// (`is_ongoing`). Karena itu, jika [isOngoing] bernilai `true` tanggal
  /// tidak diperlukan. Jika tidak, tanggal wajib dipilih dan tidak boleh
  /// di masa depan (pengalaman yang belum selesai harus ditandai
  /// "Masih berlangsung").
  static String? endDate(
    DateTime? end, {
    required bool isOngoing,
    DateTime? today,
  }) {
    if (isOngoing) return null;
    if (end == null) {
      return 'Pilih tanggal selesai atau tandai "Masih berlangsung"!';
    }
    final now = today ?? DateTime.now();
    if (end.isAfter(DateTime(now.year, now.month, now.day))) {
      return 'Tanggal selesai tidak boleh di masa depan!';
    }
    return null;
  }
}
