import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/services/api_client.dart';

/// Menyimpan token autentikasi sesi saat ini di memori dan memberi tahu
/// listener (mis. drawer) ketika login/logout mengubah state.
class AuthState extends ChangeNotifier {
  AuthState(this._apiClient, {String? initialToken}) : _token = initialToken;

  final ApiClient _apiClient;
  String? _token;

  String? get token => _token;
  bool get isLoggedIn => _token != null;

  Future<void> login(String username, String password) async {
    _token = await _apiClient.obtainToken(username, password);
    notifyListeners();
  }

  /// Mencabut token di server lalu menghapusnya dari memori. Token lokal
  /// tetap dihapus walaupun request ke server gagal (mis. offline atau
  /// token sudah tidak valid), agar pengguna tidak "terjebak" login.
  Future<void> logout() async {
    final current = _token;
    if (current == null) return;

    try {
      await _apiClient.logout(token: current);
    } on ApiException {
      // Token sudah tidak valid di server; cukup hapus di sisi klien.
    } on http.ClientException {
      // Tidak ada koneksi ke server; token tetap dihapus di sisi klien.
    } finally {
      _token = null;
      notifyListeners();
    }
  }
}
