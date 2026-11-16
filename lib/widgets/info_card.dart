import 'package:material_ui/material_ui.dart';

/// Kartu kecil yang menampilkan satu informasi profil (NPM, nama, kelas).
///
/// Lebarnya diatur oleh parent (dibungkus `Expanded` di halaman utama)
/// agar tiga kartu selalu muat dalam satu baris di layar sempit.
class InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text(content, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
