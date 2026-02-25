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
      // Improved Even Gender algorithm with Snake Distribution
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

      genderGroups.forEach((gender, players) {
        teamKeys.shuffle(); // Shuffle teams for each gender group for variety
        int n = teamKeys.length;

        for (int i = 0; i < players.length; i++) {
          // Snake distribution within each gender group
          // Sequence: 0, 1, ..., n-1, n-1, n-2, ..., 0
          int snakeIdx = i % (2 * n);
          int teamIdx;
          if (snakeIdx < n) {
            teamIdx = snakeIdx;
          } else {
            teamIdx = (2 * n - 1) - snakeIdx;
          }

          teams_list[teamKeys[teamIdx]]?.add(players[i]);
        }
      });
    } else if (settingsData.o == GEN_OPTION.proportion) {
      // Proportion algorithm
      tmp_rows.sort((a, b) {
        int cmp = (a.cells["gender_field"]?.value.toString() ?? "")
            .compareTo(b.cells["gender_field"]?.value.toString() ?? "");
        if (cmp != 0) return cmp;
        return (b.cells["skill_level_field"]?.value as num)
            .compareTo(a.cells["skill_level_field"]?.value as num);
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
    } else if (settingsData.o == GEN_OPTION.random) {
      // Random algorithm
      tmp_rows.shuffle();
      var start = 0;
      for (var i = 0; i < tmp_rows.length; i = i + size) {
        int end = i + size <= tmp_rows.length ? i + size : tmp_rows.length;
        List<PlutoRow> sublist = tmp_rows.sublist(start, end);
        int key_i = 0;

        sublist.forEach((value) {
          if (key_i < keys.length) {
            teams_list[keys[key_i]]?.add(value);
            key_i++;
          }
        });
        start = i + size;
      }
    }

    return teams_list;
  }
}
