import 'package:teammaker/model/data_model.dart';
import 'package:teammaker/model/player_entry.dart';
import 'package:teammaker/theme/app_theme.dart';

class TeamGenerator {
  static Map<String, List<PlayerEntry>> generateTeams(
      List<PlayerEntry> dat, SettingsData settingsData,
      {SportPalette? sport}) {
    // Only work on checked (active) players
    List<PlayerEntry> tmpRows = dat.where((p) => p.checked).toList();

    Map<String, List<PlayerEntry>> teamsList = {};
    for (var i = 1; i <= settingsData.teamCount; i++) {
      teamsList[i.toString()] = [];
    }

    var keys = teamsList.keys.toList();
    int size = teamsList.length;

    if (settingsData.o == GenOption.division) {
      int totalTeams = settingsData.teamCount;
      int numDivisions = settingsData.division;
      if (numDivisions <= 0) numDivisions = 1;
      if (numDivisions > totalTeams) numDivisions = totalTeams;

      tmpRows.sort((a, b) {
        int cmp = b.level.compareTo(a.level);
        if (cmp != 0) return cmp;
        return b.gender.compareTo(a.gender);
      });

      List<List<String>> divisionTeams = [];
      int teamsPerDiv = (totalTeams / numDivisions).ceil();
      for (int i = 0; i < totalTeams; i += teamsPerDiv) {
        int end = i + teamsPerDiv;
        if (end > totalTeams) end = totalTeams;
        divisionTeams.add(keys.sublist(i, end));
      }

      int playerIndex = 0;
      for (int i = 0; i < divisionTeams.length; i++) {
        List<String> currentDivTeams = divisionTeams[i];
        int numPlayersInThisDiv =
            ((currentDivTeams.length / totalTeams) * tmpRows.length).round();
        if (i == divisionTeams.length - 1) {
          numPlayersInThisDiv = tmpRows.length - playerIndex;
        }
        if (numPlayersInThisDiv <= 0) continue;

        List<PlayerEntry> divPlayers =
            tmpRows.sublist(playerIndex, playerIndex + numPlayersInThisDiv);
        playerIndex += numPlayersInThisDiv;

        int teamsInDiv = currentDivTeams.length;
        for (var j = 0; j < divPlayers.length; j += teamsInDiv) {
          int end = j + teamsInDiv;
          if (end > divPlayers.length) end = divPlayers.length;
          List<PlayerEntry> slice = divPlayers.sublist(j, end);
          currentDivTeams.shuffle();
          for (int k = 0; k < slice.length; k++) {
            teamsList[currentDivTeams[k]]?.add(slice[k]);
          }
        }
      }
    } else if (settingsData.o == GenOption.distribute) {
      tmpRows.sort((a, b) {
        int cmp = a.level.compareTo(b.level);
        if (cmp != 0) return cmp;
        return b.gender.compareTo(a.gender);
      });

      var start = 0;
      for (var i = 0; i < tmpRows.length; i = i + size) {
        int end = i + size <= tmpRows.length ? i + size : tmpRows.length;
        List<PlayerEntry> sublist = tmpRows.sublist(start, end);
        keys.shuffle();
        int keyI = 0;
        for (var value in sublist) {
          teamsList[keys[keyI]]?.add(value);
          keyI++;
        }
        start = i + size;
      }
    } else if (settingsData.o == GenOption.evenGender) {
      tmpRows.shuffle();

      Map<String, List<PlayerEntry>> genderGroups = {};
      for (var player in tmpRows) {
        genderGroups.putIfAbsent(player.gender, () => []).add(player);
      }

      genderGroups.forEach((gender, players) {
        players.sort((a, b) => b.level.compareTo(a.level));
      });

      List<String> teamKeys = teamsList.keys.toList();
      var sortedGenders = genderGroups.keys.toList()
        ..sort((a, b) =>
            genderGroups[b]!.length.compareTo(genderGroups[a]!.length));

      for (var gender in sortedGenders) {
        List<PlayerEntry> players = genderGroups[gender]!;
        int n = teamKeys.length;
        if (n == 0) continue;

        List<int> snakeIndices = [];
        for (int i = 0; i < players.length; i++) {
          int snakeIdx = i % (2 * n);
          if (snakeIdx < n) {
            snakeIndices.add(snakeIdx);
          } else {
            snakeIndices.add((2 * n - 1) - snakeIdx);
          }
        }

        List<int> distributionCounts = List.generate(n, (_) => 0);
        for (int idx in snakeIndices) {
          distributionCounts[idx]++;
        }

        List<String> sortedTeams = List.from(teamKeys)..shuffle();
        sortedTeams.sort(
            (a, b) => teamsList[a]!.length.compareTo(teamsList[b]!.length));

        List<int> sortedRelIndices = List.generate(n, (i) => i);
        sortedRelIndices.sort(
            (a, b) => distributionCounts[b].compareTo(distributionCounts[a]));

        Map<int, String> indexToTeam = {};
        for (int i = 0; i < n; i++) {
          indexToTeam[sortedRelIndices[i]] = sortedTeams[i];
        }

        for (int i = 0; i < players.length; i++) {
          String targetTeam = indexToTeam[snakeIndices[i]]!;
          teamsList[targetTeam]?.add(players[i]);
        }
      }
    } else if (settingsData.o == GenOption.roleBalanced) {
      Map<String, List<PlayerEntry>> roleGroups = {};
      List<PlayerEntry> fillers = [];

      for (var player in tmpRows) {
        if (player.role == 'Any' ||
            player.role == 'none' ||
            player.role.isEmpty) {
          fillers.add(player);
        } else {
          roleGroups.putIfAbsent(player.role, () => []).add(player);
        }
      }

      roleGroups.forEach((role, players) {
        players.sort((a, b) => b.level.compareTo(a.level));
      });
      fillers.sort((a, b) => b.level.compareTo(a.level));

      List<String> teamKeys = teamsList.keys.toList();
      if (teamKeys.isNotEmpty) {
        List<String> priorityRoles = [];
        if (sport != null) {
          priorityRoles = sport.idealRoleDistribution.keys.toList();
        }

        List<String> allRoles = List.from(priorityRoles);
        for (var r in roleGroups.keys) {
          if (!allRoles.contains(r)) allRoles.add(r);
        }

        for (var role in allRoles) {
          List<PlayerEntry>? players = roleGroups[role];
          if (players == null || players.isEmpty) continue;
          for (var player in players) {
            teamKeys.sort(
                (a, b) => teamsList[a]!.length.compareTo(teamsList[b]!.length));
            teamsList[teamKeys.first]?.add(player);
          }
        }

        for (var player in fillers) {
          teamKeys.sort(
              (a, b) => teamsList[a]!.length.compareTo(teamsList[b]!.length));
          teamsList[teamKeys.first]?.add(player);
        }
      }
    } else if (settingsData.o == GenOption.random) {
      tmpRows.shuffle();
      for (var i = 0; i < tmpRows.length; i = i + size) {
        int end = i + size <= tmpRows.length ? i + size : tmpRows.length;
        List<PlayerEntry> sublist = tmpRows.sublist(i, end);
        keys.shuffle();
        int keyI = 0;
        for (var value in sublist) {
          if (keyI < keys.length) {
            teamsList[keys[keyI]]?.add(value);
            keyI++;
          }
        }
      }
    }

    return teamsList;
  }
}
