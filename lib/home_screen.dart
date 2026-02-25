// ignore_for_file: deprecated_member_use, unused_local_variable
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
import 'package:teammaker/widgets/app_components.dart';
import 'package:teammaker/widgets/player_search_bar.dart';
import 'package:teammaker/widgets/strategy_widgets.dart';
import 'package:teammaker/utils/team_utils.dart';
import 'package:teammaker/widgets/team_results_view.dart';
import 'package:teammaker/configs/grid_columns.dart';

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
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            rows = loadedRows;
            if (stateManager != null) {
              stateManager!.removeAllRows();
              stateManager!.appendRows(loadedRows);
            }
          });
        });
      }
    }
  }

  List<PlutoColumn> columns = GridColumns.getColumns();

  List<PlutoRow> rows = [];

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
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        settingsData.teamCount = prefs.getInt('teamCount') ?? 2;
        settingsData.division = prefs.getInt('division') ?? 2;
        settingsData.proportion = prefs.getInt('proportion') ?? 6;
        settingsData.gameVenues = prefs.getInt('gameVenues') ?? 1;
        settingsData.gameRounds = prefs.getInt('gameRounds') ?? 2;

        settingsData.preferExtraTeam =
            prefs.getBool('preferExtraTeam') ?? false;

        String savedOption =
            prefs.getString('genOption') ?? GEN_OPTION.even_gender.toString();
        settingsData.o = GEN_OPTION.values.firstWhere(
            (e) => e.toString() == savedOption,
            orElse: () => GEN_OPTION.even_gender);
      });
    });
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('teamCount', settingsData.teamCount);
    prefs.setInt('division', settingsData.division);
    prefs.setInt('proportion', settingsData.proportion);
    prefs.setInt('gameVenues', settingsData.gameVenues);
    prefs.setInt('gameRounds', settingsData.gameRounds);
    prefs.setBool('preferExtraTeam', settingsData.preferExtraTeam);
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
    setState(() {});
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

    // Clear team for ALL rows first to ensure unchecked or excluded players are unassigned
    for (var row in stateManager!.rows) {
      row.cells['team_field']?.value = 'No team';
    }

    List<PlutoRow> dat = [];
    stateManager?.rows.forEach((element) {
      if (element.checked!) {
        dat.add(element);
      }
    });

    if (settingsData.o == GEN_OPTION.even_gender) {
      int player_num = dat.length;
      if (settingsData.preferExtraTeam) {
        settingsData.teamCount = (player_num / settingsData.proportion).ceil();
      } else {
        settingsData.teamCount = (player_num / settingsData.proportion).floor();
      }
      if (settingsData.teamCount == 0) settingsData.teamCount = 1;
      print("TEAMS CALCULATED: ${settingsData.teamCount}");
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
      appBar: AppBar(
        title: const Text('Team Maker Buddy',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.primaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            tooltip: 'Export to CSV',
            icon: const FaIcon(FontAwesomeIcons.fileExport, size: 20),
            onPressed: () {
              exportToCsv();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Data Copied to Clipboard!"),
                behavior: SnackBarBehavior.floating,
              ));
            },
          ),
          IconButton(
            tooltip: 'Get help',
            icon: const FaIcon(FontAwesomeIcons.circleQuestion, size: 20),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HelpExample()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        children: [
          SectionHeader(
              title: '1. PLAYER ROSTER',
              icon: FontAwesomeIcons.users,
              color: colorScheme.primary),
          Card(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            margin: const EdgeInsets.only(bottom: 24.0),
            child: ExpansionTile(
              initiallyExpanded: true,
              backgroundColor: colorScheme.surface,
              collapsedBackgroundColor: colorScheme.surface,
              leading: CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child:
                      Icon(Icons.people_outline, color: colorScheme.primary)),
              title: const Text('Manage Players',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle:
                  Text('${stateManager?.rows.length ?? 0} Players listed'),
              children: [
                SizedBox(
                  height: 450,
                  child: PlutoGrid(
                    columns: columns,
                    rows: rows,
                    rowColorCallback: (rowContext) {
                      if (rowContext.row.cells['name_field']?.value ==
                          'player level gender and team') {
                        return colorScheme.errorContainer.withOpacity(0.1);
                      }
                      return Colors.transparent;
                    },
                    configuration: PlutoGridConfiguration(
                      style: PlutoGridStyleConfig(
                        gridBackgroundColor: colorScheme.surface,
                        columnTextStyle: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold),
                        cellTextStyle: TextStyle(color: colorScheme.onSurface),
                        enableColumnBorderVertical: false,
                        enableColumnBorderHorizontal: false,
                        gridBorderColor: Colors.transparent,
                        activatedColor: colorScheme.primaryContainer,
                        borderColor: colorScheme.outlineVariant,
                      ),
                    ),
                    createHeader: (stateManager) {
                      return Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.3),
                          border: Border(
                              bottom: BorderSide(
                                  color: colorScheme.outlineVariant)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PlayerSearchBar(stateManager: stateManager),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  GridHeaderButton(
                                    onPressed: () async {
                                      final List<PlayerModel>? players =
                                          await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddPlayersScreen()));
                                      if (players != null) {
                                        addPlayers(players);
                                      }
                                    },
                                    icon: Icons.group_add,
                                    label: 'Quick Add',
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  GridHeaderButton(
                                    onPressed: () {
                                      stateManager.insertRows(
                                          0, [stateManager.getNewRow()]);
                                      _triggerSavePlayers();
                                    },
                                    icon: Icons.person_add,
                                    label: 'Add Row',
                                    color: colorScheme.secondary,
                                  ),
                                  const SizedBox(width: 12),
                                  GridHeaderButton(
                                    onPressed: () {
                                      setState(() {
                                        _isEditable = !_isEditable;
                                        for (var col in stateManager.columns) {
                                          col.enableEditingMode = _isEditable;
                                        }
                                        stateManager.notifyListeners();
                                      });
                                    },
                                    icon: _isEditable
                                        ? Icons.edit_off
                                        : Icons.edit,
                                    label: _isEditable ? 'Lock' : 'Edit',
                                    color: _isEditable
                                        ? colorScheme.tertiary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 12),
                                  GridHeaderButton(
                                    onPressed: () {
                                      stateManager
                                          .removeRows(stateManager.checkedRows);
                                      _triggerSavePlayers();
                                    },
                                    icon: Icons.delete_sweep,
                                    label: 'Clear Selected',
                                    color: colorScheme.error,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    onLoaded: (PlutoGridOnLoadedEvent event) {
                      stateManager = event.stateManager;
                      stateManager!.addListener(_triggerSavePlayers);
                      _loadPlayers();
                    },
                    onRowChecked: (PlutoGridOnRowCheckedEvent event) {
                      if (event.row != null && !event.row!.checked!) {
                        setState(() {
                          event.row!.cells['team_field']?.value = 'No team';
                        });
                        _triggerSavePlayers();
                      } else if (event.row == null) {
                        // Handle 'check all' toggles
                        bool anyUnchecked =
                            stateManager!.rows.any((r) => r.checked == false);
                        if (anyUnchecked) {
                          setState(() {
                            for (var r in stateManager!.rows) {
                              if (!r.checked!) {
                                r.cells['team_field']?.value = 'No team';
                              }
                            }
                          });
                          _triggerSavePlayers();
                        }
                      }
                    },
                    onChanged: (PlutoGridOnChangedEvent event) {
                      _triggerSavePlayers();
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
          SectionHeader(
              title: '2. BALANCE STRATEGY',
              icon: FontAwesomeIcons.gears,
              color: colorScheme.secondary),
          Card(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            margin: const EdgeInsets.only(bottom: 24.0),
            child: ExpansionTile(
              initiallyExpanded: true,
              backgroundColor: colorScheme.surface,
              collapsedBackgroundColor: colorScheme.surface,
              leading: CircleAvatar(
                  backgroundColor: colorScheme.secondaryContainer,
                  child:
                      Icon(Icons.auto_awesome, color: colorScheme.secondary)),
              title: const Text('Team Splitting Rules',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  'Mode: ${settingsData.o.toString().split('.').last.replaceAll('_', ' ').toUpperCase()}'),
              children: [
                StrategyOption(
                  option: GEN_OPTION.even_gender,
                  groupValue: settingsData.o,
                  title: 'Fair Mix (Best)',
                  subtitle:
                      'Mix players by gender and skill correctly. Grows teams naturally (${settingsData.proportion}/team).',
                  icon: Icons.wc,
                  isSelected: settingsData.o == GEN_OPTION.even_gender,
                  onChanged: (GEN_OPTION? value) {
                    setState(() {
                      settingsData.o = value ?? settingsData.o;
                      _saveSettings();
                    });
                  },
                  configWidget: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Players per team',
                          prefixIcon: Icon(Icons.numbers),
                          border: OutlineInputBorder(),
                        ),
                        initialValue: settingsData.proportion.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => setState(() {
                          settingsData.proportion = int.tryParse(v) ?? 6;
                          _saveSettings();
                        }),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Add extra team for leftovers',
                            style: TextStyle(fontSize: 13)),
                        subtitle: Text(
                            settingsData.preferExtraTeam
                                ? 'Ex: 13 players -> 3 smaller teams'
                                : 'Ex: 13 players -> 2 larger teams',
                            style: const TextStyle(fontSize: 11)),
                        value: settingsData.preferExtraTeam,
                        onChanged: (bool value) {
                          setState(() {
                            settingsData.preferExtraTeam = value;
                            _saveSettings();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                StrategyOption(
                  option: GEN_OPTION.distribute,
                  groupValue: settingsData.o,
                  title: 'Skill Balance',
                  subtitle: 'Spread top players across teams fairly.',
                  icon: Icons.balance,
                  isSelected: settingsData.o == GEN_OPTION.distribute,
                  onChanged: (GEN_OPTION? value) {
                    setState(() {
                      settingsData.o = value ?? settingsData.o;
                      _saveSettings();
                    });
                  },
                  configWidget: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Total Teams',
                      prefixIcon: Icon(Icons.grid_view),
                      border: OutlineInputBorder(),
                    ),
                    initialValue: settingsData.teamCount.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() {
                      settingsData.teamCount = int.tryParse(v) ?? 2;
                      _saveSettings();
                    }),
                  ),
                ),
                StrategyOption(
                  option: GEN_OPTION.division,
                  groupValue: settingsData.o,
                  title: 'Ranked Groups',
                  subtitle:
                      'Put strong players together and new players together.',
                  icon: Icons.military_tech,
                  isSelected: settingsData.o == GEN_OPTION.division,
                  onChanged: (GEN_OPTION? value) {
                    setState(() {
                      settingsData.o = value ?? settingsData.o;
                      _saveSettings();
                    });
                  },
                  configWidget: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Number of Groups',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: settingsData.division.toString(),
                        onChanged: (v) => setState(() {
                          settingsData.division = int.tryParse(v) ?? 2;
                          _saveSettings();
                        }),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Total Teams',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: settingsData.teamCount.toString(),
                        onChanged: (v) => setState(() {
                          settingsData.teamCount = int.tryParse(v) ?? 2;
                          _saveSettings();
                        }),
                      ),
                    ],
                  ),
                ),
                StrategyOption(
                  option: GEN_OPTION.random,
                  groupValue: settingsData.o,
                  title: 'Random',
                  subtitle: 'Mix players with no rules.',
                  icon: Icons.shuffle,
                  isSelected: settingsData.o == GEN_OPTION.random,
                  onChanged: (GEN_OPTION? value) {
                    setState(() {
                      settingsData.o = value ?? settingsData.o;
                      _saveSettings();
                    });
                  },
                  configWidget: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Total Teams',
                      prefixIcon: Icon(Icons.grid_view),
                      border: OutlineInputBorder(),
                    ),
                    initialValue: settingsData.teamCount.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() {
                      settingsData.teamCount = int.tryParse(v) ?? 2;
                      _saveSettings();
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: generateTeams,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.flash_on, size: 28),
                      label: const Text('GENERATE TEAMS',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (stateManager != null &&
              stateManager!.rows.any((element) =>
                  TeamUtils.normalizeTeamName(
                      element.cells['team_field']?.value.toString()) !=
                  "No team")) ...[
            SectionHeader(
                title: '3. RESULTS',
                icon: FontAwesomeIcons.trophy,
                color: colorScheme.tertiary),
            Card(
              elevation: 4,
              shadowColor: colorScheme.tertiary.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: colorScheme.tertiary.withOpacity(0.3)),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                initiallyExpanded: true,
                leading: CircleAvatar(
                    backgroundColor: colorScheme.tertiaryContainer,
                    child: Icon(Icons.groups, color: colorScheme.tertiary)),
                title: const Text('Active Teams',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                children: [TeamResultsView(stateManager: stateManager)],
              ),
            ),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                initiallyExpanded: true,
                leading: CircleAvatar(
                    backgroundColor: colorScheme.surfaceVariant,
                    child:
                        Icon(Icons.map, color: colorScheme.onSurfaceVariant)),
                title: const Text('Player/Team Directory',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                children: [PlayerTeamDirectoryView(stateManager: stateManager)],
              ),
            ),
          ],
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            margin: const EdgeInsets.only(bottom: 80.0),
            child: ExpansionTile(
              initiallyExpanded: true,
              leading: CircleAvatar(
                  backgroundColor:
                      colorScheme.secondaryContainer.withOpacity(0.5),
                  child: Icon(Icons.person_off, color: colorScheme.secondary)),
              title: const Text('Unassigned List',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              children: [UnassignedPlayersView(stateManager: stateManager)],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                BottomNavButton(
                  onPressed: () async {
                    final List<PlayerModel>? players = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddPlayersScreen()));
                    if (players != null) addPlayers(players);
                  },
                  icon: FontAwesomeIcons.userPlus,
                  label: 'Add',
                  color: colorScheme.primary,
                ),
                BottomNavButton(
                  onPressed: _navigateToTeam,
                  icon: FontAwesomeIcons.usersViewfinder,
                  label: 'Teams',
                  color: colorScheme.secondary,
                ),
                BottomNavButton(
                  onPressed: () {
                    // Default to 1 venue and calculate rounds so each team plays at least once
                    settingsData.gameVenues = 1;
                    settingsData.gameRounds =
                        (settingsData.teamCount / 2).ceil();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MatchScreen(settingsData)));
                  },
                  icon: FontAwesomeIcons.trophy,
                  label: 'Match',
                  color: colorScheme.tertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
