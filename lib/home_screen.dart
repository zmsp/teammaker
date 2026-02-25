import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid_export/pluto_grid_export.dart' as pluto_grid_export;
import 'package:teammaker/HelpScreen.dart';
import 'package:teammaker/MatchScreen.dart';
import 'package:teammaker/add_players.dart';
import 'package:teammaker/model/data_model.dart';
import 'package:teammaker/model/player_model.dart';
import 'package:teammaker/team_screen.dart';
import 'package:teammaker/algorithm/team_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlutoExampleScreen extends StatefulWidget {
  final String? title;
  final String? topTitle;
  final List<Widget>? topContents;
  final List<Widget>? topButtons;
  final Widget? body;

  PlutoExampleScreen({
    this.title,
    this.topTitle,
    this.topContents,
    this.topButtons,
    this.body,
  });

  @override
  _PlutoExampleScreenState createState() => _PlutoExampleScreenState();
}

enum Status { none, running, stopped, paused }

class _PlutoExampleScreenState extends State<PlutoExampleScreen> {
  PlutoGridStateManager? stateManager;
  SettingsData settingsData = new SettingsData();
  bool _isEditable = false;
  Timer? _saveTimer;

  void exportToCsv() async {
    String title = "pluto_grid_export";
    if (stateManager != null) {
      var exported = const Utf8Encoder()
          .convert(pluto_grid_export.PlutoGridExport.exportCSV(stateManager!));

      var test = pluto_grid_export.PlutoGridExport.exportCSV(stateManager!,
          fieldDelimiter: ",", textDelimiter: "", textEndDelimiter: "");
      Clipboard.setData(new ClipboardData(text: test));
      print(test);
    }

    // use file_saver from pub.dev
  }

  void _triggerSavePlayers() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), _savePlayers);
  }

  void _savePlayers() async {
    if (stateManager == null) return;
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> rowsToUpdate = stateManager!.rows.map((e) {
      return {
        'name_field': e.cells['name_field']?.value,
        'skill_level_field': e.cells['skill_level_field']?.value,
        'gender_field': e.cells['gender_field']?.value,
        'team_field': e.cells['team_field']?.value,
        'checked': e.checked,
      };
    }).toList();
    prefs.setString('saved_players', jsonEncode(rowsToUpdate));
  }

  Future<void> _loadPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    String? saved = prefs.getString('saved_players');
    if (saved != null) {
      List<dynamic> jsonMap = jsonDecode(saved);
      List<PlutoRow> loadedRows = jsonMap.map<PlutoRow>((e) {
        var row = PlutoRow(
          cells: {
            'name_field': PlutoCell(value: e['name_field'] ?? 'Unknown'),
            'skill_level_field': PlutoCell(value: e['skill_level_field'] ?? 3),
            'team_field': PlutoCell(value: e['team_field'] ?? "None"),
            'gender_field': PlutoCell(value: e['gender_field'] ?? "MALE"),
          },
        );
        if (e['checked'] != null) {
          row.setChecked(e['checked']);
        }
        return row;
      }).toList();

      if (loadedRows.isNotEmpty) {
        setState(() {
          rows = loadedRows;
          if (stateManager != null) {
            stateManager!.removeAllRows();
            stateManager!.appendRows(loadedRows);
          }
        });
      }
    }
  }

  List<PlutoColumn> columns = [
    /// Text Column definition

    PlutoColumn(
      enableRowDrag: true,
      enableHideColumnMenuItem: false,
      enableRowChecked: true,
      title: "name",
      field: "name_field",
      frozen: PlutoColumnFrozen.start,
      width: 250,
      type: PlutoColumnType.text(),
      renderer: (rendererContext) {
        return Row(
          children: [
            Expanded(
              child: Text(
                rendererContext.row.cells[rendererContext.column.field]!.value
                    .toString(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white70),
              ),
            ),
            Wrap(
              children: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.add_circle,
                  ),
                  onPressed: () {
                    rendererContext.stateManager.insertRows(
                      rendererContext.rowIdx,
                      [rendererContext.stateManager.getNewRow()],
                    );
                  },
                  iconSize: 25,
                  color: Colors.green,
                  padding: const EdgeInsets.all(0),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outlined,
                  ),
                  onPressed: () {
                    rendererContext.stateManager
                        .removeRows([rendererContext.row]);
                  },
                  iconSize: 25,
                  color: Colors.red,
                  padding: const EdgeInsets.all(0),
                ),
              ],
            ),
          ],
        );
      },
    ),
    PlutoColumn(
      title: 'Level',
      field: 'skill_level_field',
      type: PlutoColumnType.select([1, 2, 3, 4, 5]),
      width: 80,
      textAlign: PlutoColumnTextAlign.right,
    ),

    PlutoColumn(
        title: 'gender',
        field: 'gender_field',
        width: 80,
        type: PlutoColumnType.select(["MALE", "FEMALE", "X"])),

    /// Number Column definition

    PlutoColumn(
      title: 'team',
      field: 'team_field',
      textAlign: PlutoColumnTextAlign.right,
      width: 80,
      type: PlutoColumnType.text(),
    ),
  ];

  List<PlutoRow> rows = [
    PlutoRow(
      cells: {
        'name_field': PlutoCell(value: 'Sample Player'),
        'skill_level_field': PlutoCell(value: 3),
        'team_field': PlutoCell(value: "0"),
        'gender_field': PlutoCell(value: "X"),
      },
    ),
  ];

  void rebuild_options() {
    // var team_list = new List<int>.generate(level, (i) => i + 1);
    // var level_list = new List<int>.generate(teams, (i) => i + 1);
    // columns[1] = PlutoColumn(
    //   title: 'level',
    //   field: 'skill_level_field',
    //   type: PlutoColumnType.number(),
    // );

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    rebuild_options();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      settingsData.teamCount = prefs.getInt('teamCount') ?? 1;
      settingsData.division = prefs.getInt('division') ?? 2;
      settingsData.proportion = prefs.getInt('proportion') ?? 6;
      settingsData.gameVenues = prefs.getInt('gameVenues') ?? 2;
      settingsData.gameRounds = prefs.getInt('gameRounds') ?? 2;

      String savedOption =
          prefs.getString('genOption') ?? GEN_OPTION.proportion.toString();
      settingsData.o = GEN_OPTION.values.firstWhere(
          (e) => e.toString() == savedOption,
          orElse: () => GEN_OPTION.proportion);
    });
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('teamCount', settingsData.teamCount);
    prefs.setInt('division', settingsData.division);
    prefs.setInt('proportion', settingsData.proportion);
    prefs.setInt('gameVenues', settingsData.gameVenues);
    prefs.setInt('gameRounds', settingsData.gameRounds);
    prefs.setString('genOption', settingsData.o.toString());
  }

  showTextDialog(BuildContext context, String title, String message) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("$title"),
      content: SingleChildScrollView(
        child: Text("$message"),
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  String data = """
John,3,M
Jane,4,F""";

  AlertDialog reportingDialog(BuildContext context) {
    TextEditingController player_text = new TextEditingController(text: data);

    return AlertDialog(
      title: const Text('Add Players'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const Text('Add  player name and info'),
            const Text(
                'One line per player. Format should be <NAME>,<LeveL>,<GENDER>'),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'zobair,4\nmike,1,MALE\njohn,1,MALE,TEAM#1',
              ),
              controller: player_text,
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
            const Text(
                'if you are pasting the information from meetup, press format text from meetup'),
            ElevatedButton.icon(
              icon: Icon(
                FontAwesomeIcons.meetup,
                size: 25.0,
              ),
              style: ButtonStyle(
                padding: WidgetStateProperty.all<EdgeInsetsGeometry?>(
                    EdgeInsets.fromLTRB(20, 15, 10, 20)),
                backgroundColor:
                    WidgetStateProperty.all<Color>(Colors.redAccent),
              ),
              label: const Text('Format Text from meetup'),
              onPressed: () {
                String text = player_text.text;
                var lines = text.split("\n");
                var player_line = [];
                var date_field_regex =
                    RegExp(r'^(J|F|M|A|M|J|A|S|O|N|D).*(AM|PM)$');
                var record_flag = true;
                for (var i = 0; i <= lines.length - 1; i++) {
                  if ((record_flag == true) && (lines[i].trim() != "")) {
                    print(lines[i]);
                    player_line.add(lines[i] + ",3" + ",M");
                    record_flag = false;
                    continue;
                  }
                  // Here if we find a pattern for date field, we record the next line.
                  print(lines[i]);
                  print(date_field_regex.hasMatch(lines[i]));
                  if (date_field_regex.hasMatch(lines[i]) == true) {
                    // print()
                    record_flag = true;
                  }
                }
                player_text.text = player_line.join("\n");
              },
            ),
            const Text(
                'if you want to add default level(3) and gender info(male), press the next button'),
            ElevatedButton.icon(
              icon: Icon(
                FontAwesomeIcons.addressCard,
                size: 25.0,
              ),
              style: ButtonStyle(
                padding: WidgetStateProperty.all<EdgeInsetsGeometry?>(
                    EdgeInsets.fromLTRB(20, 15, 10, 20)),
                backgroundColor:
                    WidgetStateProperty.all<Color>(Colors.redAccent),
              ),
              label: const Text('Add default level and gender'),
              onPressed: () {
                String text = player_text.text;
                var lines = text.split("\n");
                var data = [];
                for (var i = 0; i <= lines.length - 1; i++) {
                  data.add(lines[i] + ",3" + ",M");
                }
                player_text.text = data.join("\n");
              },
            ),
            const Text('Press check button to see what will be added'),
            ElevatedButton.icon(
              icon: Icon(
                FontAwesomeIcons.search,
                size: 25.0,
              ),
              style: ButtonStyle(
                padding: WidgetStateProperty.all<EdgeInsetsGeometry?>(
                    EdgeInsets.fromLTRB(20, 15, 10, 20)),
                backgroundColor:
                    WidgetStateProperty.all<Color>(Colors.redAccent),
              ),
              label: const Text("Check/Validate"),
              onPressed: () {
                var lines = player_text.text.split("\n");
                var string_data = [];

                for (var i = 0; i <= lines.length - 1; i++) {
                  var map_data = {
                    "name": "x",
                    "level": 3,
                    "gender": "MALE",
                    "team": "None"
                  };

                  var data = lines[i].split(",");
                  for (var j = 0; j < data.length; j++) {
                    switch (j) {
                      case 0:
                        {
                          map_data["name"] = data[0];
                        }
                        break;
                      case 1:
                        {
                          map_data["level"] = double.tryParse(data[1]) ?? 3;
                        }
                        break;
                      case 2:
                        {
                          if (data[2].trim().toUpperCase().startsWith("M")) {
                            map_data["gender"] = "MALE";
                          } else if (data[2]
                              .trim()
                              .toUpperCase()
                              .startsWith("F")) {
                            map_data["gender"] = "FEMALE";
                          } else {
                            map_data["gender"] = "X";
                          }
                        }
                        break;
                      case 3:
                        {
                          map_data["team"] = data[3];
                        }
                        break;
                      default:
                        {
                          break;
                        }
                    }
                  }
                  string_data.add(map_data.toString() + "\n");
                }
                showTextDialog(context, "Following players will be added",
                    string_data.join("\n"));
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text(
            'No',
            style: TextStyle(
              color: Colors.deepOrange,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Add'),
          onPressed: () {
            var lines = player_text.text.split("\n");

            for (var i = 0; i <= lines.length - 1; i++) {
              var map_data = {
                "name": "x",
                "level": 3,
                "gender": "MALE",
                "team": "None"
              };

              var data = lines[i].split(",");
              for (var j = 0; j < data.length; j++) {
                switch (j) {
                  case 0:
                    {
                      map_data["name"] = data[0];
                    }
                    break;
                  case 1:
                    {
                      map_data["level"] = int.tryParse(data[1]) ?? 3;
                    }
                    break;
                  case 2:
                    {
                      if (data[2].trim().toUpperCase().startsWith("M")) {
                        map_data["gender"] = "MALE";
                      } else if (data[2].trim().toUpperCase().startsWith("F")) {
                        map_data["gender"] = "FEMALE";
                      } else {
                        map_data["gender"] = "X";
                      }
                    }
                    break;
                  case 3:
                    {
                      map_data["team"] = data[3];
                    }
                    break;
                  default:
                    {
                      break;
                    }
                }
              }

              stateManager!.appendRows([
                PlutoRow(
                  checked: true,
                  cells: {
                    'name_field': PlutoCell(value: map_data["name"]),
                    'skill_level_field': PlutoCell(value: map_data["level"]),
                    'team_field': PlutoCell(value: map_data["team"]),
                    'gender_field': PlutoCell(value: map_data["gender"]),
                  },
                )
              ]);
            }
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void addPlayers(List<PlayerModel> players) {
    for (var player in players) {
      stateManager!.appendRows([
        PlutoRow(
          checked: true,
          cells: {
            'name_field': PlutoCell(value: player.name),
            'skill_level_field': PlutoCell(value: player.level),
            'team_field': PlutoCell(value: player.team),
            'gender_field': PlutoCell(value: player.gender),
          },
        )
      ]);
    }
  }

  void _navigateToTeam() {
    //sort by team name

    stateManager!.sortAscending(columns[3]);
    List<PlutoRow?> dat = stateManager?.rows ?? [];

    Map<String, List<String>> teams_name_list = Map();
    Map<String, double> teams_total_score = Map();

    //find checked items

    List<PlutoRow?> tmp_rows = [];
    for (var i = 0; i < dat.length; i++) {
      if (dat[i]?.checked ?? false) {
        // teams_name_list.update(dat[i]?.cells?["team_field"]?.value?? "None", (value) => null)
        var t = dat[i]?.cells["skill_level_field"]?.value;
        print(t.runtimeType);
        teams_total_score.update(
          dat[i]?.cells["team_field"]?.value ?? "None",
          // You can ignore the incoming parameter if you want to always update the value even if it is already in the map
          (existingValue) =>
              existingValue +
              (dat[i]?.cells["skill_level_field"]?.value ?? 0).toDouble(),
          ifAbsent: () =>
              (dat[i]?.cells["skill_level_field"]?.value ?? 0).toDouble(),
        );

        teams_name_list.update(
          dat[i]?.cells["team_field"]?.value ?? "None",
          // You can ignore the incoming parameter if you want to always update the value even if it is already in the map
          (existingValue) {
            existingValue.add(dat[i]?.cells["name_field"]?.value +
                "\n     ${dat[i]?.cells["gender_field"]?.value} with level ${dat[i]?.cells["skill_level_field"]?.value.toString()}"
                    .toLowerCase());
            return existingValue;
          },
          ifAbsent: () => [
            (dat[i]?.cells["name_field"]?.value +
                "\n     ${dat[i]?.cells["gender_field"]?.value} with level  ${dat[i]?.cells["skill_level_field"]?.value.toString()}"
                    .toLowerCase())
          ],
        );
      } else {
        //TODO unassign team
      }
    }
    Map<String, double> teams_avg_score = Map();
    Map<String, List<String>> teams_list = Map();
    // for (var i = 1; i <= teams; i++) {
    //   teams_list[i.toString()] = [];
    // }
    List<ListItem> teams_list_data = [];
    // print(teams_list.toString());
    teams_name_list.keys.toList().forEach((value) {
      if (value == "None") return;
      var players = teams_name_list[value]!.length;
      var total_score = teams_total_score[value];
      var avg_score =
          (teams_total_score[value]! / teams_name_list[value]!.length)
              .toStringAsFixed(2);
      print(avg_score);
      teams_list_data.add(HeadingItem('TEAM#: $value',
          '$players players with average level  $avg_score and combine level  $total_score'));
      teams_name_list[value]?.toList().forEach((name) {
        teams_list_data.add(MessageItem(name.toString(), name.toString()));
      });
    });
    // print(teams_list_data);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                TeamList(items: teams_list_data, settingsData: settingsData)));
  }

  void generateTeams() {
    stateManager!.sortAscending(columns[1]);
    List<PlutoRow> dat = [];
    stateManager?.rows.forEach((element) {
      if (element.checked!) {
        dat.add(element);
      }
    });

    if (settingsData.o == GEN_OPTION.proportion) {
      int player_num = dat.length;
      settingsData.teamCount = (player_num / settingsData.proportion).round();
      if (settingsData.teamCount == 0) settingsData.teamCount = 1;
      print("TEASM ${settingsData.teamCount}");
    }

    Map<String, List<PlutoRow>> teams_list =
        TeamGenerator.generateTeams(dat, settingsData);

    teams_list.forEach((key, value) {
      value.forEach((element) {
        setState(() {
          element.cells["team_field"]?.value = key;
        });
      });
    });

    _navigateToTeam();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Shaker'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Export to CSV',
            icon: const FaIcon(FontAwesomeIcons.clipboard),
            onPressed: () {
              exportToCsv();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Text Copied. Paste text somewhere to save!"),
              ));
            },
          ),
          IconButton(
            tooltip: 'Get help',
            icon: const FaIcon(FontAwesomeIcons.circleQuestion),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HelpExample()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ExpansionTile(
            leading: const Icon(Icons.psychology),
            title: const Text('Generation Strategy',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('How do you want your teams to be balanced?'),
            children: <Widget>[
              ListTile(
                title: const Text('Fair Teams (Prioritize Skill)'),
                leading: Radio<GEN_OPTION>(
                  value: GEN_OPTION.distribute,
                  groupValue: settingsData.o,
                  onChanged: (GEN_OPTION? value) {
                    setState(() {
                      settingsData.o = value ?? settingsData.o;
                    });
                  },
                ),
                subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                          'Aggressively balances teams by distributing the best and worst players evenly, ensuring all teams have roughly the same average skill rating. Best for competitive play.'),
                      if (settingsData.o == GEN_OPTION.distribute)
                        TextFormField(
                          decoration: const InputDecoration(
                            label: Text("Number of teams"),
                            hintText:
                                'How many teams do you want to split the players to?',
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          initialValue: settingsData.teamCount.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            settingsData.teamCount =
                                int.tryParse(value) ?? settingsData.teamCount;
                          },
                        ),
                    ]),
              ),
              ListTile(
                title: const Text('Ranked Divisions'),
                leading: Radio<GEN_OPTION>(
                  value: GEN_OPTION.division,
                  groupValue: settingsData.o,
                  onChanged: (GEN_OPTION? value) {
                    setState(() {
                      settingsData.o = value ?? settingsData.o;
                    });
                  },
                ),
                subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                          'Separates players into tiered divisions so highly skilled players only play against each other, and beginners play against beginners.'),
                      if (settingsData.o == GEN_OPTION.division)
                        Column(
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                label: Text('Number of divisions'),
                                hintText:
                                    'Division number means top teams will have better players',
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              initialValue: settingsData.division.toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                settingsData.division = int.tryParse(value) ??
                                    settingsData.division;
                                _saveSettings();
                              },
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                label: Text("Number of teams"),
                                hintText:
                                    'How many teams do you want to split the players to?',
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              initialValue: settingsData.teamCount.toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                settingsData.teamCount = int.tryParse(value) ??
                                    settingsData.teamCount;
                                _saveSettings();
                              },
                            ),
                          ],
                        )
                    ]),
              ),
              ListTile(
                title: const Text('Fixed Roster Size (Pickup Mode)'),
                leading: Radio<GEN_OPTION>(
                  value: GEN_OPTION.proportion,
                  groupValue: settingsData.o,
                  onChanged: (GEN_OPTION? value) {
                    setState(() {
                      settingsData.o = value ?? settingsData.o;
                    });
                  },
                ),
                subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                          'Creates teams with a specific number of players on each roster, balanced by skill and gender. Perfect for setting up 5v5s or 6v6s pickup games.'),
                      if (settingsData.o == GEN_OPTION.proportion)
                        TextFormField(
                          decoration: const InputDecoration(
                            label: Text('Number of players per team'),
                            hintText: 'How many players per team',
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          initialValue: settingsData.proportion.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            settingsData.proportion =
                                int.tryParse(value) ?? settingsData.proportion;
                            _saveSettings();
                          },
                        )
                    ]),
              ),
              ListTile(
                title: const Text('Pure Randomizer'),
                leading: Radio<GEN_OPTION>(
                  value: GEN_OPTION.random,
                  groupValue: settingsData.o,
                  onChanged: (GEN_OPTION? value) {
                    setState(() {
                      settingsData.o = value ?? settingsData.o;
                    });
                  },
                ),
                subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                          'Randomly assigns players to teams with zero sorting. Complete luck of the draw.'),
                      if (settingsData.o == GEN_OPTION.random)
                        TextFormField(
                          decoration: const InputDecoration(
                            label: Text("Number of teams"),
                            hintText:
                                'How many teams do you want to split the players to?',
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          initialValue: settingsData.teamCount.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            settingsData.teamCount =
                                int.tryParse(value) ?? settingsData.teamCount;
                          },
                        )
                    ]),
              ),
              ListTile(
                title: const Text('Fair Teams (Prioritize Gender)'),
                leading: Radio<GEN_OPTION>(
                  value: GEN_OPTION.even_gender,
                  groupValue: settingsData.o,
                  onChanged: (GEN_OPTION? value) {
                    setState(() {
                      settingsData.o = value ?? settingsData.o;
                    });
                  },
                ),
                subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                          'Prioritizes creating an equal mix of men and women evenly across all teams, followed by balancing overall skill level. Best for mixed casual games.'),
                      if (settingsData.o == GEN_OPTION.even_gender)
                        TextFormField(
                          decoration: const InputDecoration(
                            label: Text("Number of teams"),
                            hintText:
                                'How many teams do you want to split the players to?',
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          initialValue: settingsData.teamCount.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            settingsData.teamCount =
                                int.tryParse(value) ?? settingsData.teamCount;
                          },
                        )
                    ]),
              ),
            ],
          ),
          Expanded(
            child: Container(
                child: PlutoGrid(
              columns: columns,
              rows: rows,
              configuration: const PlutoGridConfiguration(
                style: PlutoGridStyleConfig.dark(
                  enableColumnBorderHorizontal: false,
                  enableColumnBorderVertical: false,
                ),
              ),
              createHeader: (stateManager) {
                var style = stateManager.configuration.style;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    height: style.rowHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                stateManager.insertRows(
                                  stateManager.rows.length,
                                  [stateManager.getNewRow()],
                                );
                                _triggerSavePlayers();
                              },
                              icon: Icon(Icons.person_add,
                                  color: style.iconColor),
                              label: Text('Add Row',
                                  style: TextStyle(
                                      color: style.cellTextStyle.color)),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isEditable = !_isEditable;
                                  for (var col in stateManager.columns) {
                                    col.enableEditingMode = _isEditable;
                                  }
                                  stateManager.notifyListeners();
                                });
                              },
                              icon: Icon(
                                  _isEditable ? Icons.edit_off : Icons.edit,
                                  color: style.iconColor),
                              label: Text(
                                  _isEditable ? 'Disable Edit' : 'Edit Mode',
                                  style: TextStyle(
                                      color: style.cellTextStyle.color)),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        TextButton.icon(
                          onPressed: () {
                            stateManager.removeRows(stateManager.checkedRows);
                            _triggerSavePlayers();
                          },
                          icon: Icon(Icons.delete_outline,
                              color: Colors.red.shade300),
                          label: Text('Remove Checked',
                              style: TextStyle(color: Colors.red.shade300)),
                        ),
                      ],
                    ),
                  ),
                );
              },
              onLoaded: (PlutoGridOnLoadedEvent event) {
                stateManager = event.stateManager;
                stateManager!.addListener(_triggerSavePlayers);
                _loadPlayers();
              },
              onChanged: (PlutoGridOnChangedEvent event) {
                _triggerSavePlayers();
              },
            )),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: generateTeams,
        icon: const FaIcon(FontAwesomeIcons.dice),
        label: const Text('Generate',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Tooltip(
                    message: 'Add Players',
                    child: IconButton(
                      iconSize: 28,
                      onPressed: () async {
                        final List<PlayerModel> players = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddPlayersScreen()));
                        addPlayers(players);
                      },
                      icon: const FaIcon(FontAwesomeIcons.userPlus),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Tooltip(
                    message: 'View Teams',
                    child: IconButton(
                      iconSize: 28,
                      onPressed: _navigateToTeam,
                      icon: const FaIcon(FontAwesomeIcons.usersViewfinder),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Create Match',
                    child: IconButton(
                      iconSize: 28,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    MatchScreen(settingsData)));
                      },
                      icon: const FaIcon(FontAwesomeIcons.trophy),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
