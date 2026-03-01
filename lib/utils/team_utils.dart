import 'package:flutter/material.dart';

class TeamUtils {
  static String normalizeTeamName(String? name) {
    if (name == null || name.trim().isEmpty) return 'No team';
    String lower = name.trim().toLowerCase();
    if (lower == '0' || lower == 'x' || lower == 'none') {
      return 'No team';
    }
    return name.trim();
  }

  static Color teamColor(String teamName, ColorScheme cs) {
    final colors = [
      cs.primary,
      cs.secondary,
      cs.tertiary,
      const Color(0xFF00897B),
      const Color(0xFF8E24AA),
      const Color(0xFFE53935),
      const Color(0xFFFF8F00),
    ];
    final hash = teamName.codeUnits.fold(0, (a, b) => a + b);
    return colors[hash % colors.length];
  }
}
