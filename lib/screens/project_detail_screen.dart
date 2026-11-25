import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';

/// Detail satu proyek yang dipilih dari [ProjectListScreen].
class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Proyek',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project.title, style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Chip(
              avatar: const Icon(Icons.person, size: 18),
              label: Text(project.role),
            ),
            const SizedBox(height: 16),
            Text('Deskripsi', style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(project.description),
            const SizedBox(height: 16),
            Text('Tautan Proyek', style: textTheme.titleMedium),
            const SizedBox(height: 4),
            SelectableText(project.link.isEmpty ? '-' : project.link),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${project.starCount} bintang'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
