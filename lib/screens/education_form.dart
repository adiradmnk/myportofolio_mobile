import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/utils/validators.dart';
import 'package:myportofolio_mobile/widgets/form_widgets.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Formulir Tambah Edukasi untuk bagian riwayat pendidikan portofolio.
///
/// Field mengikuti model Education: institusi, jenjang, jurusan, tanggal
/// mulai, tanggal selesai (atau masih berlangsung), dan IPK opsional.
class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key});

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  final _formKey = GlobalKey<FormState>();

  static const List<String> _levels = ['SMA/SMK', 'D3', 'S1', 'S2', 'S3'];

  final _startController = TextEditingController();
  final _endController = TextEditingController();

  String _institution = '';
  String _major = '';
  String _level = 'S1';
  String _gpa = '';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isOngoing = false;

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  /// Membuka [showDatePicker] lalu menyimpan tanggal yang dipilih.
  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? _startDate ?? now,
      firstDate: DateTime(1990),
      lastDate: isStart ? now : DateTime(now.year + 10),
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
        _startController.text = _formatDate(picked);
      } else {
        _endDate = picked;
        _endController.text = _formatDate(picked);
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    showSummaryDialog(
      context,
      title: 'Edukasi berhasil disimpan',
      entries: {
        'Institusi': _institution,
        'Jenjang': _level,
        'Jurusan': _major,
        'Tanggal Mulai': _formatDate(_startDate!),
        'Tanggal Selesai': _isOngoing
            ? 'Masih berlangsung'
            : _formatDate(_endDate!),
        'IPK': _gpa.isEmpty ? '-' : _gpa.replaceAll(',', '.'),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Edukasi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(current: DrawerPage.addEducation),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nama Institusi',
                  hintText: 'Contoh: Universitas Indonesia',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.requiredText(
                  value,
                  fieldName: 'Nama institusi',
                  maxLength: 100,
                ),
                onSaved: (value) => _institution = value!.trim(),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _level,
                decoration: const InputDecoration(
                  labelText: 'Jenjang',
                  border: OutlineInputBorder(),
                ),
                items: _levels
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (value) => setState(() => _level = value!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Jurusan / Program Studi',
                  hintText: 'Contoh: Ilmu Komputer',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.requiredText(
                  value,
                  fieldName: 'Jurusan',
                  maxLength: 100,
                ),
                onSaved: (value) => _major = value!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _startController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Mulai',
                  hintText: 'Pilih tanggal',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _pickDate(isStart: true),
                validator: (_) => Validators.startDate(_startDate),
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
                  onTap: () => _pickDate(isStart: false),
                  validator: (_) => Validators.endDate(
                    _endDate,
                    start: _startDate,
                    isOngoing: _isOngoing,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'IPK (opsional)',
                  hintText: 'Contoh: 3.75',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: Validators.optionalGpa,
                onSaved: (value) => _gpa = value!.trim(),
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
