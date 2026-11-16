import 'package:material_ui/material_ui.dart';

/// Model data untuk satu tombol aksi di halaman utama.
///
/// Warna disimpan di model agar setiap [ItemCard] cukup membaca
/// `item.color` tanpa percabangan if-else. Jika [destination] diisi,
/// kartu akan membuka halaman tersebut dengan `Navigator.push()`.
class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;
  final WidgetBuilder? destination;

  ItemHomepage(this.name, this.icon, this.color, {this.destination});
}

/// Kartu tombol aksi yang menampilkan SnackBar ketika ditekan, lalu
/// membuka halaman tujuan (jika ada) di atas halaman utama.
class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text("Kamu telah menekan tombol ${item.name}!"),
              ),
            );

          final destination = item.destination;
          if (destination != null) {
            // push: halaman utama tetap ada di stack sehingga tombol kembali
            // bawaan perangkat/AppBar membawa pengguna kembali ke menu.
            Navigator.push(context, MaterialPageRoute(builder: destination));
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          // FittedBox mengecilkan isi kartu jika ruangnya terlalu sempit
          // sehingga ikon dan teks tidak overflow di layar ponsel.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, color: Colors.white, size: 30.0),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
