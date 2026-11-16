/// Kumpulan validator formulir yang dipakai bersama oleh halaman formulir.
///
/// Setiap fungsi mengembalikan `null` jika nilai valid, atau pesan kesalahan
/// yang akan ditampilkan di bawah kolom terkait jika tidak valid. Logika ini
/// dipisahkan dari widget agar mudah diuji dengan unit test.
class Validators {
  Validators._();

  /// Menolak isian kosong atau yang hanya berisi spasi, serta isian yang
  /// melebihi [maxLength] karakter setelah spasi di awal/akhir dibuang.
  static String? requiredText(
    String? value, {
    required String fieldName,
    required int maxLength,
    int minLength = 1,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return '$fieldName tidak boleh kosong!';
    }
    if (text.length < minLength) {
      return '$fieldName minimal $minLength karakter!';
    }
    if (text.length > maxLength) {
      return '$fieldName maksimal $maxLength karakter!';
    }
    return null;
  }

  /// Memvalidasi URL opsional. Isian kosong dianggap valid, tetapi jika diisi
  /// harus berupa URL `http`/`https` dengan host yang jelas.
  static String? optionalUrl(String? value, {int maxLength = 200}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (text.length > maxLength) {
      return 'URL maksimal $maxLength karakter!';
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

  /// Memvalidasi IPK opsional pada skala 0.00 sampai 4.00.
  /// Koma diterima sebagai pemisah desimal (contoh: `3,75`).
  static String? optionalGpa(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final gpa = double.tryParse(text.replaceAll(',', '.'));
    if (gpa == null) {
      return 'IPK harus berupa angka, contoh: 3.75';
    }
    if (gpa < 0 || gpa > 4) {
      return 'IPK harus berada di antara 0.00 dan 4.00!';
    }
    return null;
  }

  /// Memvalidasi tanggal mulai: wajib diisi dan tidak boleh di masa depan.
  static String? startDate(DateTime? start, {DateTime? today}) {
    if (start == null) {
      return 'Tanggal mulai wajib dipilih!';
    }
    final now = today ?? DateTime.now();
    if (start.isAfter(DateTime(now.year, now.month, now.day))) {
      return 'Tanggal mulai tidak boleh di masa depan!';
    }
    return null;
  }

  /// Memvalidasi tanggal selesai. Jika masih berlangsung ([isOngoing]),
  /// tanggal selesai tidak diperlukan. Jika tidak, tanggal wajib diisi dan
  /// tidak boleh lebih awal dari [start].
  static String? endDate(
    DateTime? end, {
    required DateTime? start,
    required bool isOngoing,
  }) {
    if (isOngoing) return null;
    if (end == null) {
      return 'Pilih tanggal selesai atau tandai "Masih berlangsung"!';
    }
    if (start != null && end.isBefore(start)) {
      return 'Tanggal selesai tidak boleh sebelum tanggal mulai!';
    }
    return null;
  }
}
