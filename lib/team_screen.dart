import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teammaker/match_screen.dart';
import 'package:teammaker/model/data_model.dart';
import 'package:teammaker/model/player_entry.dart';
import 'package:teammaker/theme/app_theme.dart';
import 'package:teammaker/utils/team_utils.dart';

class _DraggedPlayer {
  final String fromTeam;
  final PlayerEntry player;
  const _DraggedPlayer({required this.fromTeam, required this.player});
}

class TeamList extends StatefulWidget {
  final List<ListItem> items;
  final SettingsData settingsData;
  final SportPalette? sport;
  final void Function(PlayerEntry) onEditPlayer;

  const TeamList({
    super.key,
    required this.items,
    required this.settingsData,
    this.sport,
    required this.onEditPlayer,
  });

  @override
  State<TeamList> createState() => _TeamListState();
}

class _TeamListState extends State<TeamList> {
  late List<PlayerEntry> _allPlayers;

  @override
  void initState() {
    super.initState();
    _allPlayers = widget.items
        .whereType<MessageItem>()
        .map((item) => item.player)
        .toList();
  }

  void _movePlayer(PlayerEntry player, String toTeam) {
    if (player.team == toTeam) return;
    HapticFeedback.lightImpact();
    setState(() {
      player.team = toTeam;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    final Map<String, List<PlayerEntry>> teams = {};
    for (final p in _allPlayers) {
      final team = TeamUtils.normalizeTeamName(p.team);
      if (team != 'No team') {
        teams.putIfAbsent(team, () => []).add(p);
      }
    }
    final sortedTeamNames = teams.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Squad Breakdown'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: sortedTeamNames.length,
        itemBuilder: (context, index) {
          final teamName = sortedTeamNames[index];
          final players = teams[teamName]!;
          final teamColor = _teamColor(teamName, colorScheme);

          final int count = players.length;
          final double totalLevel = players.fold(0.0, (sum, p) => sum + p.level);
          final String avgLevel = (count > 0) ? (totalLevel / count).toStringAsFixed(1) : "0.0";

          return DragTarget<_DraggedPlayer>(
            onWillAcceptWithDetails: (details) => details.data.fromTeam != teamName,
            onAcceptWithDetails: (details) => _movePlayer(details.data.player, teamName),
            builder: (context, candidateData, rejectedData) {
              final isOver = candidateData.isNotEmpty;
              return Card(
                elevation: isOver ? 4 : 0,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isOver ? teamColor : colorScheme.outlineVariant,
                    width: isOver ? 2 : 1,
                  ),
                ),
                color: isOver ? teamColor.withAlpha(15) : colorScheme.surface,
                child: ExpansionTile(
                  initiallyExpanded: true,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  childrenPadding: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(side: BorderSide.none),
                  collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor: teamColor,
                    child: Text(
                      teamName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text('Team $teamName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        '$count players · Avg Lvl: $avgLevel · Total: ${totalLevel.toInt()}',
                        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        players.map((p) => p.name).join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: players.map((p) => _DraggableDetailedIcon(
                          player: p,
                          teamColor: teamColor,
                          onTap: () => widget.onEditPlayer(p),
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MatchScreen(widget.settingsData)));
        },
        label: const Text('View Matches'),
        icon: Icon(widget.sport?.icon ?? Icons.sports),
      ),
    );
  }

  Color _teamColor(String teamName, ColorScheme cs) {
    final colors = [
      cs.primary, cs.secondary, cs.tertiary,
      const Color(0xFF00897B), const Color(0xFF8E24AA),
      const Color(0xFFE53935), const Color(0xFFFF8F00),
    ];
    final hash = teamName.codeUnits.fold(0, (a, b) => a + b);
    return colors[hash % colors.length];
  }
}

class _DraggableDetailedIcon extends StatelessWidget {
  final PlayerEntry player;
  final Color teamColor;
  final VoidCallback onTap;

  const _DraggableDetailedIcon({
    required this.player,
    required this.teamColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFemale = player.gender.toUpperCase().startsWith('F');
    final colorScheme = Theme.of(context).colorScheme;

    final child = Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(50),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(80)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isFemale
                    ? Colors.pink.withAlpha(25)
                    : Colors.blue.withAlpha(25),
                child: Text(
                  player.name.isNotEmpty ? player.name.substring(0, 1).toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isFemale ? Colors.pink : Colors.blue,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(color: teamColor, shape: BoxShape.circle),
                child: Text(
                  player.level.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            player.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) => Icon(
              i < player.level ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 8,
              color: i < player.level ? Colors.amber : Colors.grey.shade400,
            )),
          ),
          Text(
            player.gender == 'X' ? 'NB' : (isFemale ? 'F' : 'M'),
            style: TextStyle(fontSize: 8, color: colorScheme.onSurfaceVariant),
          ),
          if (player.role != 'Any')
            Text(
              player.role,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 8, fontStyle: FontStyle.italic, color: teamColor),
            ),
        ],
      ),
    );

    return Draggable<_DraggedPlayer>(
      data: _DraggedPlayer(fromTeam: player.team, player: player),
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(opacity: 0.8, child: child),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: child),
      child: GestureDetector(
        onTap: onTap,
        child: child,
      ),
    );
  }
}

abstract class ListItem {
  Widget buildTitle(BuildContext context);
  Widget buildSubtitle(BuildContext context);
}

class HeadingItem implements ListItem {
  final String heading;
  final String subtitle;
  HeadingItem(this.heading, this.subtitle);
  @override
  Widget buildTitle(BuildContext context) => const SizedBox.shrink();
  @override
  Widget buildSubtitle(BuildContext context) => const SizedBox.shrink();
}

class MessageItem implements ListItem {
  final PlayerEntry player;
  MessageItem(this.player);
  @override
  Widget buildTitle(BuildContext context) => const SizedBox.shrink();
  @override
  Widget buildSubtitle(BuildContext context) => const SizedBox.shrink();
}
