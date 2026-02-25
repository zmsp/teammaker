import 'package:teammaker/model/data_model.dart';
import 'package:pluto_grid/pluto_grid.dart';

class TeamGenerator {
  static Map<String, List<PlutoRow>> generateTeams(
      List<PlutoRow> dat, SettingsData settingsData) {
    List<PlutoRow> tmp_rows = [];
    for (var i = 0; i < dat.length; i++) {
      if (dat[i].checked ?? false) {
        tmp_rows.add(dat[i]);
      } else {
        //TODO unassign team
      }
    }

    Map<String, List<PlutoRow>> teams_list = Map();
    for (var i = 1; i <= settingsData.teamCount; i++) {
      teams_list[i.toString()] = [];
    }

    var keys = teams_list.keys.toList();
    int size = teams_list.length;

    if (settingsData.o == GEN_OPTION.division) {
      // Division algorithm
      int totalTeams = settingsData.teamCount;
      int numDivisions = settingsData.division;
      if (numDivisions <= 0) numDivisions = 1;
      if (numDivisions > totalTeams) numDivisions = totalTeams;

      tmp_rows.sort((a, b) {
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
            ((currentDivTeams.length / totalTeams) * tmp_rows.length).round();

        if (i == divisionTeams.length - 1) {
          numPlayersInThisDiv = tmp_rows.length - playerIndex;
        }

        if (numPlayersInThisDiv <= 0) continue;

        List<PlutoRow> divPlayers =
            tmp_rows.sublist(playerIndex, playerIndex + numPlayersInThisDiv);
        playerIndex += numPlayersInThisDiv;

        int teamsInDiv = currentDivTeams.length;
        for (var j = 0; j < divPlayers.length; j += teamsInDiv) {
          int end = j + teamsInDiv;
          if (end > divPlayers.length) end = divPlayers.length;
          List<PlutoRow> slice = divPlayers.sublist(j, end);
          currentDivTeams.shuffle();
          for (int k = 0; k < slice.length; k++) {
            teams_list[currentDivTeams[k]]?.add(slice[k]);
          }
        }
      }
    } else if (settingsData.o == GEN_OPTION.distribute) {
      // Distribute algorithm
      tmp_rows.sort((a, b) {
        int cmp = (a.cells["skill_level_field"]?.value as num)
            .compareTo(b.cells["skill_level_field"]?.value as num);
        if (cmp != 0) return cmp;
        return (b.cells["gender_field"]?.value.toString() ?? "")
            .compareTo(a.cells["gender_field"]?.value.toString() ?? "");
      });

      var start = 0;
      for (var i = 0; i < tmp_rows.length; i = i + size) {
        int end = i + size <= tmp_rows.length ? i + size : tmp_rows.length;
        List<PlutoRow> sublist = tmp_rows.sublist(start, end);
        keys.shuffle();
        int key_i = 0;

        sublist.forEach((value) {
          teams_list[keys[key_i]]?.add(value);
          key_i++;
        });
        start = i + size;
      }
    } else if (settingsData.o == GEN_OPTION.even_gender) {
      // Improved Even Gender algorithm with Snake Distribution and Population Balancing
      tmp_rows.shuffle(); // Initial randomization for variety

      // Group by gender
      Map<String, List<PlutoRow>> genderGroups = {};
      for (var row in tmp_rows) {
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

      List<String> teamKeys = teams_list.keys.toList();

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
            (a, b) => teams_list[a]!.length.compareTo(teams_list[b]!.length));

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
          teams_list[targetTeam]?.add(players[i]);
        }
      }
    } else if (settingsData.o == GEN_OPTION.random) {
      // Random algorithm
      tmp_rows.shuffle();
      for (var i = 0; i < tmp_rows.length; i = i + size) {
        int end = i + size <= tmp_rows.length ? i + size : tmp_rows.length;
        List<PlutoRow> sublist = tmp_rows.sublist(i, end);
        keys.shuffle(); // Shuffle for each batch to distribute leftovers fairly
        int key_i = 0;

        sublist.forEach((value) {
          if (key_i < keys.length) {
            teams_list[keys[key_i]]?.add(value);
            key_i++;
          }
        });
      }
    }

    return teams_list;
  }
}
