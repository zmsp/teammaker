import 'package:flutter/material.dart';
import 'package:teammaker/match_screen.dart';
import 'package:teammaker/model/data_model.dart';
import 'package:teammaker/model/player_entry.dart';
import 'package:teammaker/theme/app_theme.dart';
import 'package:teammaker/utils/team_utils.dart';
import 'package:teammaker/widgets/team_results_view.dart';

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
    setState(() {
      player.team = toTeam;
    });
  }

  @override
  Widget build(BuildContext context) {
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

          return TeamDropZone(
            teamName: teamName,
            players: players,
            onPlayerMoved: _movePlayer,
            onEditPlayer: widget.onEditPlayer,
            initiallyExpanded: true,
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
