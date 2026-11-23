import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/utils/validators.dart';
import 'package:myportofolio_mobile/widgets/form_widgets.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Formulir Tambah Pengalaman.
///
/// Field mengikuti model `Experience` dan `ExperienceForm` di repositori
/// Django `myportofolio`: `title`, `category`, `description`, `thumbnail`,
/// dan `ended_at` (kosong berarti masih berlangsung). `started_at` tidak
/// ditampilkan karena di model diisi otomatis (`auto_now_add=True`).
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  /// Sama dengan `Experience.EXPERIENCE_CHOICES` (value -> label).
  static const Map<String, String> _categories = {
    'internship': 'Internship',
    'research': 'Research',
    'volunteer': 'Volunteer',
    'part-time': 'Part-Time',
    'full-time': 'Full-Time',
    'freelance': 'Freelance',
  };

  final _endController = TextEditingController();

  String _title = '';
  String _category = 'full-time'; // default di model
  String _description = '';
  String _thumbnail = '';
  DateTime? _endedAt;
  bool _isOngoing = false;

  @override
  void dispose() {
    _endController.dispose();
    super.dispose();
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  /// Membuka [showDatePicker] untuk memilih tanggal selesai.
  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endedAt ?? now,
      firstDate: DateTime(1990),
      lastDate: now,
    );
    if (picked == null) return;

    setState(() {
      _endedAt = picked;
      _endController.text = _formatDate(picked);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    await showSummaryDialog(
      context,
      title: 'Pengalaman berhasil ditambahkan!',
      entries: {
        'Judul Pengalaman': _title,
        'Kategori': _categories[_category]!,
        'Deskripsi': _description,
        'URL Thumbnail / Logo': _thumbnail.isEmpty ? '-' : _thumbnail,
        'Tanggal Selesai': _isOngoing
            ? 'Masih berlangsung'
            : _formatDate(_endedAt!),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Experience Form',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(current: DrawerPage.addExperience),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Judul Pengalaman',
                  hintText: 'Software Engineer Intern',
                  border: OutlineInputBorder(),
                ),
                maxLength: 255,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.requiredText(
                  value,
                  fieldName: 'Judul pengalaman',
                  maxLength: 255,
                ),
                onSaved: (value) => _title = value!.trim(),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: _categories.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Deskripsikan pengalaman Anda...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (value) =>
                    Validators.requiredText(value, fieldName: 'Deskripsi'),
                onSaved: (value) => _description = value!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'URL Thumbnail / Logo (opsional)',
                  hintText: 'https://...',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                validator: Validators.optionalUrl,
                onSaved: (value) => _thumbnail = value!.trim(),
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Masih berlangsung'),
                value: _isOngoing,
                onChanged: (value) => setState(() => _isOngoing = value),
              ),
              if (!_isOngoing) ...[
                TextFormField(
                  controller: _endController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Selesai',
                    hintText: 'Pilih tanggal',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.event_available),
                  ),
                  onTap: _pickEndDate,
                  validator: (_) =>
                      Validators.endDate(_endedAt, isOngoing: _isOngoing),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 4),
              SaveButton(onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
