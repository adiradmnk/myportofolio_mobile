import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

import 'helpers/fake_backend.dart';

void main() {
  late FakeBackend backend;
  late ApiClient client;

  setUp(() {
    backend = FakeBackend();
    client = backend.client;
  });

  group('Project JSON', () {
    test(
      'fromJson memetakan snake_case dan link null menjadi string kosong',
      () {
        final project = Project.fromJson({
          'id': 'abc',
          'title': 'A',
          'role': 'B',
          'description': 'C',
          'link': null,
          'star_count': 3,
        });
        expect(project.id, 'abc');
        expect(project.link, '');
        expect(project.starCount, 3);
      },
    );

    test('toJson tidak mengirim field read-only id dan star_count', () {
      const project = Project(
        id: 'abc',
        title: 'A',
        role: 'B',
        description: 'C',
        starCount: 5,
      );
      expect(project.toJson(), {
        'title': 'A',
        'role': 'B',
        'description': 'C',
        'link': '',
      });
    });
  });

  group('ApiClient', () {
    test('getProjects mengambil daftar proyek', () async {
      final projects = await client.getProjects();
      expect(projects.single.title, 'MyPortfolio Web');
      expect(projects.single.starCount, 2);
    });

    test('status non-2xx dilempar sebagai ApiException', () async {
      backend.failProjects = true;
      await expectLater(
        client.getProjects(),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'code', 500)),
      );
    });

    test('obtainToken mengembalikan token atau 400 jika salah', () async {
      expect(
        await client.obtainToken(FakeBackend.username, FakeBackend.password),
        FakeBackend.validToken,
      );
      await expectLater(
        client.obtainToken(FakeBackend.username, 'salah'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'code', 400)),
      );
    });

    test('createProject mengirim header Authorization dan body JSON', () async {
      backend.activeTokens.add(FakeBackend.validToken);
      final created = await client.createProject(
        const Project(title: 'Baru', role: 'Dev', description: 'Desk'),
        token: FakeBackend.validToken,
      );
      expect(created.id, isNotNull);
      final request = backend.requests.last;
      expect(request.headers['Authorization'], 'Token token-valid');
      expect(request.headers['Content-Type'], contains('application/json'));
    });

    test('createProject tanpa token valid menghasilkan 401', () async {
      await expectLater(
        client.createProject(
          const Project(title: 'Baru', role: 'Dev', description: 'Desk'),
          token: 'token-palsu',
        ),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'code', 401)),
      );
    });
  });

  group('AuthState', () {
    test('login lalu logout mencabut token di server', () async {
      final auth = AuthState(client);
      await auth.login(FakeBackend.username, FakeBackend.password);
      expect(auth.isLoggedIn, isTrue);

      await auth.logout();
      expect(auth.isLoggedIn, isFalse);
      expect(backend.activeTokens, isEmpty);
    });

    test('logout tetap menghapus token lokal walau server menolak', () async {
      final auth = AuthState(client, initialToken: 'token-kedaluwarsa');
      await auth.logout();
      expect(auth.isLoggedIn, isFalse);
    });
  });
}
