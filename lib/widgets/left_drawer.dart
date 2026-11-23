import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

/// Penanda halaman yang sedang aktif, dipakai untuk menyorot opsi drawer.
enum DrawerPage { home, addProject, addExperience }

/// Drawer yang sama untuk halaman utama dan semua halaman formulir.
class LeftDrawer extends StatelessWidget {
  /// Halaman tempat drawer ini ditampilkan.
  final DrawerPage current;

  const LeftDrawer({super.key, required this.current});

  /// Menutup drawer, lalu mengganti halaman saat ini dengan [page] memakai
  /// `pushReplacement` agar stack navigasi tidak menumpuk. Jika pengguna
  /// memilih halaman yang sedang dibuka, cukup tutup drawer.
  void _navigate(BuildContext context, DrawerPage target, WidgetBuilder page) {
    Navigator.pop(context);
    if (target == current) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: page));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'MyPortfolio',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Kelola proyek dan pengalaman portofoliomu!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.white),
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
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            selected: current == DrawerPage.addProject,
            onTap: () => _navigate(
              context,
              DrawerPage.addProject,
              (_) => const ProjectFormPage(),
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
            ),
          ),
        ],
      ),
    );
  }
}
