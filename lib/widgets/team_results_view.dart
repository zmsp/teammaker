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
// TeamResultsView — condensed grid view
// ─────────────────────────────────────────────────────────────────────────────
class TeamResultsView extends StatefulWidget {
  final List<PlayerEntry> players;
  final void Function(PlayerEntry) onEditPlayer;
  final VoidCallback? onChanged;

  const TeamResultsView({
    super.key,
    required this.players,
    required this.onEditPlayer,
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
                'Drag to switch • Tap to edit',
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
              onPlayerMoved: _movePlayer,
              onEditPlayer: widget.onEditPlayer,
            ),
          );
        }),
      ],
    );
  }
}

class _TeamDropZone extends StatefulWidget {
  final String teamName;
  final List<PlayerEntry> players;
  final void Function(PlayerEntry player, String toTeam) onPlayerMoved;
  final void Function(PlayerEntry) onEditPlayer;

  const _TeamDropZone({
    required this.teamName,
    required this.players,
    required this.onPlayerMoved,
    required this.onEditPlayer,
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
          padding: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDragOver
                ? teamColor.withValues(alpha: 0.15)
                : colorScheme.surfaceContainer,
            border: Border.all(
              color: isDragOver ? teamColor : colorScheme.outlineVariant,
              width: isDragOver ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            children: [
              // ── Team Header ──────────────────────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: teamColor.withValues(alpha: 0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Row(
                  children: [
                    Text('Team ${widget.teamName}',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: teamColor)),
                    const Spacer(),
                    Text('${widget.players.length} Players',
                        style: TextStyle(fontSize: 11, color: teamColor)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // ── Circular Grid ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.start,
                  children: widget.players.map((p) {
                    return _CircularPlayerAvatar(
                      player: p,
                      teamColor: teamColor,
                      onTap: () => widget.onEditPlayer(p),
                    );
                  }).toList(),
                ),
              ),
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

class _CircularPlayerAvatar extends StatelessWidget {
  final PlayerEntry player;
  final Color teamColor;
  final VoidCallback onTap;

  const _CircularPlayerAvatar({
    required this.player,
    required this.teamColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFemale = player.gender.toUpperCase().startsWith('F');
    final colorScheme = Theme.of(context).colorScheme;

    return Draggable<_DraggedPlayer>(
      data: _DraggedPlayer(
        name: player.name,
        fromTeam: player.team,
        player: player,
      ),
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.8,
          child: CircleAvatar(
            radius: 24,
            backgroundColor: teamColor,
            child: Text(player.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
      child: GestureDetector(
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
                    radius: 20,
                    backgroundColor: isFemale
                        ? Colors.pink.withValues(alpha: 0.1)
                        : Colors.blue.withValues(alpha: 0.1),
                    child: Text(
                      player.name.isNotEmpty
                          ? player.name.substring(0, 1).toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isFemale ? Colors.pink : Colors.blue,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      color: teamColor, shape: BoxShape.circle),
                  child: Text(
                    player.level.toString(),
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
              width: 50,
              child: Text(
                player.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ),
            if (player.role != 'Any')
              Text(
                player.role,
                style: TextStyle(fontSize: 8, color: colorScheme.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }
}

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
    final unassigned =
        players.where((p) => TeamUtils.normalizeTeamName(p.team) == 'No team');
    if (unassigned.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: unassigned.map((p) {
          return _CircularPlayerAvatar(
            player: p,
            teamColor: Colors.grey,
            onTap: () {}, // Handled in home_screen
          );
        }).toList(),
      ),
    );
  }
}

class PlayerTeamDirectoryView extends StatelessWidget {
  final List<PlayerEntry> players;

  const PlayerTeamDirectoryView({
    super.key,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = List<PlayerEntry>.from(players)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
      itemBuilder: (context, index) {
        final p = sorted[index];
        final isAssigned = TeamUtils.normalizeTeamName(p.team) != 'No team';
        return ListTile(
          dense: true,
          title: Text(p.name, style: const TextStyle(fontSize: 13)),
          trailing: Text(
            isAssigned ? 'Team ${p.team}' : 'Unassigned',
            style: TextStyle(
              fontSize: 11,
              color: isAssigned ? Theme.of(context).colorScheme.primary : Colors.grey,
            ),
          ),
        );
      },
    );
  }
}
