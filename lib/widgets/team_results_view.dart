import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teammaker/model/player_entry.dart';
import 'package:teammaker/utils/team_utils.dart';
import 'package:teammaker/widgets/player_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Player data passed around during drag
// ─────────────────────────────────────────────────────────────────────────────
class DraggedPlayer {
  final String fromTeam;
  final PlayerEntry player;

  const DraggedPlayer({
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
    if (player.team == toTeam) return;
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
            child: TeamDropZone(
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

class TeamDropZone extends StatefulWidget {
  final String teamName;
  final List<PlayerEntry> players;
  final void Function(PlayerEntry player, String toTeam) onPlayerMoved;
  final void Function(PlayerEntry) onEditPlayer;
  final bool initiallyExpanded;

  const TeamDropZone({
    super.key,
    required this.teamName,
    required this.players,
    required this.onPlayerMoved,
    required this.onEditPlayer,
    this.initiallyExpanded = true,
  });

  @override
  State<TeamDropZone> createState() => _TeamDropZoneState();
}

class _TeamDropZoneState extends State<TeamDropZone> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final teamColor = TeamUtils.teamColor(widget.teamName, colorScheme);

    final int count = widget.players.length;
    final double totalLevel =
        widget.players.fold(0.0, (sum, p) => sum + p.level);
    final String avgLevel =
        (count > 0) ? (totalLevel / count).toStringAsFixed(1) : "0.0";

    return DragTarget<DraggedPlayer>(
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
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ExpansionTile(
              initiallyExpanded: widget.initiallyExpanded,
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              childrenPadding: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(side: BorderSide.none),
              collapsedShape:
                  const RoundedRectangleBorder(side: BorderSide.none),
              leading: CircleAvatar(
                radius: 12,
                backgroundColor: teamColor,
                child: Text(
                  widget.teamName.length > 1
                      ? widget.teamName.substring(0, 1).toUpperCase()
                      : widget.teamName.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold),
                ),
              ),
              title: Text('Team ${widget.teamName}',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: teamColor)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count players · Avg Lvl: $avgLevel · Total: ${totalLevel.toInt()}',
                    style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              children: [
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: widget.players.map((p) {
                      return PlayerAvatar.fromEntry(
                        p,
                        teamColor,
                        onTap: () => widget.onEditPlayer(p),
                        isDraggable: true,
                        dragData:
                            DraggedPlayer(fromTeam: widget.teamName, player: p),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class UnassignedPlayersView extends StatelessWidget {
  final List<PlayerEntry> players;
  final void Function(PlayerEntry) onEditPlayer;
  final VoidCallback? onChanged;

  const UnassignedPlayersView({
    super.key,
    required this.players,
    required this.onEditPlayer,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final unassigned =
        players.where((p) => TeamUtils.normalizeTeamName(p.team) == 'No team');
    if (unassigned.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: unassigned.map((p) {
          return PlayerAvatar.fromEntry(
            p,
            Colors.grey,
            onTap: () => onEditPlayer(p),
            isDraggable: true,
            dragData: DraggedPlayer(fromTeam: 'No team', player: p),
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
              color: isAssigned
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
          ),
        );
      },
    );
  }
}
