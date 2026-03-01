import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:teammaker/theme/app_theme.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'package:teammaker/HelpScreen.dart';
import 'package:teammaker/MatchScreen.dart';
import 'package:teammaker/SettingsScreen.dart';
import 'package:teammaker/add_players.dart';
import 'package:teammaker/model/data_model.dart';
import 'package:teammaker/model/player_model.dart';
import 'package:teammaker/team_screen.dart';
import 'package:teammaker/algorithm/team_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teammaker/widgets/app_components.dart';
import 'package:teammaker/widgets/strategy_widgets.dart';
import 'package:teammaker/utils/team_utils.dart';
import 'package:teammaker/widgets/team_results_view.dart';
import 'package:teammaker/configs/grid_columns.dart';
import 'package:teammaker/widgets/tapscore_widget.dart';
import 'package:teammaker/widgets/random_team_widget.dart';

class PlutoExampleScreen extends StatefulWidget {
  final String? title;
  final String? topTitle;
  final List<Widget>? topContents;
  final List<Widget>? topButtons;
  final Widget? body;
  final ThemeController? themeController;

  const PlutoExampleScreen({
    super.key,
    this.title,
    this.topTitle,
    this.topContents,
    this.topButtons,
    this.body,
    this.themeController,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PlutoExampleScreenState createState() => _PlutoExampleScreenState();
}

enum Status { none, running, stopped, paused }

// ignore: library_private_types_in_public_api
class _PlutoExampleScreenState extends State<PlutoExampleScreen> {
  PlutoGridStateManager? stateManager;
  SettingsData settingsData = SettingsData();
  bool _isEditable = false;
  Timer? _saveTimer;

  /// Cached SharedPreferences — obtained once, reused in every save call.
  SharedPreferences? _prefs;

  void exportToCsv() async {
    if (stateManager == null) return;

    StringBuffer csvBuffer = StringBuffer();
    // Headers
    csvBuffer.writeln("Name,Level,Gender,Team,Position");

    for (var row in stateManager!.rows) {
      String name = row.cells['name_field']?.value?.toString() ?? "";
      String level = row.cells['skill_level_field']?.value?.toString() ?? "";
      String gender = row.cells['gender_field']?.value?.toString() ?? "";
      String team = row.cells['team_field']?.value?.toString() ?? "";
      String role = row.cells['role_field']?.value?.toString() ?? "Any";

      csvBuffer.writeln("$name,$level,$gender,$team,$role");
    }

    await Clipboard.setData(ClipboardData(text: csvBuffer.toString()));
  }

  void _triggerSavePlayers() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), _savePlayers);
  }

  void _savePlayers() {
    if (stateManager == null || _prefs == null) return;
    final rowsToUpdate = stateManager!.rows
        .map((e) => {
              'name_field': e.cells['name_field']?.value,
              'skill_level_field': e.cells['skill_level_field']?.value,
              'gender_field': e.cells['gender_field']?.value,
              'team_field': e.cells['team_field']?.value,
              'role_field': e.cells['role_field']?.value,
              'checked': e.checked,
            })
        .toList();
    _prefs!.setString('saved_players', jsonEncode(rowsToUpdate));
  }

  Future<void> _loadPlayers() async {
    _prefs ??= await SharedPreferences.getInstance();
    String? saved = _prefs!.getString('saved_players');
    if (saved != null) {
      List<dynamic> jsonMap = jsonDecode(saved);
      List<PlutoRow> loadedRows = jsonMap.map<PlutoRow>((e) {
        var row = PlutoRow(
          cells: {
            'name_field': PlutoCell(value: e['name_field'] ?? 'Unknown'),
            'skill_level_field': PlutoCell(value: e['skill_level_field'] ?? 3),
            'team_field': PlutoCell(value: e['team_field'] ?? "None"),
            'gender_field': PlutoCell(value: e['gender_field'] ?? "MALE"),
            'role_field': PlutoCell(value: e['role_field'] ?? "Any"),
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

  late List<PlutoColumn> columns;

  List<PlutoRow> rows = [];

  @override
  void initState() {
    super.initState();
    // Build columns once — allRoles de-duplicated at startup only
    final allRoles =
        SportPalette.values.expand((e) => e.roles).toSet().toList();
    columns = GridColumns.getColumns(allRoles);
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    // _prefs was already obtained in _initPrefs — no extra getInstance call
    final prefs = _prefs!;
    if (!mounted) return;
    setState(() {
      settingsData.teamCount = prefs.getInt('teamCount') ?? 2;
      settingsData.division = prefs.getInt('division') ?? 2;
      settingsData.proportion = prefs.getInt('proportion') ?? 6;
      settingsData.gameVenues = prefs.getInt('gameVenues') ?? 1;
      settingsData.gameRounds = prefs.getInt('gameRounds') ?? 2;
      settingsData.preferExtraTeam = prefs.getBool('preferExtraTeam') ?? false;
      final savedOption =
          prefs.getString('genOption') ?? GenOption.evenGender.toString();
      settingsData.o = GenOption.values.firstWhere(
          (e) => e.toString() == savedOption,
          orElse: () => GenOption.evenGender);
    });
  }

  void _saveSettings() {
    if (_prefs == null) return;
    _prefs!.setInt('teamCount', settingsData.teamCount);
    _prefs!.setInt('division', settingsData.division);
    _prefs!.setInt('proportion', settingsData.proportion);
    _prefs!.setInt('gameVenues', settingsData.gameVenues);
    _prefs!.setInt('gameRounds', settingsData.gameRounds);
    _prefs!.setBool('preferExtraTeam', settingsData.preferExtraTeam);
    _prefs!.setString('genOption', settingsData.o.toString());
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
      title: Text(title),
      content: SingleChildScrollView(
        child: Text(message),
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
    TextEditingController playerText = TextEditingController(text: data);

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
              controller: playerText,
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
                String text = playerText.text;
                var lines = text.split("\n");
                var playerLine = [];
                var dateFieldRegex =
                    RegExp(r'^(J|F|M|A|M|J|A|S|O|N|D).*(AM|PM)$');
                var recordFlag = true;
                for (var i = 0; i < lines.length; i++) {
                  String line = lines[i].trim();
                  if (line.isEmpty) continue;

                  if (recordFlag && !dateFieldRegex.hasMatch(line)) {
                    String name = line;
                    String position = "Any";
                    if (line.contains("(") && line.contains(")")) {
                      final start = line.lastIndexOf("(");
                      final end = line.lastIndexOf(")");
                      if (end > start) {
                        position = line.substring(start + 1, end).trim();
                        name = line.substring(0, start).trim();
                      }
                    }
                    playerLine.add("$name,3,M,,$position");
                    recordFlag = false;
                    continue;
                  }

                  if (dateFieldRegex.hasMatch(line)) {
                    recordFlag = true;
                  }
                }
                playerText.text = playerLine.join("\n");
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
                String text = playerText.text;
                var lines = text.split("\n");
                var data = [];
                for (var i = 0; i <= lines.length - 1; i++) {
                  data.add("${lines[i]},3,M");
                }
                playerText.text = data.join("\n");
              },
            ),
            const Text('Press check button to see what will be added'),
            ElevatedButton.icon(
              icon: Icon(
                FontAwesomeIcons.magnifyingGlass,
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
                var lines = playerText.text.split("\n");
                var stringData = [];

                for (var i = 0; i <= lines.length - 1; i++) {
                  var mapData = {
                    "name": "x",
                    "level": 3,
                    "gender": "MALE",
                    "team": "None",
                    "position": "Any"
                  };

                  var data = lines[i].split(",");
                  for (var j = 0; j < data.length; j++) {
                    switch (j) {
                      case 0:
                        {
                          mapData["name"] = data[0];
                        }
                        break;
                      case 1:
                        {
                          mapData["level"] = double.tryParse(data[1]) ?? 3;
                        }
                        break;
                      case 2:
                        {
                          if (data[2].trim().toUpperCase().startsWith("M")) {
                            mapData["gender"] = "MALE";
                          } else if (data[2]
                              .trim()
                              .toUpperCase()
                              .startsWith("F")) {
                            mapData["gender"] = "FEMALE";
                          } else {
                            mapData["gender"] = "X";
                          }
                        }
                        break;
                      case 3:
                        {
                          mapData["team"] = data[3];
                        }
                        break;
                      case 4:
                        {
                          mapData["position"] = data[4];
                        }
                        break;
                      default:
                        {
                          break;
                        }
                    }
                  }
                  stringData.add("$mapData\n");
                }
                showTextDialog(context, "Following players will be added",
                    stringData.join("\n"));
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
            var lines = playerText.text.split("\n");

            for (var i = 0; i <= lines.length - 1; i++) {
              var mapData = {
                "name": "x",
                "level": 3,
                "gender": "MALE",
                "team": "None",
                "position": "Any"
              };

              var data = lines[i].split(",");
              for (var j = 0; j < data.length; j++) {
                switch (j) {
                  case 0:
                    {
                      mapData["name"] = data[0];
                    }
                    break;
                  case 1:
                    {
                      mapData["level"] = int.tryParse(data[1]) ?? 3;
                    }
                    break;
                  case 2:
                    {
                      if (data[2].trim().toUpperCase().startsWith("M")) {
                        mapData["gender"] = "MALE";
                      } else if (data[2].trim().toUpperCase().startsWith("F")) {
                        mapData["gender"] = "FEMALE";
                      } else {
                        mapData["gender"] = "X";
                      }
                    }
                    break;
                  case 3:
                    {
                      mapData["team"] = data[3];
                    }
                    break;
                  case 4:
                    {
                      mapData["position"] = data[4];
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
                    'name_field': PlutoCell(value: mapData["name"]),
                    'skill_level_field': PlutoCell(value: mapData["level"]),
                    'team_field': PlutoCell(value: mapData["team"]),
                    'gender_field': PlutoCell(value: mapData["gender"]),
                    'role_field': PlutoCell(value: mapData["position"]),
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
            'role_field': PlutoCell(value: player.role),
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

    Map<String, List<PlutoRow>> teamsRows = {};
    Map<String, double> teamsTotalScore = {};

    //find checked items

    for (var i = 0; i < dat.length; i++) {
      if (dat[i]?.checked ?? false) {
        // teams_name_list.update(dat[i]?.cells?["team_field"]?.value?? "None", (value) => null)
        var t = dat[i]!.cells["skill_level_field"]?.value;
        assert(() {
          debugPrint('skill_level type: ${t.runtimeType}');
          return true;
        }());
        teamsTotalScore.update(
          dat[i]!.cells["team_field"]?.value ?? "None",
          // You can ignore the incoming parameter if you want to always update the value even if it is already in the map
          (existingValue) =>
              existingValue +
              (dat[i]?.cells["skill_level_field"]?.value ?? 0).toDouble(),
          ifAbsent: () =>
              (dat[i]?.cells["skill_level_field"]?.value ?? 0).toDouble(),
        );

        teamsRows.update(
          dat[i]?.cells["team_field"]?.value ?? "None",
          (existingValue) {
            existingValue.add(dat[i]!);
            return existingValue;
          },
          ifAbsent: () => [dat[i]!],
        );
      } else {
        //TODO unassign team
      }
    }

    // for (var i = 1; i <= teams; i++) {
    //   teams_list[i.toString()] = [];
    // }
    List<ListItem> teamsListData = [];
    // print(teams_list.toString());
    teamsRows.keys.toList().forEach((value) {
      if (value == "None") return;
      var players = teamsRows[value]!.length;
      var totalScore = teamsTotalScore[value];
      var avgScore = (teamsTotalScore[value]! / teamsRows[value]!.length)
          .toStringAsFixed(2);

      teamsListData.add(HeadingItem('TEAM#: $value',
          '$players players with average level  $avgScore and combine level  $totalScore'));
      for (var row in teamsRows[value]!) {
        teamsListData.add(MessageItem(row));
      }
    });
    // print(teams_list_data);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TeamList(
                  items: teamsListData,
                  settingsData: settingsData,
                  sport: widget.themeController?.palette,
                )));
  }

  void generateTeams() {
    stateManager!.sortAscending(
        stateManager!.columns.firstWhere((c) => c.field == 'name_field'));

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

    if (settingsData.o == GenOption.evenGender) {
      int playerNum = dat.length;
      if (settingsData.preferExtraTeam) {
        settingsData.teamCount = (playerNum / settingsData.proportion).ceil();
      } else {
        settingsData.teamCount = (playerNum / settingsData.proportion).floor();
      }
      if (settingsData.teamCount == 0) settingsData.teamCount = 1;
      assert(() {
        debugPrint('TEAMS CALCULATED: ${settingsData.teamCount}');
        return true;
      }());
    }

    Map<String, List<PlutoRow>> teamsList = TeamGenerator.generateTeams(
      dat,
      settingsData,
      sport: widget.themeController?.palette,
    );

    // Single setState after all assignments — avoids N rebuilds during team generation
    setState(() {
      teamsList.forEach((key, value) {
        for (final element in value) {
          element.cells['team_field']?.value = key;
        }
      });
    });

    _navigateToTeam();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Maker Buddy',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Team Picker',
            icon: const FaIcon(FontAwesomeIcons.dice, size: 20),
            onPressed: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          RandomTeamScreen(
                            initialTotal: 6,
                          )));
            },
          ),
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
            tooltip: 'Appearance',
            icon: const FaIcon(FontAwesomeIcons.palette, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    settingsData,
                    themeController: widget.themeController,
                  ),
                ),
              );
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
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        children: [
          FadeSlideIn(
            delay: const Duration(milliseconds: 0),
            child: SectionHeader(
                title: 'QUICK TOOLS',
                icon: FontAwesomeIcons.bolt,
                color: Colors.orangeAccent),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  QuickToolCard(
                    title: 'TAP SCORE',
                    icon: Theme.of(context)
                            .extension<SportIconExtension>()
                            ?.icon ??
                        Icons.sports,
                    color: colorScheme.primary,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TapScoreScreen()));
                    },
                  ),
                  const SizedBox(width: 12),
                  QuickToolCard(
                    title: 'MATCH MAKER',
                    icon: FontAwesomeIcons.trophy,
                    color: Colors.amber,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MatchScreen(settingsData)));
                    },
                  ),
                  const SizedBox(width: 12),
                  QuickToolCard(
                    title: 'PLAYER QUEUE',
                    icon: FontAwesomeIcons.dice,
                    color: Colors.purpleAccent,
                    onTap: () {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder: (context, anim, sec) =>
                                  const RandomTeamScreen(initialTotal: 6)));
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeSlideIn(
            delay: const Duration(milliseconds: 80),
            child: SectionHeader(
                title: '1. PLAYER ROSTER',
                icon: FontAwesomeIcons.users,
                color: colorScheme.primary),
          ),
          Card(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            margin: const EdgeInsets.only(bottom: 8.0),
            child: ExpansionTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              childrenPadding: EdgeInsets.zero,
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
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
                  height: 400,
                  child: PlutoGrid(
                    columns: columns,
                    rows: rows,
                    rowColorCallback: (rowContext) {
                      if (rowContext.row.cells['name_field']?.value ==
                          'player level gender and team') {
                        return colorScheme.errorContainer
                            .withValues(alpha: 0.1);
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          border: Border(
                              bottom: BorderSide(
                                  color: colorScheme.outlineVariant)),
                        ),
                        child: SingleChildScrollView(
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
                              const SizedBox(width: 6),
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
                              const SizedBox(width: 6),
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
                                icon: _isEditable ? Icons.edit_off : Icons.edit,
                                label: _isEditable ? 'Lock' : 'Edit',
                                color: _isEditable
                                    ? colorScheme.tertiary
                                    : colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
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
                      );
                    },
                    onLoaded: (PlutoGridOnLoadedEvent event) {
                      stateManager = event.stateManager;
                      stateManager!.addListener(_triggerSavePlayers);
                      _loadPlayers();
                    },
                    onRowChecked: (PlutoGridOnRowCheckedEvent event) {
                      setState(() {
                        if (event.row != null && !event.row!.checked!) {
                          event.row!.cells['team_field']?.value = 'No team';
                        } else if (event.row == null) {
                          // Handle 'check all' toggles
                          for (var r in stateManager!.rows) {
                            if (!r.checked!) {
                              r.cells['team_field']?.value = 'No team';
                            }
                          }
                        }
                      });
                      _triggerSavePlayers();
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
          FadeSlideIn(
            delay: const Duration(milliseconds: 160),
            child: SectionHeader(
                title: '2. BALANCE STRATEGY',
                icon: FontAwesomeIcons.gears,
                color: colorScheme.secondary),
          ),
          Card(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            margin: const EdgeInsets.only(bottom: 8.0),
            child: ExpansionTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              childrenPadding: EdgeInsets.zero,
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
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
                'Mode: ${settingsData.o.toString().split('.').last.replaceAll('_', ' ').toUpperCase()} • ${stateManager?.rows.where((r) => r.checked == true).length ?? 0} Players Selected',
                style: TextStyle(
                    fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
              children: [
                RadioGroup<GenOption>(
                  groupValue: settingsData.o,
                  onChanged: (GenOption? value) {
                    setState(() {
                      settingsData.o = value ?? settingsData.o;
                      _saveSettings();
                    });
                  },
                  child: Column(
                    children: [
                      StrategyOption(
                        option: GenOption.evenGender,
                        title: 'Fair Mix (Best)',
                        subtitle:
                            'Mix players by gender and skill correctly. Grows teams naturally (${settingsData.proportion}/team).',
                        icon: Icons.wc,
                        isSelected: settingsData.o == GenOption.evenGender,
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
                        option: GenOption.distribute,
                        title: 'Skill Balance',
                        subtitle: 'Spread top players across teams fairly.',
                        icon: Icons.balance,
                        isSelected: settingsData.o == GenOption.distribute,
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
                        option: GenOption.division,
                        title: 'Ranked Groups',
                        subtitle:
                            'Put strong players together and new players together.',
                        icon: Icons.military_tech,
                        isSelected: settingsData.o == GenOption.division,
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
                        option: GenOption.random,
                        title: 'Random',
                        subtitle: 'Mix players with no rules.',
                        icon: Icons.shuffle,
                        isSelected: settingsData.o == GenOption.random,
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
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: generateTeams,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Theme.of(context)
                                    .extension<SportIconExtension>()
                                    ?.icon ??
                                Icons.sports,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'GENERATE TEAMS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.flash_on, size: 16),
                        ],
                      ),
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
            FadeSlideIn(
              delay: const Duration(milliseconds: 0),
              child: SectionHeader(
                  title: '3. RESULTS',
                  icon: FontAwesomeIcons.trophy,
                  color: colorScheme.tertiary),
            ),
            Card(
              elevation: 4,
              shadowColor: colorScheme.tertiary.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                    color: colorScheme.tertiary.withValues(alpha: 0.3)),
              ),
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ExpansionTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                childrenPadding: EdgeInsets.zero,
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
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
                dense: true,
                visualDensity: VisualDensity.compact,
                childrenPadding: EdgeInsets.zero,
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
                initiallyExpanded: true,
                leading: CircleAvatar(
                    backgroundColor: colorScheme.surfaceContainerHighest,
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
            margin: const EdgeInsets.only(bottom: 8.0),
            child: ExpansionTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              childrenPadding: EdgeInsets.zero,
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
              initiallyExpanded: true,
              leading: CircleAvatar(
                  backgroundColor:
                      colorScheme.secondaryContainer.withValues(alpha: 0.5),
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
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            )
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
                    // Sync team count to actually generated teams to exclude empty ones
                    // We calculate this based on the unique team assignments in the grid
                    var activeTeams = stateManager!.rows
                        .where((r) => r.checked == true)
                        .map((r) => r.cells['team_field']?.value.toString())
                        .where(
                            (t) => t != null && t != "None" && t != "No team")
                        .toSet()
                        .length;

                    if (activeTeams >= 2) {
                      settingsData.teamCount = activeTeams;
                    }

                    // Default to 1 venue and calculate rounds for a full round-robin
                    settingsData.gameVenues = 1;
                    settingsData.gameRounds = settingsData.teamCount.isOdd
                        ? settingsData.teamCount
                        : (settingsData.teamCount - 1).clamp(1, 99);

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MatchScreen(settingsData)));
                  },
                  icon: FontAwesomeIcons.trophy,
                  label: 'Match',
                  color: colorScheme.tertiary,
                ),
                BottomNavButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TapScoreScreen()));
                  },
                  icon: FontAwesomeIcons.stopwatch20,
                  label: 'Score',
                  color: colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
