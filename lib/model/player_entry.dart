/// A lightweight, plain-Dart player record that replaces the heavy PlutoRow.
/// This is the single source-of-truth for player data across the whole app.
class PlayerEntry {
  String name;
  int level;
  String gender;
  String team;
  String role;
  bool checked;

  PlayerEntry({
    this.name = '',
    this.level = 3,
    this.gender = 'MALE',
    this.team = 'No team',
    this.role = 'Any',
    this.checked = true,
  });

  factory PlayerEntry.fromJson(Map<String, dynamic> json) => PlayerEntry(
        name: json['name_field'] as String? ?? '',
        level: (json['skill_level_field'] as num?)?.toInt() ?? 3,
        gender: json['gender_field'] as String? ?? 'MALE',
        team: json['team_field'] as String? ?? 'No team',
        role: json['role_field'] as String? ?? 'Any',
        checked: json['checked'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'name_field': name,
        'skill_level_field': level,
        'gender_field': gender,
        'team_field': team,
        'role_field': role,
        'checked': checked,
      };

  PlayerEntry copyWith({
    String? name,
    int? level,
    String? gender,
    String? team,
    String? role,
    bool? checked,
  }) =>
      PlayerEntry(
        name: name ?? this.name,
        level: level ?? this.level,
        gender: gender ?? this.gender,
        team: team ?? this.team,
        role: role ?? this.role,
        checked: checked ?? this.checked,
      );
}
