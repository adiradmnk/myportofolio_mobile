import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/validators.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/form_widgets.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Formulir Tambah Proyek yang mengirim data ke `POST /api/v1/projects/`.
///
/// Field mengikuti `ProjectSerializer` di repositori Django `myportofolio`:
/// `title`, `role`, `description`, dan `link`.
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _role = '';
  String _description = '';
  String _link = '';
  bool _isSubmitting = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (!await ensureLoggedIn(context)) return;
    if (!mounted) return;

    final apiClient = context.read<ApiClient>();
    final auth = context.read<AuthState>();
    final newProject = Project(
      title: _title,
      role: _role,
      description: _description,
      link: _link,
    );

    setState(() => _isSubmitting = true);
    try {
      final created = await apiClient.createProject(
        newProject,
        token: auth.token!,
      );
      if (!mounted) return;
      // Matikan loading sebelum dialog tampil agar tombol tidak terus berputar.
      setState(() => _isSubmitting = false);

      // 201 Created: tampilkan data yang dikembalikan server.
      await showSummaryDialog(
        context,
        title: 'Proyek berhasil ditambahkan!',
        entries: {
          'Nama Proyek': created.title,
          'Peran / Posisi': created.role,
          'Deskripsi': created.description,
          'Tautan': created.link.isEmpty ? '-' : created.link,
        },
      );
      if (!mounted) return;
      _formKey.currentState!.reset();
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        // Token kedaluwarsa/dicabut: logout lalu minta login ulang.
        await auth.logout();
        if (!mounted) return;
        _showSnackBar(e.userMessage);
        await ensureLoggedIn(context);
      } else {
        _showSnackBar('Gagal menyimpan (${e.statusCode}): ${e.userMessage}');
      }
    } on http.ClientException {
      if (!mounted) return;
      _showSnackBar('Tidak dapat terhubung ke server. Coba lagi nanti.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Project Form',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(current: DrawerPage.addProject),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nama Proyek',
                  hintText: 'Nama Proyek',
                  border: OutlineInputBorder(),
                ),
                maxLength: 255,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.requiredText(
                  value,
                  fieldName: 'Nama proyek',
                  maxLength: 255,
                ),
                onSaved: (value) => _title = value!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Peran / Posisi',
                  hintText: 'Frontend Developer, Lead, dll.',
                  border: OutlineInputBorder(),
                ),
                maxLength: 255,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.requiredText(
                  value,
                  fieldName: 'Peran / posisi',
                  maxLength: 255,
                ),
                onSaved: (value) => _role = value!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Proyek',
                  hintText: 'Ceritakan proyekmu...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) => Validators.requiredText(
                  value,
                  fieldName: 'Deskripsi proyek',
                ),
                onSaved: (value) => _description = value!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Link Proyek (opsional)',
                  hintText: 'https://github.com/...',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                validator: Validators.optionalUrl,
                onSaved: (value) => _link = value!.trim(),
              ),
              const SizedBox(height: 16),
              SaveButton(onPressed: _submit, isLoading: _isSubmitting),
            ],
          ),
        ),
      ),
    );
  }
}
