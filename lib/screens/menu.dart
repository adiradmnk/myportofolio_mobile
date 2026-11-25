import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/widgets/info_card.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Halaman utama aplikasi portofolio (StatelessWidget).
class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final String npm = "2506656375";
  final String nama = "Adriana Ainurrahmah Damanik";
  final String kelas = "PBP E";

  final List<ItemHomepage> items = [
    ItemHomepage(
      "Lihat Proyek",
      Icons.folder,
      Colors.blue,
      destination: (_) => const ProjectListScreen(),
    ),
    ItemHomepage(
      "Tambah Proyek",
      Icons.add_circle,
      Colors.green,
      destination: (_) => const ProjectFormPage(),
      requiresLogin: true,
    ),
    ItemHomepage(
      "Tambah Pengalaman",
      Icons.work,
      Colors.deepPurple,
      destination: (_) => const ExperienceFormPage(),
      requiresLogin: true,
    ),
    ItemHomepage("Logout", Icons.logout, Colors.red, action: ItemAction.logout),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(current: DrawerPage.home),
      // SingleChildScrollView menjaga isi tetap bisa digulir di layar pendek.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // IntrinsicHeight + stretch membuat tinggi ketiga kartu sama,
            // Expanded membagi lebar layar secara merata.
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: InfoCard(title: 'NPM', content: npm),
                  ),
                  Expanded(
                    child: InfoCard(title: 'Name', content: nama),
                  ),
                  Expanded(
                    child: InfoCard(title: 'Class', content: kelas),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Text(
                'Selamat datang di MyPortfolio Mobile!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
            ),
            GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 3,
              shrinkWrap: true,
              // Scroll ditangani SingleChildScrollView di atas.
              physics: const NeverScrollableScrollPhysics(),
              children: items.map((ItemHomepage item) {
                return ItemCard(item);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
