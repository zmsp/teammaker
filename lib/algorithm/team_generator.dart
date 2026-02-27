import 'package:teammaker/model/data_model.dart';
import 'package:pluto_grid/pluto_grid.dart';

class TeamGenerator {
  static Map<String, List<PlutoRow>> generateTeams(
      List<PlutoRow> dat, SettingsData settingsData) {
    List<PlutoRow> tmpRows = [];
    for (var i = 0; i < dat.length; i++) {
      if (dat[i].checked ?? false) {
        tmpRows.add(dat[i]);
      } else {
        //TODO unassign team
      }
    }

    Map<String, List<PlutoRow>> teamsList = {};
    for (var i = 1; i <= settingsData.teamCount; i++) {
      teamsList[i.toString()] = [];
    }

    var keys = teamsList.keys.toList();
    int size = teamsList.length;

    if (settingsData.o == GenOption.division) {
      // Division algorithm
      int totalTeams = settingsData.teamCount;
      int numDivisions = settingsData.division;
      if (numDivisions <= 0) numDivisions = 1;
      if (numDivisions > totalTeams) numDivisions = totalTeams;

      tmpRows.sort((a, b) {
        int cmp = (b.cells["skill_level_field"]?.value as num)
            .compareTo(a.cells["skill_level_field"]?.value as num);
        if (cmp != 0) return cmp;
        return (b.cells["gender_field"]?.value.toString() ?? "")
            .compareTo(a.cells["gender_field"]?.value.toString() ?? "");
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

        List<PlutoRow> divPlayers =
            tmpRows.sublist(playerIndex, playerIndex + numPlayersInThisDiv);
        playerIndex += numPlayersInThisDiv;

        int teamsInDiv = currentDivTeams.length;
        for (var j = 0; j < divPlayers.length; j += teamsInDiv) {
          int end = j + teamsInDiv;
          if (end > divPlayers.length) end = divPlayers.length;
          List<PlutoRow> slice = divPlayers.sublist(j, end);
          currentDivTeams.shuffle();
          for (int k = 0; k < slice.length; k++) {
            teamsList[currentDivTeams[k]]?.add(slice[k]);
          }
        }
      }
    } else if (settingsData.o == GenOption.distribute) {
      // Distribute algorithm
      tmpRows.sort((a, b) {
        int cmp = (a.cells["skill_level_field"]?.value as num)
            .compareTo(b.cells["skill_level_field"]?.value as num);
        if (cmp != 0) return cmp;
        return (b.cells["gender_field"]?.value.toString() ?? "")
            .compareTo(a.cells["gender_field"]?.value.toString() ?? "");
      });

      var start = 0;
      for (var i = 0; i < tmpRows.length; i = i + size) {
        int end = i + size <= tmpRows.length ? i + size : tmpRows.length;
        List<PlutoRow> sublist = tmpRows.sublist(start, end);
        keys.shuffle();
        int keyI = 0;

        for (var value in sublist) {
          teamsList[keys[keyI]]?.add(value);
          keyI++;
        }
        start = i + size;
      }
    } else if (settingsData.o == GenOption.evenGender) {
      // Improved Even Gender algorithm with Snake Distribution and Population Balancing
      tmpRows.shuffle(); // Initial randomization for variety

      // Group by gender
      Map<String, List<PlutoRow>> genderGroups = {};
      for (var row in tmpRows) {
        String gender = row.cells["gender_field"]?.value.toString() ?? "X";
        genderGroups.putIfAbsent(gender, () => []).add(row);
      }

      // Sort within each gender by level (descending)
      genderGroups.forEach((gender, players) {
        players.sort((a, b) {
          return (b.cells["skill_level_field"]?.value as num)
              .compareTo(a.cells["skill_level_field"]?.value as num);
        });
      });

      List<String> teamKeys = teamsList.keys.toList();

      // Sort gender groups by size descending to distribute larger groups first
      var sortedGenders = genderGroups.keys.toList()
        ..sort((a, b) =>
            genderGroups[b]!.length.compareTo(genderGroups[a]!.length));

      for (var gender in sortedGenders) {
        List<PlutoRow> players = genderGroups[gender]!;
        int n = teamKeys.length;
        if (n == 0) continue;

        // 1. Generate snake sequence of indices for these players
        // Sequence: 0, 1, ..., n-1, n-1, n-2, ..., 0
        List<int> snakeIndices = [];
        for (int i = 0; i < players.length; i++) {
          int snakeIdx = i % (2 * n);
          if (snakeIdx < n) {
            snakeIndices.add(snakeIdx);
          } else {
            snakeIndices.add((2 * n - 1) - snakeIdx);
          }
        }

        // 2. Count how many players each relative index will get
        List<int> distributionCounts = List.generate(n, (index) => 0);
        for (int idx in snakeIndices) {
          distributionCounts[idx]++;
        }

        // 3. Map these indices to actual teams based on current populations
        // To keep it fair, the indices that get more players (from the partial snake)
        // should be assigned to the teams that currently have the fewest players.

        // Get teams sorted by current count (ascending)
        // Shuffle first for random tie-breaking
        List<String> sortedTeams = List.from(teamKeys)..shuffle();
        sortedTeams.sort(
            (a, b) => teamsList[a]!.length.compareTo(teamsList[b]!.length));

        // Get relative indices sorted by their player count (descending)
        List<int> sortedRelIndices = List.generate(n, (i) => i);
        sortedRelIndices.sort(
            (a, b) => distributionCounts[b].compareTo(distributionCounts[a]));

        // Create the mapping: relative_index -> teamKey
        Map<int, String> indexToTeam = {};
        for (int i = 0; i < n; i++) {
          indexToTeam[sortedRelIndices[i]] = sortedTeams[i];
        }

        // 4. Assign players to the mapped teams
        for (int i = 0; i < players.length; i++) {
          String targetTeam = indexToTeam[snakeIndices[i]]!;
          teamsList[targetTeam]?.add(players[i]);
        }
      }
    } else if (settingsData.o == GenOption.random) {
      // Random algorithm
      tmpRows.shuffle();
      for (var i = 0; i < tmpRows.length; i = i + size) {
        int end = i + size <= tmpRows.length ? i + size : tmpRows.length;
        List<PlutoRow> sublist = tmpRows.sublist(i, end);
        keys.shuffle(); // Shuffle for each batch to distribute leftovers fairly
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
