class TeamUtils {
  static String normalizeTeamName(String? name) {
    if (name == null || name.trim().isEmpty) return 'No team';
    String lower = name.trim().toLowerCase();
    if (lower == '0' || lower == 'x' || lower == 'none') {
      return 'No team';
    }
    return name.trim();
  }
}
