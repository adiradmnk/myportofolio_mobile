/// Base URL backend Django REST Framework.
///
/// Default `http://10.0.2.2:8000`, yaitu alamat mesin pengembangan lokal
/// jika diakses dari emulator Android. Timpa dengan
/// `--dart-define=API_BASE_URL=http://localhost:8000` saat menjalankan di
/// Chrome, atau dengan URL deployment PWS untuk build rilis.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',
);
