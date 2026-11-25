import 'package:material_ui/material_ui.dart';

/// Tombol Simpan lebar penuh dengan warna primary tema, dipakai oleh semua
/// halaman formulir agar tampilannya seragam.
///
/// Saat [isLoading] bernilai `true`, tombol dinonaktifkan dan menampilkan
/// indikator loading agar data tidak terkirim dua kali.
class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const SaveButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
        label: const Text('Simpan'),
      ),
    );
  }
}

/// Menampilkan ringkasan isian formulir dalam [AlertDialog].
///
/// [entries] berisi pasangan label dan nilai, ditampilkan berurutan.
/// Dialog ditutup dengan tombol OK dan pengguna kembali ke formulir.
Future<void> showSummaryDialog(
  BuildContext context, {
  required String title,
  required Map<String, String> entries,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final entry in entries.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${entry.key}: ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: entry.value),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
