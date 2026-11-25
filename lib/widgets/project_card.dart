import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

/// Jenis aksi yang dijalankan sebuah [ItemCard].
enum ItemAction {
  /// Hanya menampilkan SnackBar (atau membuka [ItemHomepage.destination]).
  open,

  /// Mencabut token dan logout.
  logout,
}

/// Model data untuk satu tombol aksi di halaman utama.
///
/// Warna disimpan di model agar setiap [ItemCard] cukup membaca
/// `item.color` tanpa percabangan if-else. Jika [destination] diisi,
/// kartu akan membuka halaman tersebut dengan `Navigator.push()`; jika
/// [requiresLogin] bernilai `true`, pengguna diminta login terlebih dahulu.
class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;
  final WidgetBuilder? destination;
  final bool requiresLogin;
  final ItemAction action;

  ItemHomepage(
    this.name,
    this.icon,
    this.color, {
    this.destination,
    this.requiresLogin = false,
    this.action = ItemAction.open,
  });
}

/// Kartu tombol aksi yang menampilkan SnackBar ketika ditekan, lalu
/// menjalankan aksinya (membuka halaman tujuan atau logout).
class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthState>();
    if (!auth.isLoggedIn) {
      _showSnackBar(context, 'Kamu belum login.');
      return;
    }
    await auth.logout();
    if (!context.mounted) return;
    _showSnackBar(
      context,
      'Kamu telah menekan tombol Logout! Berhasil logout.',
    );
  }

  Future<void> _open(BuildContext context) async {
    _showSnackBar(context, 'Kamu telah menekan tombol ${item.name}!');

    final destination = item.destination;
    if (destination == null) return;
    if (item.requiresLogin && !await ensureLoggedIn(context)) return;
    if (!context.mounted) return;

    // push: halaman utama tetap ada di stack sehingga tombol kembali
    // bawaan perangkat/browser membawa pengguna kembali ke menu.
    Navigator.push(context, MaterialPageRoute(builder: destination));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => switch (item.action) {
          ItemAction.open => _open(context),
          ItemAction.logout => _logout(context),
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
