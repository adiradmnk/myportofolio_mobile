import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// Proyek portofolio yang disinkronkan dengan API Django REST Framework.
///
/// Field mengikuti `ProjectSerializer` di repositori `myportofolio`:
/// `id`, `title`, `role`, `description`, `link`, dan `star_count`.
/// Field read-only (`id`, `star_count`) tidak dikirim saat POST.
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    required this.title,
    required this.role,
    required this.description,
    this.link = '',
    this.id,
    this.starCount = 0,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  /// UUID yang dibuat oleh Django, sehingga tidak dikirim saat POST.
  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final String role;
  final String description;

  /// `URLField(blank=True, null=True)`: bisa `null` di API, jadi default `''`.
  @JsonKey(defaultValue: '')
  final String link;

  /// Jumlah pengguna yang memberi bintang (read-only di serializer).
  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
