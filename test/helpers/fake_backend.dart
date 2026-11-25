import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

/// Backend DRF palsu berbasis [MockClient] untuk pengujian tanpa server.
///
/// Meniru endpoint `/api/v1/projects/`, `/api/v1/auth/token/`, dan
/// `/api/v1/auth/logout/` beserta aturan autentikasinya.
class FakeBackend {
  static const username = 'adriana';
  static const password = 'rahasia123';
  static const validToken = 'token-valid';

  final List<Map<String, dynamic>> projects = [
    {
      'id': '11111111-1111-1111-1111-111111111111',
      'title': 'MyPortfolio Web',
      'role': 'Fullstack Developer',
      'description': 'Website portofolio berbasis Django.',
      'link': 'https://github.com/adiradmnk/myportofolio',
      'star_count': 2,
      'is_starred': false,
      'starred_by_names': 'a, b',
    },
  ];

  /// Jika `true`, endpoint daftar proyek membalas 500.
  bool failProjects = false;

  /// Token yang masih berlaku di "server".
  final Set<String> activeTokens = {};

  /// Request terakhir yang diterima, untuk diperiksa di test.
  final List<http.Request> requests = [];

  ApiClient get client =>
      ApiClient(client: MockClient(_handle), baseUrl: 'http://test');

  Future<http.Response> _handle(http.Request request) async {
    requests.add(request);
    final auth = request.headers['Authorization'];
    final token = auth?.replaceFirst('Token ', '');
    final isAuthed = token != null && activeTokens.contains(token);

    switch ((request.method, request.url.path)) {
      case ('GET', '/api/v1/projects/'):
        if (failProjects) return http.Response('<h1>Server Error</h1>', 500);
        return _json(projects);
      case ('POST', '/api/v1/projects/'):
        if (!isAuthed) {
          return _json({'detail': 'Invalid token.'}, 401);
        }
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final created = {
          ...body,
          'id': '22222222-2222-2222-2222-222222222222',
          'star_count': 0,
        };
        projects.add(created);
        return _json(created, 201);
      case ('POST', '/api/v1/auth/token/'):
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if (body['username'] == username && body['password'] == password) {
          activeTokens.add(validToken);
          return _json({'token': validToken});
        }
        return _json({
          'non_field_errors': ['Unable to log in.'],
        }, 400);
      case ('POST', '/api/v1/auth/logout/'):
        if (!isAuthed) return _json({'detail': 'Invalid token.'}, 401);
        activeTokens.remove(token);
        return http.Response('', 204);
    }
    return http.Response('Not found', 404);
  }

  static http.Response _json(Object body, [int status = 200]) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}
