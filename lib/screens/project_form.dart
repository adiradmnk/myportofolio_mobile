import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/utils/validators.dart';
import 'package:myportofolio_mobile/widgets/form_widgets.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Formulir Tambah Proyek (Tutorial 09).
///
/// Field mengikuti Tutorial 09, ditambah `Peran / Posisi` dari model
/// `Project` di repositori Django `myportofolio` (`title`, `role`,
/// `description`, `link`).
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();

  static const List<String> _categories = [
    'Web Development',
    'Mobile Development',
    'Machine Learning',
    'Data Science',
    'Other',
  ];

  String _projectName = '';
  String _role = '';
  String _description = '';
  String _category = _categories.first;
  String _technologies = '';
  String _projectLink = '';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    await showSummaryDialog(
      context,
      title: 'Proyek berhasil ditambahkan!',
      entries: {
        'Nama Proyek': _projectName,
        'Peran / Posisi': _role,
        'Deskripsi': _description,
        'Kategori': _category,
        'Teknologi': _technologies.isEmpty ? '-' : _technologies,
        'Tautan': _projectLink.isEmpty ? '-' : _projectLink,
      },
    );
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
                  hintText: 'Contoh: MyPortfolio Web',
                  border: OutlineInputBorder(),
                ),
                maxLength: 255,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.requiredText(
                  value,
                  fieldName: 'Nama proyek',
                  maxLength: 255,
                ),
                onSaved: (value) => _projectName = value!.trim(),
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
                  hintText: 'Ceritakan singkat tentang proyek ini',
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
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Kategori Proyek',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Teknologi yang Digunakan',
                  hintText: 'Contoh: Flutter, Django, Figma',
                  border: OutlineInputBorder(),
                ),
                maxLength: 200,
                textInputAction: TextInputAction.next,
                onSaved: (value) => _technologies = value!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Tautan Proyek',
                  hintText: 'URL Proyek (opsional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                validator: Validators.optionalUrl,
                onSaved: (value) => _projectLink = value!.trim(),
              ),
              const SizedBox(height: 16),
              SaveButton(onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
