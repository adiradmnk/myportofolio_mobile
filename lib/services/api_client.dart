import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/project.dart';

/// Exception yang dilempar ketika API membalas dengan status non-2xx.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;

  /// Body respons mentah. Jangan ditampilkan langsung ke pengguna karena bisa
  /// berisi halaman error HTML/stack trace saat `DEBUG=True` di Django.
  final String message;

  /// Pesan ramah pengguna berdasarkan [statusCode].
  String get userMessage => switch (statusCode) {
    400 => 'Data tidak valid, periksa kembali isian formulir.',
    401 => 'Sesi login berakhir atau tidak valid. Silakan login ulang.',
    403 => 'Hanya pemilik portofolio yang dapat melakukan aksi ini.',
    404 => 'Data tidak ditemukan.',
    >= 500 => 'Server sedang bermasalah, coba lagi nanti.',
    _ => 'Terjadi kesalahan (kode $statusCode).',
  };

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Klien HTTP untuk backend Django REST Framework MyPortfolio.
///
/// Header ditulis sebagai string biasa (bukan `HttpHeaders` dari `dart:io`)
/// agar tetap bisa di-build untuk Flutter Web.
class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  static const _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _authHeaders(String token) => {
    ..._jsonHeaders,
    'Authorization': 'Token $token',
  };

  /// `GET /api/v1/projects/` (publik).
  Future<List<Project>> getProjects() async {
    final response = await _client.get(
      _uri('/api/v1/projects/'),
      headers: const {'Accept': 'application/json'},
    );
    _ensureSuccess(response);

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return decoded
        .map((item) => Project.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// `POST /api/v1/projects/` dengan token (hanya superuser).
  Future<Project> createProject(
    Project project, {
    required String token,
  }) async {
    final response = await _client.post(
      _uri('/api/v1/projects/'),
      headers: _authHeaders(token),
      body: jsonEncode(project.toJson()),
    );
    _ensureSuccess(response);

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return Project.fromJson(decoded);
  }

  /// `POST /api/v1/auth/token/`: menukar username + password menjadi token.
  Future<String> obtainToken(String username, String password) async {
    final response = await _client.post(
      _uri('/api/v1/auth/token/'),
      headers: _jsonHeaders,
      body: jsonEncode({'username': username, 'password': password}),
    );
    _ensureSuccess(response);

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['token'] as String;
  }

  /// `POST /api/v1/auth/logout/`: mencabut token di server (204).
  Future<void> logout({required String token}) async {
    final response = await _client.post(
      _uri('/api/v1/auth/logout/'),
      headers: _authHeaders(token),
    );
    _ensureSuccess(response);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw ApiException(response.statusCode, response.body);
  }
}
