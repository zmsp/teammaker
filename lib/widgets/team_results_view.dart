import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:teammaker/utils/team_utils.dart';

class TeamResultsView extends StatelessWidget {
  final PlutoGridStateManager? stateManager;

  const TeamResultsView({
    super.key,
    required this.stateManager,
  });

  @override
  Widget build(BuildContext context) {
    if (stateManager == null) return const SizedBox.shrink();

    Map<String, List<String>> teams = {};
    for (var row in stateManager!.rows) {
      String name = row.cells['name_field']?.value.toString() ?? '';
      String team = TeamUtils.normalizeTeamName(
          row.cells['team_field']?.value.toString());
      if (!teams.containsKey(team)) {
        teams[team] = [];
      }
      teams[team]!.add(name);
    }

    var sortedTeams = teams.keys.toList()..sort();
    return Column(
      children: sortedTeams.where((team) => team != 'No team').map((team) {
        return ExpansionTile(
          initiallyExpanded: true,
          title: Text('Team $team',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          children: teams[team]!
              .map((player) => ListTile(
                  leading: const Icon(Icons.person, size: 16),
                  title: Text(player)))
              .toList(),
        );
      }).toList(),
    );
  }
}

class UnassignedPlayersView extends StatelessWidget {
  final PlutoGridStateManager? stateManager;

  const UnassignedPlayersView({
    super.key,
    required this.stateManager,
  });

  @override
  Widget build(BuildContext context) {
    if (stateManager == null) return const SizedBox.shrink();

    var unassigned = stateManager!.rows.where((row) =>
        TeamUtils.normalizeTeamName(
            row.cells['team_field']?.value.toString()) ==
        'No team');

    if (unassigned.isEmpty) {
      return const ListTile(title: Text('All players assigned!'));
    }

    return Column(
      children: unassigned
          .map((row) => ListTile(
                leading:
                    const Icon(Icons.person_off, size: 16, color: Colors.grey),
                title: Text(row.cells['name_field']?.value.toString() ?? ''),
              ))
          .toList(),
    );
  }
}

class PlayerTeamDirectoryView extends StatelessWidget {
  final PlutoGridStateManager? stateManager;

  const PlayerTeamDirectoryView({
    super.key,
    required this.stateManager,
  });

  @override
  Widget build(BuildContext context) {
    if (stateManager == null) return const SizedBox.shrink();

    var sorted = List<PlutoRow>.from(stateManager!.rows);
    sorted.sort((a, b) =>
        (a.cells['name_field']?.value.toString().toLowerCase() ?? '').compareTo(
            b.cells['name_field']?.value.toString().toLowerCase() ?? ''));

    return Column(
      children: sorted.map((row) {
        String teamName = TeamUtils.normalizeTeamName(
            row.cells['team_field']?.value.toString());
        return ListTile(
          title: Text(row.cells['name_field']?.value.toString() ?? ''),
          trailing: Text(teamName == 'No team' ? 'No team' : 'Team: $teamName',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        );
      }).toList(),
    );
  }
}
