import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

/// Penanda halaman yang sedang aktif, dipakai untuk menyorot opsi drawer.
enum DrawerPage { home, projects, addProject, addExperience }

/// Drawer yang sama untuk halaman utama, daftar proyek, dan semua formulir.
class LeftDrawer extends StatelessWidget {
  /// Halaman tempat drawer ini ditampilkan.
  final DrawerPage current;

  const LeftDrawer({super.key, required this.current});

  /// Mengganti halaman saat ini dengan [page] memakai `pushReplacement` agar
  /// stack navigasi tidak menumpuk. Jika [requiresLogin], pengguna diminta
  /// login dulu lewat [ensureLoggedIn] (selagi drawer masih terbuka, agar
  /// `context` tetap valid). Memilih halaman yang sedang dibuka cukup
  /// menutup drawer.
  Future<void> _navigate(
    BuildContext context,
    DrawerPage target,
    WidgetBuilder page, {
    bool requiresLogin = false,
  }) async {
    if (requiresLogin && !await ensureLoggedIn(context)) return;
    if (!context.mounted) return;

    Navigator.pop(context);
    if (target == current) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: page));
  }

  /// Logout, lalu kembali ke Home jika halaman saat ini butuh login.
  Future<void> _logout(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await context.read<AuthState>().logout();

    navigator.pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Kamu berhasil logout.')));
    if (current == DrawerPage.addProject ||
        current == DrawerPage.addExperience) {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => MyHomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // watch: drawer dibangun ulang otomatis saat status login berubah.
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Container (bukan DrawerHeader yang tingginya tetap) agar header
          // menyesuaikan tinggi teks dan tidak overflow di layar kecil atau
          // saat ukuran font sistem diperbesar.
          Container(
            color: colorScheme.primary,
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 32,
              16,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'MyPortfolio',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isLoggedIn
                      ? 'Kamu sudah login.'
                      : 'Kelola proyek dan pengalaman portofoliomu!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            selected: current == DrawerPage.home,
            onTap: () =>
                _navigate(context, DrawerPage.home, (_) => MyHomePage()),
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Project List'),
            selected: current == DrawerPage.projects,
            onTap: () => _navigate(
              context,
              DrawerPage.projects,
              (_) => const ProjectListScreen(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            selected: current == DrawerPage.addProject,
            onTap: () => _navigate(
              context,
              DrawerPage.addProject,
              (_) => const ProjectFormPage(),
              requiresLogin: true,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('Add Experience'),
            selected: current == DrawerPage.addExperience,
            onTap: () => _navigate(
              context,
              DrawerPage.addExperience,
              (_) => const ExperienceFormPage(),
              requiresLogin: true,
            ),
          ),
          const Divider(),
          if (isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(context),
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () async {
                final loggedIn = await ensureLoggedIn(context);
                if (!context.mounted) return;
                Navigator.pop(context);
                if (loggedIn) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('Login berhasil!')),
                    );
                }
              },
            ),
        ],
      ),
    );
  }
}
