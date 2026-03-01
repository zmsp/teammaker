import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teammaker/model/player_entry.dart';
import 'package:teammaker/utils/team_utils.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Player data passed around during drag
// ─────────────────────────────────────────────────────────────────────────────
class _DraggedPlayer {
  final String name;
  final String fromTeam;
  final PlayerEntry player;

  const _DraggedPlayer({
    required this.name,
    required this.fromTeam,
    required this.player,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// TeamResultsView — drag-and-drop, uses plain PlayerEntry list
// ─────────────────────────────────────────────────────────────────────────────
class TeamResultsView extends StatefulWidget {
  final List<PlayerEntry> players;
  final VoidCallback? onChanged;

  const TeamResultsView({
    super.key,
    required this.players,
    this.onChanged,
  });

  @override
  State<TeamResultsView> createState() => _TeamResultsViewState();
}

class _TeamResultsViewState extends State<TeamResultsView> {
  late Map<String, List<PlayerEntry>> _teams;

  @override
  void initState() {
    super.initState();
    _rebuildTeams();
  }

  @override
  void didUpdateWidget(TeamResultsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _rebuildTeams();
  }

  void _rebuildTeams() {
    final Map<String, List<PlayerEntry>> built = {};
    for (final player in widget.players) {
      final team = TeamUtils.normalizeTeamName(player.team);
      if (team == 'No team') continue;
      built.putIfAbsent(team, () => []).add(player);
    }
    _teams = built;
  }

  void _movePlayer(PlayerEntry player, String toTeam) {
    player.team = toTeam;
    HapticFeedback.lightImpact();
    setState(() {
      _rebuildTeams();
    });
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sortedTeams = _teams.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: Row(
            children: [
              Icon(Icons.drag_indicator,
                  size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                'Drag a player to switch teams',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        ...sortedTeams.map((teamName) {
          final teamPlayers = _teams[teamName] ?? [];
          return RepaintBoundary(
            child: _TeamDropZone(
              teamName: teamName,
              players: teamPlayers,
              allTeamNames: sortedTeams,
              onPlayerMoved: _movePlayer,
            ),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Drop zone card for a single team
// ─────────────────────────────────────────────────────────────────────────────
class _TeamDropZone extends StatefulWidget {
  final String teamName;
  final List<PlayerEntry> players;
  final List<String> allTeamNames;
  final void Function(PlayerEntry player, String toTeam) onPlayerMoved;

  const _TeamDropZone({
    required this.teamName,
    required this.players,
    required this.allTeamNames,
    required this.onPlayerMoved,
  });

  @override
  State<_TeamDropZone> createState() => _TeamDropZoneState();
}

class _TeamDropZoneState extends State<_TeamDropZone> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final teamColor = _teamColor(widget.teamName, colorScheme);

    return DragTarget<_DraggedPlayer>(
      onWillAcceptWithDetails: (details) =>
          details.data.fromTeam != widget.teamName,
      onAcceptWithDetails: (details) {
        widget.onPlayerMoved(details.data.player, widget.teamName);
        if (mounted) setState(() => _isDragOver = false);
      },
      onMove: (_) {
        if (!_isDragOver && mounted) setState(() => _isDragOver = true);
      },
      onLeave: (_) {
        if (_isDragOver && mounted) setState(() => _isDragOver = false);
      },
      builder: (context, candidateData, rejectedData) {
        final isDragOver = candidateData.isNotEmpty || _isDragOver;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDragOver
                ? teamColor.withValues(alpha: 0.15)
                : colorScheme.surfaceContainer,
            border: Border.all(
              color: isDragOver ? teamColor : colorScheme.outlineVariant,
              width: isDragOver ? 2.0 : 1.0,
            ),
            boxShadow: isDragOver
                ? [
                    BoxShadow(
                      color: teamColor.withValues(alpha: 0.25),
                      blurRadius: 12,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: Column(
            children: [
              // ── Team Header ──────────────────────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: teamColor.withValues(alpha: 0.12),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: teamColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.teamName.length > 2
                              ? widget.teamName.substring(0, 2).toUpperCase()
                              : widget.teamName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Team ${widget.teamName}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: teamColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: teamColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${widget.players.length} players',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: teamColor,
                        ),
                      ),
                    ),
                    if (isDragOver) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.add_circle, color: teamColor, size: 20),
                    ],
                  ],
                ),
              ),

              // ── Player List ──────────────────────────────────────────────
              if (widget.players.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Drop a player here',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                  ),
                )
              else
                ...widget.players.map((player) {
                  final name = player.name;
                  final role = player.role;
                  final gender = player.gender;
                  final level = player.level;

                  final dragData = _DraggedPlayer(
                    name: name,
                    fromTeam: widget.teamName,
                    player: player,
                  );

                  return RepaintBoundary(
                    child: _DraggablePlayerTile(
                      dragData: dragData,
                      name: name,
                      role: role,
                      gender: gender,
                      level: level,
                      teamColor: teamColor,
                    ),
                  );
                }),

              const SizedBox(height: 4),
            ],
          ),
        );
      },
    );
  }

  Color _teamColor(String teamName, ColorScheme cs) {
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

// ─────────────────────────────────────────────────────────────────────────────
// Draggable player tile — const where possible
// ─────────────────────────────────────────────────────────────────────────────
class _DraggablePlayerTile extends StatelessWidget {
  final _DraggedPlayer dragData;
  final String name;
  final String role;
  final String gender;
  final int level;
  final Color teamColor;

  const _DraggablePlayerTile({
    required this.dragData,
    required this.name,
    required this.role,
    required this.gender,
    required this.level,
    required this.teamColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFemale = gender.toUpperCase().startsWith('F');

    return Draggable<_DraggedPlayer>(
      data: dragData,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: teamColor.withValues(alpha: 0.95),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.drag_indicator, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildTile(colorScheme, isFemale),
      ),
      child: _buildTile(colorScheme, isFemale),
    );
  }

  Widget _buildTile(ColorScheme colorScheme, bool isFemale) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.drag_indicator,
                size: 16,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(width: 4),
            CircleAvatar(
              radius: 14,
              backgroundColor: isFemale
                  ? Colors.pink.withValues(alpha: 0.15)
                  : Colors.blue.withValues(alpha: 0.12),
              child: Text(
                isFemale ? '♀' : '♂',
                style: TextStyle(
                  fontSize: 13,
                  color: isFemale ? Colors.pink : Colors.blue,
                ),
              ),
            ),
          ],
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: (role.isNotEmpty && role != 'Any')
            ? Text(
                role,
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic),
              )
            : null,
        trailing: _StarRating(level: level, color: teamColor),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compact star rating — const-safe
// ─────────────────────────────────────────────────────────────────────────────
class _StarRating extends StatelessWidget {
  final int level;
  final Color color;

  const _StarRating({required this.level, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < level ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 13,
          color: i < level ? color : Colors.grey.shade400,
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UnassignedPlayersView — draggable unassigned players list
// ─────────────────────────────────────────────────────────────────────────────
class UnassignedPlayersView extends StatelessWidget {
  final List<PlayerEntry> players;
  final VoidCallback? onChanged;

  const UnassignedPlayersView({
    super.key,
    required this.players,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final unassigned =
        players.where((p) => TeamUtils.normalizeTeamName(p.team) == 'No team');

    if (unassigned.isEmpty) {
      return ListTile(
        leading: Icon(Icons.check_circle, color: colorScheme.primary),
        title: const Text('All players assigned!'),
      );
    }

    return Column(
      children: unassigned.map((player) {
        final name = player.name;
        final role = player.role;
        final gender = player.gender;
        final level = player.level;
        final dragData = _DraggedPlayer(
          name: name,
          fromTeam: 'No team',
          player: player,
        );
        final isFemale = gender.toUpperCase().startsWith('F');

        return Draggable<_DraggedPlayer>(
          data: dragData,
          feedback: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.drag_indicator,
                      color: colorScheme.onErrorContainer, size: 16),
                  const SizedBox(width: 8),
                  Text(name,
                      style: TextStyle(
                          color: colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w800,
                          fontSize: 14)),
                ],
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _unassignedTile(
                context, colorScheme, name, role, isFemale, level),
          ),
          child: _unassignedTile(
              context, colorScheme, name, role, isFemale, level),
        );
      }).toList(),
    );
  }

  Widget _unassignedTile(BuildContext context, ColorScheme cs, String name,
      String role, bool isFemale, int level) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.error.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.drag_indicator,
                size: 16, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(width: 4),
            CircleAvatar(
              radius: 14,
              backgroundColor: cs.errorContainer,
              child: Text(
                isFemale ? '♀' : '♂',
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
        title: Text(name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: (role.isNotEmpty && role != 'Any')
            ? Text(role,
                style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                    fontStyle: FontStyle.italic))
            : null,
        trailing: _StarRating(level: level, color: cs.error),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PlayerTeamDirectoryView — alphabetical read-only list
// ─────────────────────────────────────────────────────────────────────────────
class PlayerTeamDirectoryView extends StatelessWidget {
  final List<PlayerEntry> players;

  const PlayerTeamDirectoryView({
    super.key,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final sorted = List<PlayerEntry>.from(players)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Column(
      children: sorted.map((player) {
        final teamName = TeamUtils.normalizeTeamName(player.team);
        final isAssigned = teamName != 'No team';
        return ListTile(
          dense: true,
          leading: Icon(
            isAssigned ? Icons.person : Icons.person_off,
            color: isAssigned ? colorScheme.primary : colorScheme.error,
            size: 20,
          ),
          title: Text(player.name),
          subtitle: (player.role.isNotEmpty && player.role != 'Any')
              ? Text(player.role,
                  style: const TextStyle(
                      fontSize: 11, fontStyle: FontStyle.italic))
              : null,
          trailing: Chip(
            label: Text(
              isAssigned ? 'Team $teamName' : 'Unassigned',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isAssigned ? colorScheme.primary : colorScheme.error,
              ),
            ),
            backgroundColor:
                (isAssigned ? colorScheme.primary : colorScheme.error)
                    .withValues(alpha: 0.1),
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            visualDensity: VisualDensity.compact,
          ),
        );
      }).toList(),
    );
  }
}
