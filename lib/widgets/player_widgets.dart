import 'package:flutter/material.dart';
import 'package:teammaker/model/player_entry.dart';
import 'package:teammaker/model/player_model.dart';

/// A set of shared UI components for representing players.
///
/// [PlayerCard] is used for list views (like Add Players).
/// [PlayerAvatar] is used for grid/wrap views (like Teams/Unassigned).
///
/// Both follow the user's rule: "level ★ · m/f · role" on one line.

class PlayerInfoRow extends StatelessWidget {
  final int level;
  final String gender;
  final String role;
  final Color? color;
  final bool isCondensed;

  const PlayerInfoRow({
    super.key,
    required this.level,
    required this.gender,
    required this.role,
    this.color,
    this.isCondensed = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isFemale = gender.toUpperCase().startsWith('F');
    final textColor = color ?? colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$level★',
            style: TextStyle(
              fontSize: isCondensed ? 10 : 11,
              color: Colors.amber.shade900,
              fontWeight: FontWeight.bold,
            )),
        Text(' · ',
            style: TextStyle(
                color: colorScheme.outline, fontSize: isCondensed ? 10 : 11)),
        Text(
          gender == 'X' ? 'NB' : (isFemale ? 'F' : 'M'),
          style: TextStyle(
            fontSize: isCondensed ? 10 : 11,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (role != 'Any') ...[
          Text(' · ',
              style: TextStyle(
                  color: colorScheme.outline, fontSize: isCondensed ? 10 : 11)),
          Flexible(
            child: Text(
              role,
              style: TextStyle(
                fontSize: isCondensed ? 10 : 11,
                fontStyle: FontStyle.italic,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

class PlayerAvatar extends StatelessWidget {
  final String name;
  final int level;
  final String gender;
  final String role;
  final Color teamColor;
  final VoidCallback? onTap;
  final double radius;
  final bool isDraggable;
  final Object? dragData;

  const PlayerAvatar({
    super.key,
    required this.name,
    required this.level,
    required this.gender,
    required this.role,
    required this.teamColor,
    this.onTap,
    this.radius = 22,
    this.isDraggable = false,
    this.dragData,
  });

  factory PlayerAvatar.fromEntry(PlayerEntry e, Color teamColor,
      {VoidCallback? onTap, bool isDraggable = false, Object? dragData}) {
    return PlayerAvatar(
      name: e.name,
      level: e.level,
      gender: e.gender,
      role: e.role,
      teamColor: teamColor,
      onTap: onTap,
      isDraggable: isDraggable,
      dragData: dragData,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFemale = gender.toUpperCase().startsWith('F');

    Widget avatar = GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: teamColor, width: 2),
                ),
                child: CircleAvatar(
                  radius: radius,
                  backgroundColor: isFemale
                      ? Colors.pink.withValues(alpha: 0.1)
                      : Colors.blue.withValues(alpha: 0.1),
                  child: Text(
                    name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: radius * 0.9,
                      fontWeight: FontWeight.bold,
                      color: isFemale ? Colors.pink : Colors.blue,
                    ),
                  ),
                ),
              ),
              // Level Badge
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: teamColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  level.toString(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: radius * 3,
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          PlayerInfoRow(
              level: level, gender: gender, role: role, isCondensed: true),
        ],
      ),
    );

    if (isDraggable && dragData != null) {
      return Draggable<Object>(
        data: dragData!,
        feedback: Material(
            color: Colors.transparent,
            child: Opacity(opacity: 0.8, child: avatar)),
        childWhenDragging: Opacity(opacity: 0.3, child: avatar),
        child: avatar,
      );
    }
    return avatar;
  }
}

class PlayerCard extends StatelessWidget {
  final String name;
  final int level;
  final String gender;
  final String role;
  final Color? teamColor;
  final VoidCallback? onTap;

  const PlayerCard({
    super.key,
    required this.name,
    required this.level,
    required this.gender,
    required this.role,
    this.teamColor,
    this.onTap,
  });

  factory PlayerCard.fromModel(PlayerModel m, {VoidCallback? onTap}) {
    return PlayerCard(
      name: m.name,
      level: m.level,
      gender: m.gender,
      role: m.role,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isFemale = gender.toUpperCase().startsWith('F');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isFemale
                    ? Colors.pink.withValues(alpha: 0.1)
                    : Colors.blue.withValues(alpha: 0.1),
                child: Text(
                  name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isFemale ? Colors.pink : Colors.blue),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14)),
                    PlayerInfoRow(level: level, gender: gender, role: role),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
